#!/bin/bash -x
if [ $# -ne 1 ]
then
  echo 'Usage: $0 <hostname>'
  exit
fi

HOSTNAME=$1

if [ -f /etc/redhat-release ]
then
  hostnamectl set-hostname $HOSTNAME

  RELVER=$(grep -o '[0-9]*' /etc/redhat-release |head -1)
  yum install -q -y http://dl.fedoraproject.org/pub/epel/epel-release-latest-${RELVER}.noarch.rpm
  yum install -q -y https://yum.puppetlabs.com/puppetlabs-release-el-${RELVER}.noarch.rpm
  yum update -q -y
  yum install -q -y puppet

  systemctl disable firewalld

  puppet resource augeas selinux_config context=/files/etc/selinux/config changes="set SELINUX disabled"
  puppet resource augeas network context=/files/etc/sysconfig/network changes="set HOSTNAME ${HOSTNAME}"
  puppet resource augeas sshd_config context=/files/etc/ssh/sshd_config changes="set Port 65022"

  puppet resource user lax ensure=present managehome=true groups=wheel
  puppet resource file /etc/sudoers.d/lax content='lax      ALL=(ALL)       NOPASSWD: ALL'
  puppet resource file /data ensure=directory owner=lax
  puppet resource file /home/lax/data ensure=link target=/data/apps

  for u in lax root
  do
    puppet resource ssh_authorized_key liulantao@gmail.com user=$u type=ssh-rsa key="AAAAB3NzaC1yc2EAAAADAQABAAABAQC630AGTfMzPZciLhPFzmfSMqjcd4Z6B7uJgaOj0ihl8KUORB4ii2MBuw941VImwSzrr5sqC9m+xvWuONiFRdCmhnG9tEQPp5t9qZRFuIAncsX2DNiwETq7PSxDxedTBPVtbzOOf/1IttJiR1yBujwCEmeQPFg+hrEjHpQ3KlispQ/VYBY9hWXEb17DSICofJjR5dtWVb7pRJZHgqueq76FSJXII410MM9et0UcZtodpvwrQ1vjfyWmcZ97F+tvmL552sMmwDs+LIE2b/CpSZ70DHb4ByWKA4HbXSHA9R2tyi5xIevv5WyQ6camlENUgoRAiL/0x4a9lADKeFZ8rlFF"
    puppet resource ssh_authorized_key liulantao@gmail.com-1 user=$u type=ssh-rsa key="AAAAB3NzaC1yc2EAAAADAQABAAABAQDU6Cfwvp6WIY55baM5vJelJ4KeBoF8JlpBGivFm0VQroDuCR8D3jpc0ua86PxP1uv8ms3J+Nz9Z82rk9VrDRgZnA0J2D/A0cHRfDvIo2oDpgm6aK0R6GBRihJm7kLxMpOgZHnJmE2BxthUn4VUCRBLw4V8+cDsYecLkqrWiBn+7A1l+h0YHC0UqbUeILWkc4yDKolf7f2WQ2NtDnV9x0MpAvUh5nFbuSD5x3mceNoLSqRJIRwEro3GrHjdkPuhBr1cJNzktwpoia9ZI3g5tIPmz4snJw0br7b6MfEjUK4Uv5+kUUTqJh8R7/G3y5elzuYOhhi+4SslWs9OmLgZvytX"
  done
fi
