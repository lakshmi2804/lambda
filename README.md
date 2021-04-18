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

`LambdaDeployment` : This paramter is used to made deployment on lambda whether it will be 'Create, UpdateCode, UpdateConfig, Delete, PostDeploymentTest, PublishVersion'

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

This stage will be executed only when user wants to do `Create` or `UpdateCode`.We have to do maven build in this particular stage based on the `pom.xml` file which has been present in the git repository.First we have to check whether the lambda deployment is "Create" or "UpdateCode" using `if` block statements.If the condition either of those values then we will do maven build based on the configuration file (i.e; pom.xml).

`mvn clean package shade:shade`

This command will install and build maven package and it will also generate some .jar files which we to upload to `s3 bucket` in further stages.

**Approver Notification**

Here we are configuring the approver mail in the post conditions.In these configuration also we are checking two conditions whether the mails needs to be sent or no need for these we are writing an if block statement (i.e; if the "${params.Approver_Email}" is Not Applicable then we don't need to sent a mail whether the "${params.Approver_Email}" is any recipient then we have to sent a mail to that recipient).


**Approval**

Approver mail or input needs to send or asked only when the job is configured to `Prod` environment,if the job is configured to `NonProd` environment then we don't need to send an email or ask for an input.Here we created an input button whether the job needs to be 'Approve' or 'Reject'.we also have to check another condition that the input is 'Reject'.If it is rejected then also we must have to abort the job by throwing an error "Approver has rejected the Deployment".If the input is 'Approve' then we must have to call the function where the lambda deployments took place.

**Prod or NonProd**

This stage depends on a function whenever the function call this stage will execute.In this stage we must have to provide the stage name as the environment name which is selected at parameters.First we have to export our aws credentials which are stored in jenkins credentials by using the below commands.

`withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${params.AWS_CredentialsId}"]])`

`export AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID`

`export AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_ACCESS_KEY`

After exporting our aws credentials then we are checking the environment whether it is `Prod` or `NonProd`.Then we are passing some echo commands for user understanding while seeing in the console output that the present build is deploying to this particular environment.And also we are exporting repo name and branch name which are being stored in script files during gitclone process.Then we have to check whether the deployment is `Create, Delete, UpdateCode, UpdateConfig, PublishVersion`.

If the deployment is `Create` then we have to create a lambda function based on the configuration files.Before creating the lambda function we have to upload `.jar` files which are created during maven build to the s3 bucket.This uploading part will be done in a script file (i.e; copyingfile.sh).Here we will check the path of the .jar files where it has been created then we will upload to s3.

`aws s3 cp $i s3://$S3_Bucket_name --region $Aws_Region`

This command will push the .jar files to our s3 bucket based on the region where our bucket has been located.After pushing to s3 bucket then we have to create the lambda fucntion based on the configuration file.First we have to load the configuration files using `load` command.Then we have to run cli commands to create.

`aws lambda create-function --function-name $Function_Name  --code S3Bucket=$S3_Bucket_name,S3Key=$S3_Key_Name --handler $Handler_Name --runtime $Run_Time --role $Role --memory-size $Memory_Size --timeout $timeout --region "${env.Aws_Region}"`

Those variable values will be exported from those configuration files.So that's why we loaded the file before creating the function.The above cli command will create lambda function.

If the lambda deployment is to do  `UpdateCode`,In this case also we have to follow the same what we have done for create.First we have to upload .jar files to s3 this uploading script is same for both create and updatecode.We are using the same script file for both the conditions the procedure is mentioned above in the "Create" condtion you can check from there.After uploading to s3 then we have to run aws cli command to update our existing lambdba function.

`aws lambda update-function-code --function-name ${env.Function_Name} --s3-bucket ${env.S3_Bucket_Name} --s3-key ${env.S3_Key_Name} --region "${env.Aws_Region}"`

This command line will help to update the existing lambda fucntion.In this step also we have to load these variables from the configuration file.Before running the cli command we have to run `load` command to load those variable values from the configuration files.

If the user need to delete the lambda function then he didn't need to push any files to s3 directly we can delete the lambda function.

`aws lambda delete-function --function-name ${env.Function_Name} --region "${env.Aws_Region}`

This command will help you to delete the lambda function by passing `Function_Name` and `Aws_Region` as arguments.

If the user wants to do `UpdateConfig` here also we dont need to upload any jar files to s3 direclty we can update configuration of the existing lambda function.This will be helpful when we have any changes in configuration file then we can update those changes to lambda function by using UpdateConfig.It can also be done with a simple cli command which is given below.

`aws lambda update-function-configuration --function-name ${env.Function_Name} --memory-size ${env.Memory_Size} --timeout $timeout --runtime $Run_Time --region "${env.Aws_Region}"`


Finally if we need to `PublishVersion` of updated lambda function then we can run the command 

`aws lambda publish-version --function-name ${env.Function_Name} --description "by Jenkins job #${env.BUILD_NUMBER} on $present" --region ${env.Aws_Region}`

Here we having another requirement that the Publishedversion of lambda description should be like present jenkins build number with date when the job build take place,For that we are using `Date()` function and we are also formatting to get only in that format like "dd/MM/yyyy" and assinging it to a variable and passing the varibale as an argument in the above command.

**SonarQube Testing**

After the function called the next stage is SonarQube Testing.As of now we are not doing any that type of testing we are just passing an simple echo command that this stage is active.

**Integration Testing**

As a part of integration testing we are doing lambda-invoke.This lambda invoke process is also written in a script file,First we are exporting aws credentials here again beacuse it is a new stage and it doesnt depend on the function so we are calling them again.After exporting we also doing the same what we did previously i.e; loading the configuration file from the git repository you can check it from the previous stages how to export aws credentials and load configuration files.Then we will run the script file by passing some command line arguments like "Function_Name, Git_Branch, test6(i.e;Git_Repo_Url name which we stored in a file during gitclone), Environment, Aws_Region".First we are copying the post-deploy folder which is present in git to our job workspace and then we are creating a response folder with the functionname to store the responses of lambda-invoke(i.e; $WORKSPACE/post-deploy-responses/$function_name).Then we are giving 777 permissions to overflow some permission issues and we are checking whether the lambda function is in `Prod` or `NonProd` then based on the environment we are greping the response files to do lambda-invoke from post-deploy folder.Then we are passing hrough a for loop where





































