choice=$1
test=$2
sample=$3
Lambda_Function_Name=$4
Approver_Email=$5
Git_Repo_Url=$6
Git_Branch=$7
Git_Token=$8

#echo $choice
#c=`echo "$test" | sed 's/[[:space:]]//g'`
echo "$Lambda_Function_Name"

if [ -z "$Lambda_Function_Name" ]
then
        exit 1
fi

if [ -z "$Approver_Email" ]
then
        exit 1
fi

if [ -z "$Git_Repo_Url" ]
then
        exit 1
fi

if [ -z "$Git_Branch" ]
then
        exit 1
fi

if [ -z "$Git_Token" ]
then
        exit 1
fi


if [ $choice != "Create" ] && [ $choice != "UpdateCode" ] && [ $choice != "UpdateConfig" ] && [ $choice != "Delete" ] && [ $choice != "PostDeploymentTest" ] && [ $choice != "PublishVersion" ]
then
        exit 1
fi
if [ $test != "NonProd-{bi-general-nonprod}" ] && [ $test != "DevOps-{bi-general-devops}" ] && [ $test != "Prod-{bi-general-}" ]
then
        exit 1
fi
if [ $sample != "Aws_NonProd-bi-general_Credentials" ] && [ $sample != "Aws_DevOps-bi-general_Credentials" ]  && [ $sample != "Aws_Prod-bi-general_Credentials" ]
then
        exit 1
fi


