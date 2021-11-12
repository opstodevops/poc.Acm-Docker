FROM centos:centos7.7.1908

RUN yum check-update; \
    yum install -y gcc libffi-devel python-devel openssl-devel epel-release; \
    yum install -y python3-pip python-wheel; \
    yum install -y openssh-clients openssl; \
    yum install -y sshpass; \
    yum install -y git
   
RUN pip3 install --upgrade pip

RUN pip install boto; \
    pip install boto3; \
    pip install botocore; \
    pip install pywinrm; \
    pip install --upgrade awscli