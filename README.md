# poc.Acm-Docker
Repo for generating certificate for ACM in Docker container 

### 
```
$ docker build -t centos:aws-cli .

$ docker run --rm -it --network=host -v "$(pwd)":/folder -w /folder \
-e "AWS_ACCESS_KEY_ID=AWSACCESSKEYID" \
-e "AWS_SECRET_ACCESS_KEY=AWSSECRETACCESSKEY" \ 
centos:aws-cli

[root@docker-desktop folder]# git clone https://github.com/OpenVPN/easy-rsa.git
Cloning into 'easy-rsa'...
remote: Enumerating objects: 2095, done.
remote: Counting objects: 100% (13/13), done.
remote: Compressing objects: 100% (11/11), done.
remote: Total 2095 (delta 3), reused 4 (delta 0), pack-reused 2082
Receiving objects: 100% (2095/2095), 11.72 MiB | 2.85 MiB/s, done.
Resolving deltas: 100% (916/916), done.

[root@docker-desktop folder]# cd easy-rsa/easyrsa3

[root@docker-desktop easyrsa3]# ./easyrsa init-pki

init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /folder/easy-rsa/easyrsa3/pki


[root@docker-desktop easyrsa3]# ./easyrsa init-pki


WARNING!!!

You are about to remove the EASYRSA_PKI at: /folder/easy-rsa/easyrsa3/pki
and initialize a fresh PKI here.

Type the word 'yes' to continue, or any other input to abort.
  Confirm removal: no

Aborting without confirmation.

[root@docker-desktop easyrsa3]# ./easyrsa build-ca nopass
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating RSA private key, 2048 bit long modulus
................+++
..........+++
e is 65537 (0x10001)
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/folder/easy-rsa/easyrsa3/pki/ca.crt


[root@docker-desktop easyrsa3]# ./easyrsa build-server-full server nopass
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating a 2048 bit RSA private key
........................................+++
.........+++
writing new private key to '/folder/easy-rsa/easyrsa3/pki/easy-rsa-91.tt6Z3S/tmp.drvz2q'
-----
Using configuration from /folder/easy-rsa/easyrsa3/pki/easy-rsa-91.tt6Z3S/tmp.lVPZXo
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'server'
Certificate is to be certified until Feb 15 00:35:09 2024 GMT (825 days)

Write out database with 1 new entries
Data Base Updated

[root@docker-desktop easyrsa3]# ./easyrsa build-client-full client1.domain.tld nopass
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating a 2048 bit RSA private key
...............+++
...........+++
writing new private key to '/folder/easy-rsa/easyrsa3/pki/easy-rsa-178.LgmYaY/tmp.68dHGA'
-----
Using configuration from /folder/easy-rsa/easyrsa3/pki/easy-rsa-178.LgmYaY/tmp.rkrWZn
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'client1.domain.tld'
Certificate is to be certified until Feb 15 00:35:21 2024 GMT (825 days)

Write out database with 1 new entries
Data Base Updated

[root@docker-desktop easyrsa3]# mkdir aws-acm
[root@docker-desktop easyrsa3]# cp pki/ca.crt aws-acm/
[root@docker-desktop easyrsa3]# cp pki/issued/server.crt aws-acm/
[root@docker-desktop easyrsa3]# cp pki/private/server.key aws-acm/
[root@docker-desktop easyrsa3]# cp pki/issued/client1.domain.tld.crt aws-acm/
[root@docker-desktop easyrsa3]# cp pki/private/client1.domain.tld.key aws-acm/
[root@docker-desktop easyrsa3]# cd aws-acm/
[root@docker-desktop aws-acm]# aws acm import-certificate --certificate fileb://server.crt --private-key fileb://server.key --certificate-chain fileb://ca.crt --region us-east-1
{
    "CertificateArn": "arn:aws:acm:us-east-1:391129762139:certificate/bde55518-1dcd-49e9-b635-ab411276ce98"
}
[root@docker-desktop aws-acm]# aws acm import-certificate --certificate fileb://client1.domain.tld.crt --private-key fileb://client1.domain.tld.key --certificate-chain fileb://ca.crt --region us-east-1
{
    "CertificateArn": "arn:aws:acm:us-east-1:391129762139:certificate/425ad363-01b2-4636-a99a-99fbe585f4ff"
}
[root@docker-desktop aws-acm]# exit

```

