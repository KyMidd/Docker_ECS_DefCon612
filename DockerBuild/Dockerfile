FROM ubuntu:20.04

# Set PowerShell version to download and install
ARG PS_PACKAGE_URL=https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/powershell_7.1.3-1.ubuntu.20.04_amd64.deb
ENV DEBIAN_FRONTEND=noninteractive

# Define ENVs for Localization/Globalization  
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    # set a fixed location for the Module analysis cache
    PSModuleAnalysisCachePath=/var/cache/microsoft/powershell/PSModuleAnalysisCache/ModuleAnalysisCache \
    POWERSHELL_DISTRIBUTION_CHANNEL=PSDocker-Ubuntu-20.04

# Set assume-yes for non-interactive install
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

# Install tooling
RUN apt-get update \
  && apt-get install -y \
    ca-certificates \
    less \
    npm \
    nodejs \
    less \
    locales \
    gss-ntlmssp \
    openssh-client \
    curl \
    jq \
    git \
    netcat \
    apt-transport-https \
    lsb-release \
    gnupg \
    build-essential \
    python-all \
    rlwrap  \
    vim  \
    nano \
    zip \
    unzip \
    iputils-ping \
    software-properties-common \
    libcurl4 \
    libunwind8 \
    netcat \
    libssl1.0 \
    liblttng-ust0 \
    liblog4j2-java \
    g++ \
    apache2-utils \
    awscli \
    wget \
    unzip \
    sudo \
    gnupg-agent \
    libnl-utils \
    libnl-genl-3-200 \
    yamllint \
#install kubectl
  && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
  && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
# install zulu java
  && apt-key adv \
  --keyserver hkp://keyserver.ubuntu.com:80 \
  --recv-keys 0xB1998361219BD9C9 \
  && curl -O https://cdn.azul.com/zulu/bin/zulu-repo_1.0.0-2_all.deb \
  && apt-get install ./zulu-repo_1.0.0-2_all.deb \
  && apt-get update \
  && apt-get install zulu11-jdk \
# Download the Linux powershell package and save it
  && echo ${PS_PACKAGE_URL} \
  && curl -sSL ${PS_PACKAGE_URL} -o /tmp/powershell.deb \
  && apt-get install -y /tmp/powershell.deb \
  && locale-gen $LANG && update-locale \
# Remove powershell package
  && rm /tmp/powershell.deb \
# Intialize powershell module cache and disable telemetry
  && export POWERSHELL_TELEMETRY_OPTOUT=1 \
  && pwsh \
      -NoLogo \
      -NoProfile \
      -Command " \
        \$ErrorActionPreference = 'Stop' ; \
        \$ProgressPreference = 'SilentlyContinue' ; \
        Install-Module -Name Az -Scope CurrentUser -Force -AllowClobber; \
        while(!(Test-Path -Path \$env:PSModuleAnalysisCachePath)) {  \
          Write-Host "'Waiting for $env:PSModuleAnalysisCachePath'" ; \
        }"

# Install Azure CLI
RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash \ 
  && rm -rf /var/lib/apt/lists/*

# Install Dotnet 5
RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -k -O packages-microsoft-prod.deb \
     && dpkg -i packages-microsoft-prod.deb

# Install updates
RUN apt-get update && \
    apt-get install -y dotnet-sdk-5.0

# Install NPM, newman cli and newman-report-html
RUN npm install -g npm-check \
  && npm install -g newman \
  && npm install -g newman-reporter-html \
  && npm install -g npm-check-updates \
  && npm update -g

# Install latest terraform version
RUN TF_LATEST_VER=$(curl --silent "https://api.github.com/repos/hashicorp/terraform/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/') \
    && wget https://releases.hashicorp.com/terraform/${TF_LATEST_VER}/terraform_${TF_LATEST_VER}_linux_amd64.zip \
    && unzip terraform_${TF_LATEST_VER}_linux_amd64.zip \
    && sudo mv terraform /usr/bin/ \
    && sudo rm -rf /usr/local/bin/terraform

# Install latest Azure DevOps agent version
ARG TARGETARCH=x64
WORKDIR /azp
RUN ADO_RUNNER_LATEST=$(curl --silent "https://github.com/microsoft/azure-pipelines-agent/releases/latest" | grep -oE '[0-9].[0-9][0-9][0-9].[0-9]') \
  && if [ "$TARGETARCH" = "amd64" ]; then \
      AZP_AGENTPACKAGE_URL=https://vstsagentpackage.azureedge.net/agent/${ADO_RUNNER_LATEST}/vsts-agent-linux-x64-${ADO_RUNNER_LATEST}.tar.gz; \
    else \
      AZP_AGENTPACKAGE_URL=https://vstsagentpackage.azureedge.net/agent/${ADO_RUNNER_LATEST}/vsts-agent-linux-${TARGETARCH}-${ADO_RUNNER_LATEST}.tar.gz; \
    fi; \
    curl -LsS "$AZP_AGENTPACKAGE_URL" | tar -xz

# Fully update image and packages
RUN apt-get update -y \
  && apt-get upgrade -y \
# Clean the apt cache to reduce image size
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Stage start.sh and mark runnable
COPY ./start.sh .
RUN chmod +x start.sh

# Define entrypoint
ENTRYPOINT [ "./start.sh" ]
