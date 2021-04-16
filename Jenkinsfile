node ('master'){
	cleanWs()
}
def buildType
def folderpath
def JsonContent
def Test
def sample
def sample1
def sample2
def value
def gitbranch
def gitbranch1
def function_name
def profile1

	
pipeline {
	agent {
		docker {
			image 'image/jdk8-maven-awscli:1'
		}
	}
	options {
		timestamps()
	}
	parameters {
	                string(name: 'Lambda_Function_Name', defaultValue: '', description: '')
		      //  extendedChoice defaultValue: 'us-east-1', description: 'Select the AWS Region', descriptionPropertyValue: '', multiSelectDelimiter: ',', name: 'Aws_Region', quoteValue: false, saveJSONParameterToFile: false, type: 'PT_RADIO', value: 'us-east-1, us-east-2, us-west-1, us-west-2', visibleItemCount: 4
	                //choice(defaultValue: 'us-east-1', name: 'Aws_Region', choices: ['us-east-1', 'us-east-2', 'us-west-1', 'us-west-2'], description: 'Select the AWS Region')
			extendedChoice defaultValue: 'PostDeploymentTest', description: '', descriptionPropertyValue: ' ', multiSelectDelimiter: ',', name: 'LambdaDeployment', quoteValue: false, saveJSONParameterToFile: false, type: 'PT_RADIO', value: 'Create, UpdateCode, UpdateConfig, Delete, PostDeploymentTest, PublishVersion', visibleItemCount: 6
			extendedChoice defaultValue: 'NonProd', description: '', descriptionPropertyValue: '', multiSelectDelimiter: ',', name: 'Environment', quoteValue: false, saveJSONParameterToFile: false, type: 'PT_RADIO', value: 'Prod, NonProd-{bi-general, DevOps-', visibleItemCount: 3
		        choice(choices: ['Not Applicable', 'email@.com', 'email@.com'], description: "", name: 'Approver_Email')
		        string(name: 'Git_Repo_Url', defaultValue: '', description: '')
		        string(name: 'Git_Branch', defaultValue: '', description: '')
			//string(name: 'lambda_payload_folder', defaultValue: '', description: 'Enter the Payload folder name')
		        string(name: 'Git_Token', defaultValue: '', description: '')
		        extendedChoice defaultValue: 'Aws_NonProd-bi-general_Credentials', description: '', descriptionPropertyValue: '', multiSelectDelimiter: ',', name: 'AWS_CredentialsId', quoteValue: false, saveJSONParameterToFile: false, type: 'PT_RADIO', value: 'Aws_Prod-bi-general_Credentials, Aws_NonProd-bi-general_Credentials, Aws_DevOps-bi-general_Credentials', visibleItemCount: 3
	}
	environment {
		GitToken = credentials("${params.Git_Token}")
		GitBranch = "${params.Git_Branch}"
		LambdaDeployment = "${params.LambdaDeployment}"
	}
    stages {
	    stage("Git Checkout"){
		    steps{
			    script{
				    try {
					    sh """
					    sh $WORKSPACE/lambda/lambda-paramters-error-catch.sh "${params.LambdaDeployment}" "${params.Environment}" "${params.AWS_CredentialsId}" "${params.Lambda_Function_Name}" "${params.Approver_Email}" "${params.Git_Repo_Url}" "${params.Git_Branch}" "\$Git_Token"
					    """
				    } catch (Exception e) {
					    //print err
					    //currentBuild.result = 'FAILURE'
					    //sh 'Handle the exception!'
					    error ('**********************WRONG INPUT OR NULL INPUT PASSED IN THE PARAMETERS PLEASE VALIDATE************************')
				    }
				    sh """
				    sh $WORKSPACE/lambda/folder_script.sh "${params.Git_Repo_Url}" "\$GitToken" "${params.Git_Branch}" $WORKSPACE
				   # sh /var/lib/jenkins/Aws-credentials-test.sh
				    """
				    JsonContent = readFile "$WORKSPACE/folder.sh"
				    sample = readFile "$WORKSPACE/folder.sh"
		                    echo "$sample"
				    sample1 = sample.trim()
		                    echo "$sample"
				    sample2 = sample.trim()
				    gitbranch = readFile "$WORKSPACE/branch.sh"
				    gitbranch1 = gitbranch.trim()
				    echo "$gitbranch1"
				    if  (params.Environment == 'NonProd-') {
				            value="${params.Lambda_Function_Name}.nonprod"
					    echo "$value"
					    profile1 = "NonProd"
					    echo "$profile1"
				    }
				    if (params.Environment == 'Prod') {
				            value="${params.Lambda_Function_Name}.prod"
					    echo "$value"
					    profile1 = "Prod"
					    echo "$profile1"  
				    }
				    load "$WORKSPACE/$GitBranch/$sample1/deploy/$value"
				    function_name = "${env.Function_Name}"
				    echo "$aws_region"
			    }
		    }
	    }
	    stage("Maven Build/JUNIT Testing"){
		steps {
			script {
				if (params.LambdaDeployment == 'UpdateCode') {
					sh """
					cd $WORKSPACE/$GitBranch/$JsonContent
					ls -lrt
					pwd
					mvn clean package shade:shade
					"""
				}
				if (params.LambdaDeployment == 'Create') {
					sh """
					cd $WORKSPACE/$GitBranch/$sample
					pwd
					mvn clean package shade:shade
					"""
				}
                        }           
		}
	    }
	    stage("Approver Notification"){
		    steps{
			    echo "*********SENDING APPROVER MAIL NOTIFICATION********"
		    }
		    post {
			    always {
				    echo "Approval Needed!"
				    echo 'post->Approval Needed'
				    echo "${params.Approver_Email}"
				    script{
					    if ( "${params.Approver_Email}" == "Not Applicable" ){
						    echo "no need for approval"
					    }
					     if ( "${params.Approver_Email}" != "Not Applicable" ){
						    mail to: "${params.Approver_Email}",
							    subject: "Approval Needed for Production Deployment: Build ${env.JOB_NAME}", 
							    body: "Approval Needed for Production Deployment ${env.JOB_NAME} build no: ${env.BUILD_NUMBER}\n\nPlease click on the below link for Approval:\n ${env.BUILD_URL}\\input\n\n Git Repo : ${params.Git_Repo_Url}\n\n Branch : ${params.Git_Branch}\n\n Lambda Function Name :${params.Lambda_Function_Name}\n\n Lambda Deployment :${params.LambdaDeployment} "
					    }
				    }
			    }
		    }
	    }
	    stage("Approval"){
		    steps{
			    script{
				    if ( "${params.Environment}" == "Prod" ){
					    def USER_INPUT = input(
						    message: 'User input required -  Approval or Rejected?',
						    parameters: [
							    [$class: 'ChoiceParameterDefinition',
							     choices: ['Approve','Reject'].join('\n'),
							     name: 'Selection',
							     description: " \nGit Repo : ${params.Git_Repo_Url}\n\n Branch : ${params.Git_Branch}\n\n "]
						    ],
						    submitter: "a"
					    )
					    if( "${USER_INPUT}" == "Approve"){
						    buildType = "${params.Environment}"
						    echo "$buildType"
						    createBuilds(buildType)
					    } else {
						    error("Approver has rejected the Deployment")
					    }
				    }
				    else {
					    buildType = "${params.Environment}"
					    echo "$buildType"
					    createBuilds(buildType)
				    }	 
			    }
		    }	 
	    }
	    stage ("SonarQube Testing") {
		    steps {
			    script{
				    echo "Place holder for the code quality testing"
			    }
                    }
	    }
	    stage ("Integration Testing") {
		    steps {
			    script{
			    	    echo "Place holder for the code testing"
			    	    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${params.AWS_CredentialsId}"]]) {
					    sh """
					    export AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID
					    export AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_ACCESS_KEY
					    """
					    if (params.LambdaDeployment == 'PostDeploymentTest' || params.LambdaDeployment == 'UpdateCode') {
						    echo "Running Post Deployment Test Cases"
						  //  echo "PostDeploymentTest: ${params.LambdaDeployment}"
					    	    Test = readFile "$WORKSPACE/folder.sh"
					    	    echo "$Test"
					    	    test6 = Test.trim()	  
						    echo "$WORKSPACE/$GitBranch/$test6/deploy/$value"
					    	    load "$WORKSPACE/$GitBranch/$test6/deploy/$value"
					            sh """
					    	    sh $WORKSPACE/lambda/lambda-invoke.sh ${env.Function_Name} "${params.Git_Branch}" $test6 "${params.Environment}" $WORKSPACE "${env.Aws_Region}"
					    	    """
					    }
				    }
			    }
		    }
	    }
    }
	post{
		success {
			echo "Lambda Deployement  Success!"
		        echo 'post->success is called'
		        mail to: 'email@.com',
			subject: "Jenkins Build SUCCESSFUL: Build ${env.JOB_NAME} ${env.LambdaDeployment} $function_name", 
			body: "Build Successful ${env.JOB_NAME} build no: ${env.BUILD_NUMBER}\n\nView the log at:\n ${env.BUILD_URL}\n\nBlue Ocean:\n${env.RUN_DISPLAY_URL}"
		}
		failure {
			echo "Lambda Deployement  Failed!"
			echo 'post->Failed is called'
			mail to: 'email@.com',
			subject: "Jenkins Build FAILED: Build ${env.JOB_NAME} ${env.LambdaDeployment} $function_name", 
			body: "Build Failed ${env.JOB_NAME} build no: ${env.BUILD_NUMBER}\n\nView the log at:\n ${env.BUILD_URL}\n\nBlue Ocean:\n${env.RUN_DISPLAY_URL}"
			cleanWs()
		}
	}
}
def createBuilds(thestage){ 
    stage("Deploying on"+" "+thestage) {
	    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${params.AWS_CredentialsId}"]]) {
		    sh """
		    export AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID
		    export AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_ACCESS_KEY
		    """
		    if ( params.Environment == 'NonProd}') {
			    value="${params.Lambda_Function_Name}.nonprod"
			    value1 = "${value}"
			    profile = "NonProd"
			    echo "$value1"
			    echo "Depoying on NonProd - {bi-general-nonprod-)}"
			    echo "Copying Artifact to S3Bucket"
			    Test = readFile "$WORKSPACE/folder.sh"
			    echo "$Test"
			    test = Test.trim()
			    echo "$WORKSPACE/$GitBranch/$test/deploy/$value1"
			    load "$WORKSPACE/$GitBranch/$test/deploy/$value1"
			    echo "${env.S3_Bucket_name}"
			    //sh "ls -lrt"
			   // echo "${params.LambdaDeployment}"
		    }
		    if ( params.Environment == 'DevOps-{bi-general-devops}') {
			    echo "Depoying on bi-general-DevOps-tfs "
			    echo "Copying Artifact to S3Bucket"
			    Test = readFile "/var/lib/jenkins/folder.sh"
			    echo "$Test"
			    test1 = Test.trim()
			//    load "/var/lib/jenkins/$GitBranch/$test1/deploy/$value1"
			    //echo "${env.S3_Bucket_name}"
			    //echo "${params.Lambda_Function}"
		    }
		    if ( params.Environment == 'Prod-{bi-general}') {
		 //   	    sh """
		//	    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
		//	    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
		//	    export AWS_DEFAULT_REGION=us-east-1
		//	    """
			    value="${params.Lambda_Function_Name}.prod"
			    value1 = "$value"
			    profile = "Prod"
			    echo "Depoying on bi-general-
			    Test = readFile "$WORKSPACE/folder.sh"
			    echo "$Test"
			    test7 = Test.trim()
			    load "$WORKSPACE/$GitBranch/$test7/deploy/$value1"
			    //echo "${env.S3_Bucket_name}"
			    //echo "${params.Lambda_Function}"
		    }
		    if (params.LambdaDeployment == 'UpdateCode') {
			    echo "Updating existing Lambda Function Code"
			    echo "Update: ${params.UpdateCode}"
			    Test = readFile "$WORKSPACE/folder.sh"
			    echo "$Test"
			    test2 = Test.trim()
			    load "$WORKSPACE/$GitBranch/$test2/deploy/$value1"
			    sh """
			    sh $WORKSPACE/lambda/copyingfile.sh ${env.S3_Bucket_Name} $LambdaDeployment "${params.Git_Branch}" $test2  $WORKSPACE "${env.Aws_Region}"
			    """
			    echo "aws lambda update-function-code --function-name ${env.Function_Name} --s3-bucket ${env.S3_Bucket_Name} --s3-key ${env.S3_Key_Name} --region '${env.Aws_Region}'"
			    sh """
			    aws lambda update-function-code --function-name ${env.Function_Name} --s3-bucket ${env.S3_Bucket_Name} --s3-key ${env.S3_Key_Name} --region "${env.Aws_Region}"
			    """
			//    sh """
			  //  sh $WORKSPACE/lambda/lambda-invoke.sh ${env.Function_Name} "${params.Git_Branch}" $test2 
			    //"""
			    
		    }
		    if (params.LambdaDeployment =='UpdateConfig') {
			    sh """
			    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
		    	    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
		            export AWS_DEFAULT_REGION=us-east-1
		            """
			    echo "Updating existing Lambda Function Configuration"
			    echo "Update: ${params.UpdateConfig}"
			    Test = readFile "$WORKSPACE/folder.sh"
			    echo "$Test"
			    test3 = Test.trim()
			    load "$WORKSPACE/$GitBranch/$test3/deploy/$value1"
			    sh """
			    aws lambda update-function-configuration --function-name ${env.Function_Name} --memory-size ${env.Memory_Size} --timeout $timeout --runtime $Run_Time --region "${env.Aws_Region}"
			    """
			  //  sh "$WORKSPACE/lambda/lambda-invoke.sh ${env.Function_Name} "${params.Git_Branch}""
		    }
		    if (params.LambdaDeployment == 'Delete') {
			    echo "Deleting the Lambda Function"
			    echo "Update: ${params.Delete}"
			    Test = readFile "$WORKSPACE/folder.sh"
			    echo "$Test"
			    test4 = Test.trim()
			    load "$WORKSPACE/$GitBranch/$test4/deploy/$value1"
			    sh """
			    aws lambda delete-function --function-name ${env.Function_Name} --region "${env.Aws_Region}"
			    """
		    }
		    if (params.LambdaDeployment == 'PublishVersion') {
			    echo env.date
			    echo "${env.BUILD_DATE}"
			    echo "Updating the Lambda Function Version"
			    echo "Update: ${params.PublishVersion}"
			    Test = readFile "$WORKSPACE/folder.sh"
			    echo "$Test"
			    test8 = Test.trim()
			    load "$WORKSPACE/$GitBranch/$test8/deploy/$value1"
			    def now = new Date()
			    def present = now.format("dd/MM/yyyy")
			    echo "$present"
			    sh """
			    echo "aws lambda publish-version --function-name ${env.Function_Name} --description by-Jenkins-job-${env.BUILD_NUMBER}-on-$present --region ${env.Aws_Region}"
			    aws lambda publish-version --function-name ${env.Function_Name} --description "by Jenkins job #${env.BUILD_NUMBER} on $present" --region ${env.Aws_Region}
			    """
		    }
		    if (params.LambdaDeployment =='Create') {
			    echo "Creating New Lambda Function"
			    echo "Update: ${params.Create}"
			    Test = readFile "$WORKSPACE/folder.sh"
			    echo "$Test"
			    test5 = Test.trim()
			    load "$WORKSPACE/$GitBranch/$test5/deploy/$value1"
			    sh """
			    sh $WORKSPACE/lambda/copyingfile.sh ${env.S3_Bucket_Name} $LambdaDeployment "${params.Git_Branch}" $test5 $WORKSPACE "${env.Aws_Region}"
			   # aws configure set default.region $Aws_Region 
			    aws lambda create-function --function-name $Function_Name  --code S3Bucket=$S3_Bucket_name,S3Key=$S3_Key_Name --handler $Handler_Name --runtime $Run_Time --role $Role --memory-size $Memory_Size --timeout $timeout --region "${env.Aws_Region}"
			    """
		    }
	    }
    }
}
node {
    stage("artifacts"){
	    script {
		    if (params.LambdaDeployment == 'PostDeploymentTest' || params.LambdaDeployment == 'UpdateCode') {
			    sh """
			    sh $WORKSPACE/lambda/post-deploy-responses.sh "${params.Lambda_Function_Name}" $WORKSPACE
			    echo "cp -r $WORKSPACE/post-deploy-responses/"${params.Lambda_Function_Name}"/* /var/lib/jenkins/post-deploy-responses/"${params.Lambda_Function_Name}" "
			   # cp -r $WORKSPACE/post-deploy-responses/"${params.Lambda_Function_Name}"/* /var/lib/jenkins/post-deploy-responses/"${params.Lambda_Function_Name}"
			    """
		    }
		    cleanWs()
	    }
    }
}
