#!/bin/bash

if [ -z $REGION ];
  then echo "ERROR: Please set 'REGION' to your current AWS Region!" && exit 1;
fi
ROOT_DIR=`pwd`

git clone https://github.com/OpenVPN/easy-rsa.git
cd easy-rsa/easyrsa3
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa build-server-full server nopass
./easyrsa build-server-full zero-clientvpn-test nopass
mkdir custom_folder/
cp pki/ca.crt custom_folder/
cp pki/issued/server.crt custom_folder/
cp pki/private/server.key custom_folder/
cp pki/issued/zero-clientvpn-test.crt custom_folder
cp pki/private/zero-clientvpn-test.key custom_folder/
cd custom_folder/

# Import server cert to ACM
aws acm import-certificate \
  --certificate fileb://zero-clientvpn-test.crt \
  --private-key fileb://zero-clientvpn-test.key \
  --certificate-chain fileb://ca.crt \
  --tags Key=Name,Value=zero-clientvpn-test \
  --region $REGION
aws acm import-certificate \
  --certificate fileb://server.crt \
  --private-key fileb://server.key \
  --certificate-chain fileb://ca.crt \
  --tags Key=Name,Value=zero-clientvpn-test \
  --region $REGION
cd $ROOT_DIR
rm -rf easy-rsa