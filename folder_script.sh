#!bin/bash
Git_Repo_Url=$1
GitToken=$2
Git_Branch=$3
WORKSPACE=$4
lambda_payload_folder=$5
echo $GitToken
echo $Git_Repo_Url > file.txt
cat file.txt
b=`echo $Git_Branch | cut -d '/' -f1`
echo $b > branch.sh
Git_Url=$(cut -d "/" -f3- file.txt)
echo $Git_Url
ls -lrt
a=`echo $Git_Repo_Url | cut -d "/" -f5 | cut -d "." -f1`
echo $a > folder.sh
tr -d " /t" <folder.sh
mkdir testing
mkdir subset
cp -r testing subset
cd subset
ls -lrt
echo "git clone https://$GitToken@$Git_Url"
git clone https://$GitToken@$Git_Url
cd $WORKSPACE
#echo "mkdir -p /var/lib/jenkins/$Git_Branch"
mkdir -p $Git_Branch
#echo "cp -r /var/lib/jenkins/subset/$a /var/lib/jenkins/$Git_Branch"
cp -r $WORKSPACE/subset/$a $WORKSPACE/$Git_Branch
cd $WORKSPACE/$Git_Branch/$a
echo "git checkout $Git_Branch"
git checkout $Git_Branch
ls -lrt
