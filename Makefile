PYTHON ?= python
PIP ?= $(PYTHON) -m pip
GO ?= go
TRIVY ?= trivy


.PHONY: create-container
create-container:
	base-deploy docker --tag hydra-runner:0.0.1 --target dockerfiles/github-arc-runners


.PHONY: deploy-all
deploy-all:
	base-deploy --version
	make deploy-vpc
	make deploy-s3
	make deploy-eks
	make deploy-argo
	make deploy-argo-example
	make deploy-jenkins-example
	make deploy-arc
	make deploy-nexus


.PHONY: destroy-all
destroy-all:
	make deploy-arc DESTROY=--destroy
	make deploy-argo-example DESTROY=--destroy
	make deploy-argo DESTROY=--destroy
	make deploy-eks DESTROY=--destroy
	make deploy-s3 DESTROY=--destroy
	make deploy-vpc DESTROY=--destroy


.PHONY: deploy-arc
deploy-arc:
	base-deploy terraform --target "terraform/helm/github-arc" $(DESTROY)


.PHONY: deploy-argo
deploy-argo:
	base-deploy terraform --target "terraform/helm/argo" $(DESTROY)


.PHONY: deploy-argo-example
deploy-argo-example:
	base-deploy terraform --target "terraform/kubernetes/manifests/argo-example-app" $(DESTROY)


.PHONY: deploy-jenkins-example
deploy-jenkins-example:
	base-deploy terraform --target "terraform/kubernetes/manifests/jenkins-example"	$(DESTROY)


.PHONY: deploy-eks
deploy-eks:
	base-deploy terraform --target "terraform/eks/base" $(DESTROY)


.PHONY: deploy-nexus
deploy-nexus:
	base-deploy terraform --target "terraform/kubernetes/manifests/nexus" $(DESTROY)


.PHONY: deploy-s3
deploy-s3:
	base-deploy terraform --target "terraform/s3/base" $(DESTROY)


.PHONY: deploy-vpc
deploy-vpc:
	base-deploy terraform --target "terraform/vpc/base" $(DESTROY)


.PHONY: deployer-test
deployer-test:
	$(PYTHON) -m pylint base-infra-deployer/src
	$(PYTHON) -m unittest -v base-infra-deployer/tests/test_deployer.py


.PHONY: install
install:
	$(PYTHON) --version
	$(PYTHON) -m pip install --upgrade pip
	$(PIP) install base-infra-deployer/


.PHONY: kitchen-test
kitchen-test:
	cd cookbooks/base-ami && kitchen test


.PHONY: terratest
terratest:
	$(GO) -C terraform/modules/s3/test mod tidy
	$(GO) -C terraform/modules/s3/test test -v
	$(GO) -C terraform/modules/vpc/test mod tidy
	$(GO) -C terraform/modules/vpc/test test -v


.PHONY: test-shell
test-shell:
	shellcheck setup-aws-params.sh


.PHONY: test
test:  test-shell terratest install deployer-test


.PHONY: tf-trivy
tf-trivy:
	$(TRIVY) config --config=trivy.yaml terraform


.PHONY: clean
clean:
	$(PIP) uninstall -y \
		astroid \
		base-infra-deployer \
		boto3 \
		botocore \
		certifi \
		charset-normalizer \
		colorama \
		dill \
		docutils \
		importlib-metadata \
		idna \
		isort \
		jaraco.classes \
		jmespath \
		keyring \
		markdown-it-py \
		mccabe \
		mdurl \
		more-itertools \
		nh3 \
		pkginfo \
		platformdirs \
		pylint \
		Pygments \
		python-dateutil \
		pywin32-ctypes \
		readme-renderer \
		requests \
		requests-toolbelt \
		rfc3986 \
		rich \
		s3transfer \
		six \
		tomlkit \
		twine \
		urllib3 \
		zipp

	rm -rf build \
		*.egg-info \
		base-infra-deployer/build \
		base-infra-deployer/dist \
		base-infra-deployer/src/*egg-info \
		src/*.egg-info
