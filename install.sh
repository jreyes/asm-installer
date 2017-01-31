#!/bin/bash -e

if [[ ! -x $(which lsb_release 2>/dev/null) ]]; then
  echo "ERROR: lsb_release is not installed"
  echo "Cannot evaluate the platform"
  echo "Please install lsb_release and retry"
  echo "Red Hat based Systems : yum install redhat-lsb-core"
  echo "Debian based Systems : apt-get install lsb-release"
  exit 1
fi

# GET OS VENDOR
os_VENDOR=$(lsb_release -i -s)
# GET OS MAJOR VERSION
os_VERSION=$(lsb_release  -r  -s | cut -d. -f 1)

echo "*** Detected Linux $os_VENDOR $os_VERSION ***"

if git --version &> /dev/null ; then
  echo "Git is already installed."
else
  if [[ "Debian" =~ $os_VENDOR || "Raspbian" =~ $os_VENDOR || "Ubuntu" =~ $os_VENDOR || "LinuxMint" =~ $os_VENDOR ]]; then
    sudo apt-get update
    sudo apt-get install -y git
  else
    echo "*** Unsupported platform ${os_VENDOR}: ${os_VERSION} ***"
    exit 1
  fi

  if ( git --version &> /dev/null ); then
    echo "*** $(git --version | head -n1) installed successfully ***"
  else
    echo "Something went wrong, please have a look at the script output"
    exit 1
  fi
fi

if ansible --version &> /dev/null ; then
  echo "Ansible is already installed."
else
  if [[ "Debian" =~ $os_VENDOR || "Raspbian" =~ $os_VENDOR ]]; then
    sudo apt-get update
    sudo apt-get install -y ansible
  elif [[ "Ubuntu" =~ $os_VENDOR || "LinuxMint" =~ $os_VENDOR ]]; then
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository -y ppa:ansible/ansible
    sudo apt-get update
    sudo apt-get install -y ansible
  else
    echo "*** Unsupported platform ${os_VENDOR}: ${os_VERSION} ***"
    exit 1
  fi

  if ( ansible --version &> /dev/null ); then
    echo "*** $(ansible --version | head -n1) installed successfully ***"
  else
    echo "Something went wrong, please have a look at the script output"
    exit 1
  fi
fi

if [[ -d "asm-installer" ]]; then
    echo "Removing existing installer directory"
    rm -rf asm-installer
fi

if git clone https://github.com/jreyes/asm-installer.git; then
    echo "*** Another Smart Mirror installer cloned ***"
else
    echo "*** Unable to clone the Another Smart Mirror installer ***"
    exit 1;
fi

cd asm-installer
ansible-galaxy install -r ansible/requirements.yml
ansible-playbook -i "localhost", -vvv -c local ansible/setup-asm.yml
cd ..

set +x
echo "Installation completed."
