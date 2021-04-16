Function_Name=$1
WORKSPACE=$2
cd /var/lib/jenkins/post-deploy-responses
if [ -d "$Function_Name" ];
then
    echo "$Function_Name has been found"
    cp -r $WORKSPACE/post-deploy-responses/$Function_Name/* /var/lib/jenkins/post-deploy-responses/$Function_Name
else
    echo "$Function_Name has not been found"
    mkdir /var/lib/jenkins/post-deploy-responses/$Function_Name
    chown jenkins:jenkins /var/lib/jenkins/post-deploy-responses/$Function_Name
    chmod 777 /var/lib/jenkins/post-deploy-responses/$Function_Name
    cp -r $WORKSPACE/post-deploy-responses/$Function_Name/* /var/lib/jenkins/post-deploy-responses/$Function_Name    
fi
