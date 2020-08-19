#! /bin/bash

# Override existing DNS Settings using netplan, but don't do it for Terraform builds
if ! curl -s 169.254.169.254 --connect-timeout 2 >/dev/null; then
  echo -e "    eth1:\n      dhcp4: true\n      nameservers:\n        addresses: [1.1.1.1,8.8.8.8]" >>/etc/netplan/01-netcfg.yaml
  netplan apply
fi
sed -i 's/nameserver 127.0.0.53/nameserver 1.1.1.1/g' /etc/resolv.conf && chattr +i /etc/resolv.conf

export DEBIAN_FRONTEND=noninteractive
echo "apt-fast apt-fast/maxdownloads string 10" | debconf-set-selections
echo "apt-fast apt-fast/dlflag boolean true" | debconf-set-selections

apt_install_prerequisites() {
  echo "[$(date +%H:%M:%S)]: Adding apt repositories..."
  # Add repository for apt-fast
  add-apt-repository -y ppa:apt-fast/stable
  # Add repository for yq
  add-apt-repository -y ppa:rmescandon/yq
  # Install prerequisites and useful tools
  echo "[$(date +%H:%M:%S)]: Running apt-get clean..."
  apt-get clean
  echo "[$(date +%H:%M:%S)]: Running apt-get update..."
  apt-get -qq update
  apt-get -qq install -y apt-fast
  echo "[$(date +%H:%M:%S)]: Running apt-fast install..."
  apt-fast -qq install -y jq whois build-essential git unzip htop yq nano
}

test_prerequisites() {
  for package in jq whois build-essential git unzip yq nano; do
    echo "[$(date +%H:%M:%S)]: [TEST] Validating that $package is correctly installed..."
    # Loop through each package using dpkg
    if ! dpkg -S $package >/dev/null; then
      # If which returns a non-zero return code, try to re-install the package
      echo "[-] $package was not found. Attempting to reinstall."
      apt-get -qq update && apt-get install -y $package
      if ! which $package >/dev/null; then
        # If the reinstall fails, give up
        echo "[X] Unable to install $package even after a retry. Exiting."
        exit 1
      fi
    else
      echo "[+] $package was successfully installed!"
    fi
  done
}

install_splunk() {
  # Check if Splunk is already installed
  if [ -f "/opt/splunk/bin/splunk" ]; then
    echo "[$(date +%H:%M:%S)]: Splunk is already installed"
  else
    # Get download.splunk.com into the DNS cache. Sometimes resolution randomly fails during wget below
    dig @8.8.8.8 download.splunk.com >/dev/null
    dig @8.8.8.8 splunk.com >/dev/null
    dig @8.8.8.8 www.splunk.com >/dev/null
    # Download Splunk
    echo "[$(date +%H:%M:%S)]: Downloading Splunk..."
    wget --progress=bar:force -O /opt/splunk-8.0.5-a1a6394cc5ae-linux-2.6-amd64.deb 'http://download.splunk.com/products/splunk/releases/8.0.5/linux/splunk-8.0.5-a1a6394cc5ae-linux-2.6-amd64.deb'
    # Install Splunk
    echo "[$(date +%H:%M:%S)]: Installing Splunk..."
    if ! ls /opt/splunk*.deb 1>/dev/null 2>&1; then
      echo "Something went wrong while trying to download Splunk. This script cannot continue. Exiting."
      exit 1
    fi
    if ! dpkg -i /opt/splunk*.deb >/dev/null; then
      echo "Something went wrong while trying to install Splunk. This script cannot continue. Exiting."
      exit 1
    fi

    # Start Splunk
    /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd changeme

    # Add wineventlog Index
    /opt/splunk/bin/splunk add index wineventlog -auth 'admin:changeme'

    # Install TAs
    /opt/splunk/bin/splunk install app /vagrant/resources/splunk_forwarder/splunk-add-on-for-microsoft-windows_800.tgz -auth 'admin:changeme'
    /opt/splunk/bin/splunk install app /vagrant/resources/splunk_forwarder/splunk-add-on-for-microsoft-sysmon_1062.tgz -auth 'admin:changeme'

    # Add a Splunk TCP input on port 9997
    echo -e "[splunktcp://9997]\nconnection_host = ip" >/opt/splunk/etc/apps/search/local/inputs.conf

    # Skip Splunk Tour and Change Password Dialog
    echo "[$(date +%H:%M:%S)]: Disabling the Splunk tour prompt..."
    touch /opt/splunk/etc/.ui_login
    mkdir -p /opt/splunk/etc/users/admin/search/local
    echo -e "[search-tour]\nviewed = 1" >/opt/splunk/etc/system/local/ui-tour.conf
    # Source: https://answers.splunk.com/answers/660728/how-to-disable-the-modal-pop-up-help-us-to-improve.html
    if [ ! -d "/opt/splunk/etc/users/admin/user-prefs/local" ]; then
      mkdir -p "/opt/splunk/etc/users/admin/user-prefs/local"
    fi
    echo '[general]
render_version_messages = 1
dismissedInstrumentationOptInVersion = 4
notification_python_3_impact = false' > /opt/splunk/etc/users/admin/user-prefs/local/user-prefs.conf
    # Enable SSL Login for Splunk
    echo -e "[settings]\nenableSplunkWebSSL = true" > /opt/splunk/etc/system/local/web.conf
    # Reboot Splunk to make changes take effect
    /opt/splunk/bin/splunk restart
    /opt/splunk/bin/splunk enable boot-start
  fi
}

