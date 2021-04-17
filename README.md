# Jenkins Lambda Pipeline

## Description





## Dockerfile

Dockerfile is used to build up  our own custom image with specific requirements. The Docker image builds up with base ubuntu:latestversion, This Dockerfile will install Git, Maven, Java and Aws-cli. Then we build up the image and pushed to Dockerhub using below docker commands.

`docker build -t image/jdk8-maven-awscli:1 .` 

'.' represents the Dockerfile is present in current directory and -t represents tag name.Then after building up the image we have to push to Dockerhub.Before pushing to the Dockerhub we have to login Dockerhub with your credentials in local machine where the image is build.

`docker login --username Username --password Password`

This will login to your Dockerhub and provide access to push the images we build up locally.

`docker push image/jdk8-maven-awscli:1`

Finally this will push our image to Dockerhub

## Jenkinsfile

**Scripted pipeline**

The Jenkinsfile starts with scripted pipeline having master node where it will be used to delete the job workspace which is used for the previous build.

**Declarative pipeline**

After using the scripted pipeline we moved to declarative pipeline.Where we are defining some environment variables which are to be used in the pipeline.The variables we defined based on our requirement are `folderpath, JsonContent, buildType, Test, sample, sample1, sample2, value, gitbranch, gitbranch1, function_name, profile1`.Each variable has its own specific task to be performed under the stages of pipeline.After defining the variables we start our pipeline code

**Agent Section**

Though it's clearly mentioned our pipeline needs to be run in docker we making agent as docker and image used here is which we previously builded up and pushed to our Dockerhub (i.e; image/jdk8-maven-awscli:1).

**Options**

Here we are using only one options it is,

timestamps` : This will be helpfull to display timestamps for every line of console ouput`

**Parameters Section**

After the options section we then moved to paramters section which are to be passed by the user who is running the job.These parameters will be helpful to find the git repository and the the groovy file where the lambda function has its own configuration and also the response files used for lambda-invoke.Parameters we need for this job are 

`Lambda_Function_Name` : User needs to give the function name 

`LambdaDeployment` :

`Environment` : The user also needs to specify the environment whether it could be `NonProd` or `Prod`

`Approver_Email` : This parameter is only used for approval whenever the user needs to copy file to `Prod`

`Git_Repo_Url` : User needs to give the github repository url where the configuration files are present

`Git_Branch` : After passing the repo url user must have to pass the gitbranch because the github will have multiple branches 

`Git_Token` : For accessing the github using jenkins you must need to provide the password or authorized token

`AWS_CredentialsId` : Here we need to pass aws credentials to access aws using jenkins


**Environment Variables**

In this section we will store the credentials or tokens in encrypted form. Mainly we are passing git token which will be encrypted  by not seeing them in the console output.And we are also defining the "Git_Branch" and "LambdaDeployment" by calling it from parameters


**Stages**

**Git Checkout**

In this stage first we are running a bash script file (i.e; lambda-paramters-error-catch.sh) which is used to check the parameters given by the user are valid or invalid.Each parameter passed by the user will be checked by using `if` conditions in this script file.And we are running this script file in a `try catch block` where try block will run the script file.If there are any errors in the try block then catch block will catch those errors and it will display the error messsage (i.e; WRONG INPUT OR NULL INPUT PASSED IN THE PARAMETERS PLEASE VALIDATE) in the console output.

After checking the parameters passed by the user then we proced to git clone where our configuration files are present.This process is also done by using another bash script file (i.e; folder_script.sh)First we are passing some command line arguments to the script file (i.e; Git_Repo_Url, Git_Branch, GitToken, $WORKSPACE). $WORKSPACE is the jenkins workspace path where the jenkins job is running.The procedure we followed in the script file is first calling the command line arguments to specific variables and by following some cut commands we picked the repo name from the git repo url and also the branch (specifically when the branch name contains '/' EX:test/test1/test2),Then we created two directories using `mkdir` command (directories created are testing and subset) and after creating the directories we copied testing directory to subset directory and then `cd` to 'subset'.After changing to subset directory we moved to git clone process using the command 

`git clone https://$GitToken@$Git_Url`

This will clone the repository and all cloned files will be created under repo named folder in subset folder present in jenkins workspace.After the cloning process we again back to workspace and copy the cloned folder to another folder which is named as the git branch name (i.e; $Git_Branch in bash file) and finally moved to that folder and trying to do checkout process to know whether we are in the exact path or not

`git checkout $Git_Branch`

This will checkout the gitbranch and at last we are cross checking by running `ls -lrt` command.

Then we are extracting the repo name and branch name by using `readFile` from the files where we previously passed the names to the files.And assinging the repo name and the branch name to specific variables and also we re using `trim()` which is used to delete the empty spaces in the variable.After assinging the varibles then we are checking the environment paramter whether it could be `NonProd` or `Prod` for extracting the configuration files.If the environment is `NonProd` then we have to pick configuration file which belongs to `NonProd`,the same could be followed if the environment is `Prod`.After checking the environment then we have to load the configuration file for extracting the env variables present in the file.

**Maven Build/JUNIT Testing**