### AWS Vpn Client Config File (download after creating Client VPN endpoint)
#### The Client VPN endpoint configuration file includes a parameter called remote-random-hostname. This parameter forces the client to prepend a random string to the DNS name to prevent DNS caching. Some clients do not recognize this parameter and therefore, they do not prepend the required random string to the DNS name.
#### Open the Client VPN endpoint configuration file using your preferred text editor. Locate the line that specifies the Client VPN endpoint DNS name, and prepend a random string to it so that the format is random_string.displayed_DNS_name. For example:
```
Original DNS name: cvpn-endpoint-0102bc4c2eEXAMPLE.clientvpn.us-west-2.amazonaws.com
Modified DNS name: asdfa.cvpn-endpoint-0102bc4c2eEXAMPLE.clientvpn.us-west-2.amazonaws.com
```


```
client
dev tun
proto udp
remote asdfa.cvpn-endpoint-04cbb51e377af6e09.prod.clientvpn.us-east-1.amazonaws.com 443
remote-random-hostname
resolv-retry infinite
nobind
remote-cert-tls server
cipher AES-256-GCM
verb 3
<ca>
-----BEGIN CERTIFICATE-----
MIIDNTCCAh2gAwIBAgIJANPuVz5PoMuSMA0GCSqGSIb3DQEBCwUAMBYxFDASBgNV
BAMMC0Vhc3ktUlNBIMAGA4XDTIxMTExMTEwMzQyNFoXDTMxMTEwOTEwMzQyNFow
FjEUMBIGA1UEAwwLRWFzeS1SU0EgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
ggEKAoIBAQCW/vQAXYzYx6vNAl3Q9MfIr7Fw24cJEKMWbDtSFMdTjHyZKopzuHrG
zSbpNYfJ0fYY+YpDB5EgWslFtuBaSgiJjptckTVH5s62Zyf7OAYTZI0c3YwD0QjN
wmDLgVOW9fvBbU0ayxH3AMvYcEEi7cOJ+h+Wngo92VBodRQAhCLD7b2iSwkcc/V5
PT+9/GhL0XQfFm2pKwBEPeybLoi6l4BfJQ7LLjg3JnlZV5xeoMQne8Bv4YLDBJ+C
jyUacKebJTR+x+E47ZZsrC/WwO4+d7raRVr8C1QbwesJ2oPuWrrPgZh1TqZkQ+Hg
xFbtfbkNp7MnCc4i0XEopMaGaAuVKPldAgMBAAGjgYUwgYIwHQYDVR0OBBYEFFFc
MjMR0il1cqT7gyceA0KW9G9/MEYGA1UdIwQ/MD2AFFFcMjMR0il1cqT7gyceA0KW
9G9/oRqkGDAWMRQwEgYDVQQDDAtFYXN5LVJTQSBDQYIJANPuVz5PoMuSMAwGA1Ud
EwQFMAMBAf8wCwYDVR0PBAQDAgMAGA0GCSqGSIb3DQEBCwUAA4IBAQA7JlCCmW+s
EDCN6CXFxvtSQ4tdYBAd/a7Bnl+EmtYcatGrSF4xMOtK6Q7um/uflP76qPJCb54n
Yy92gnXONilOkHMCB9BqFPtZsU3aIFfrHu4ytCD0bbGF3sPBWek8fSYZk1TnGcZ6
l/h3esll5Rwsm76AH7zL8nDT1EZzUU1bF0KY66NDLnL1sA9IXZPB4WexV78sEG38
yDgjQ8YtIaTr+xEGHoi8D0l3+BgpalJ9HvuJOiyL18nIal1/ePWnl/iW2WtiO8wN
jrk8LnBJBOhh2O0OwUkrasagP1abgNtVxSEqmHFsx0KgdYqAungv5wgy/S3MkKXK
zowiVjLEehZe
-----END CERTIFICATE-----

</ca>


reneg-sec 0


cert /Users/prashant/foldert/easy-rsa/easyrsa3/aws_acm/client1.domain.tld.crt
key /Users/prashant/folder/easy-rsa/easyrsa3/aws_acm/client1.domain.tld.key
```