install_guacamole_prereqs() {
    echo "[$(date +%H:%M:%S)]: Installing Guacamole pre-requisite packages..."
    apt-get -qq install -y gcc g++ libcairo2-dev libjpeg-turbo8-dev libpng-dev libtool-bin libossp-uuid-dev libavcodec-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev libssh2-1-dev libvncserver-dev libtelnet-dev libssl-dev libvorbis-dev libwebp-dev tomcat9 tomcat9-admin tomcat9-common tomcat9-user
}

test_guacamole_prerequisites() {
  for package in gcc g++ libcairo2-dev libjpeg-turbo8-dev libpng-dev libtool-bin libossp-uuid-dev libavcodec-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev libssh2-1-dev libvncserver-dev libtelnet-dev libssl-dev libvorbis-dev libwebp-dev tomcat9 tomcat9-admin tomcat9-common tomcat9-user; do
    echo "[$(date +%H:%M:%S)]: [TEST] Validating that $package is correctly installed..."
    # Loop through each package using dpkg
    if ! dpkg -S $package >/dev/null; then
      # If which returns a non-zero return code, try to re-install the package
      echo "[-] $package was not found. Attempting to reinstall."
      apt-get -qq update && apt-get install -y $package
      if ! which $package >/dev/null; then
        # If the reinstall fails, give up
        echo "[X] Unable to install $package even after a retry. Exiting."
        exit 1
      fi
    else
      echo "[+] $package was successfully installed!"
    fi
  done
}

install_guacamole() {
  echo "[$(date +%H:%M:%S)]: Installing Guacamole..."
  cd /opt || exit 1
  wget --progress=bar:force "http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/1.2.0/source/guacamole-server-1.2.0.tar.gz" -O guacamole-server-1.2.0.tar.gz
  tar -xf guacamole-server-1.2.0.tar.gz && cd guacamole-server-1.2.0 || echo "[-] Unable to find the Guacamole folder."
  ./configure &>/dev/null && make --quiet &>/dev/null && make --quiet install &>/dev/null || echo "[-] An error occurred while installing Guacamole."
  ldconfig
  cd /var/lib/tomcat9/webapps || echo "[-] Unable to find the tomcat9/webapps folder."
  wget --progress=bar:force "http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/1.2.0/binary/guacamole-1.2.0.war" -O guacamole.war
  mkdir /etc/guacamole
  mkdir /usr/share/tomcat9/.guacamole
  cp /vagrant/resources/guacamole/user-mapping.xml /etc/guacamole/
  cp /vagrant/resources/guacamole/guacamole.properties /etc/guacamole/
  cp /vagrant/resources/guacamole/guacd.service /lib/systemd/system
  sudo ln -s /etc/guacamole/guacamole.properties /usr/share/tomcat9/.guacamole/
  sudo ln -s /etc/guacamole/user-mapping.xml /usr/share/tomcat9/.guacamole/
  systemctl enable guacd
  systemctl enable tomcat9
  systemctl start guacd
  systemctl start tomcat9
}

postinstall_tasks() {
  # Include Splunk in the PATH
  echo export PATH="$PATH:/opt/splunk/bin" >>~/.bashrc
  echo "export SPLUNK_HOME=/opt/splunk" >>~/.bashrc
}

main() {
  apt_install_prerequisites
  test_prerequisites
  install_splunk
  install_guacamole_prereqs
  test_guacamole_prerequisites
  install_guacamole
  postinstall_tasks
}

main
exit 0