locals {
  cluster_name          = "${var.owner}-${local.base_tags.environment}-eks-${var.region}"
  ebs_volume_size       = "100Gi"
  ebs_volume_type       = "gp2"
  karpenter_chart       = "karpenter"
  karpenter_version     = "v0.32.1"
  karpenter_namespace   = "karpenter"
  karpenter_repository  = "oci://public.ecr.aws/karpenter"
  karpenter_annotations = "com/role-arn"
  k8s_file              = "karpenter.yaml"
  k8s_path              = "../../../kubernetes/manifests/karpenter"

  values_map = {
    serviceAccount = {
      annotations = {
        tostring("eks.amazonaws.com/role-arn") = aws_iam_role.karpenter_controller.arn
      }
    }

    settings = {
      aws = {
        clusterName            = data.aws_ssm_parameter.eks_cluster_name.value
        clusterEndpoint        = data.aws_ssm_parameter.eks_cluster_endpoint.value
        interruptionQueue      = data.aws_ssm_parameter.eks_cluster_name.value
        defaultInstanceProfile = aws_iam_instance_profile.karpenter.name
      }
    }
  }
}

module "karpenter" {
  source        = "../../modules/helm-install"
  chart         = local.karpenter_chart
  chart_version = local.karpenter_version
  namespace     = local.karpenter_namespace
  release_name  = local.karpenter_chart
  repository    = local.karpenter_repository
  values_map    = local.values_map
}

resource "kubernetes_manifest" "karpenter_provisioner" {
  manifest = {
    apiVersion = "karpenter.sh/v1alpha5"

    kind = "Provisioner"

    metadata = {
      name = "karpenter-provisioner-1"
    }

    spec = {
      requirements = [
        {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values = [
            "on-demand"
          ]
        },
        {
          key      = "node.kubernetes.io/instance-type"
          operator = "In"
          values = [
            "t3.small",
            "t3.medium",
            "t3.large"
          ]
        }
      ]

      limits = {
        resources = {
          cpu = 95
        }
      }

      provider = {
        blockDeviceMappings = [{
          deviceName = "/dev/xvda",
          ebs = {
            deleteOnTermination = true
            volumeSize          = local.ebs_volume_size
            volumeType          = local.ebs_volume_type
          }
        }]

#        subnetSeletor = {
#          "kubernetes.io/cluster" = "shared"
#        }

        securityGroupSelector = {
          "karpenter.sh/discovery/${data.aws_ssm_parameter.eks_cluster_name.value}" = data.aws_ssm_parameter.eks_cluster_name.value
        }

        tags = {
          "karpenter.sh/discovery/${data.aws_ssm_parameter.eks_cluster_name.value}" = data.aws_ssm_parameter.eks_cluster_name.value
        }

        ttlSecondsAfterEmpty = 30
      }
    }
  }

  depends_on = [
    module.karpenter
  ]
}
