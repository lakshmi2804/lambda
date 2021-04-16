S3_Bucket_Name=$1
lambda=$2
GitBranch=$3
test=$4
WORKSPACE=$5
Aws_Region=$6
echo $test
echo $GitBranch
echo $profile
test1=`echo $test`
#echo $3
#cd $workspace/lambda/target/
#cd /var/lib/jenkins/$GitBranch/target

echo $S3_Bucket_name
cd $WORKSPACE/$GitBranch/$test/target
for i in `ls *.?ar`
do
    echo $i
    echo $S3_Bucket_name
    aws s3 cp $i s3://$S3_Bucket_name --region $Aws_Region
done
#if [ $lambda = "Create" ]
#then
 #   cd $WORKSPACE/$GitBranch/$test/target
  #  for i in `ls *.?ar`
   # do
    #    echo $i
     #   aws s3 cp $i s3://$S3_Bucket_name --region $Aws_Region
    #done
#fi
