functions_name=$1
S3_Bucket_Name=$2
S3_Key_Name=$3
AWS_Access_Key_ID=$4
Aws_Secret_Key=$5

export AWS_ACCESS_KEY_ID=$AWS_Access_Key_ID
export AWS_SECRET_ACCESS_KEY=$Aws_Secret_Key
export AWS_DEFAULT_REGION=us-east-1

a=`aws lambda list-functions --query 'Functions[*].[FunctionName]' --output text | tr '\r\n' ' '`
for i in $a
do
if [ "$functions_name" == "$i" ]; then
   aws lambda update-function-code --function-name $i  --s3-bucket $S3_Bucket_Name --s3-key $S3_Key_Name
else 
    echo "the given Lambda function name Already exist"
