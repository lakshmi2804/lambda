#AWS_CONFIG_FILE="/home/jenkins/.aws/config"
#pwd
#!/usr/bin/env bash
function_name=$1

Git_Branch=$2
test=$3
environment=$4
WORKSPACE=$5
Aws_Region=$6
echo $test
echo $function_name
echo $environment
echo $Aws_Region
echo "cp -r $WORKSPACE/$Git_Branch/$test/post-deploy/$function_name $WORKSPACE/post-deploy"
cp -r $WORKSPACE/$Git_Branch/$test/post-deploy/$function_name $WORKSPACE/post-deploy
mkdir -p $WORKSPACE/post-deploy-responses/$function_name
chmod 777 $WORKSPACE/post-deploy-responses/$function_name
if [ $environment = "NonProd-{bi-general-" ]; then
    echo OK
    a=`ls $WORKSPACE/post-deploy/nonprod`
    echo $a > $WORKSPACE/file.txt
    cp $WORKSPACE/file.txt $WORKSPACE/file1.txt
    sed -i 's/Request/Response/g' $WORKSPACE/file1.txt
    VAR1=$(cat $WORKSPACE/file.txt)
    VAR2=$(cat $WORKSPACE/file1.txt)


    fun()
    {
        set $VAR2
        for i in $VAR1; do
            #echo "$i" "$1"
            echo "aws lambda invoke --function-name $function_name --payload file://$WORKSPACE/post-deploy/nonprod/$i $WORKSPACE/post-deploy-responses/$function_name/$1"
            aws lambda invoke --function-name $function_name --payload file://$WORKSPACE/post-deploy/nonprod/$i $WORKSPACE/post-deploy-responses/$function_name/$1 --region $Aws_Region
            shift
        done
    }
    fun
elif [ $environment = 'Prod-{bi-general-' ]; then
    echo OK
    a=`ls $WORKSPACE/post-deploy/prod`
    echo $a > $WORKSPACE/file.txt
    cp $WORKSPACE/file.txt $WORKSPACE/file1.txt
    sed -i 's/Request/Response/g' $WORKSPACE/file1.txt
    VAR1=$(cat $WORKSPACE/file.txt)
    VAR2=$(cat $WORKSPACE/file1.txt)


    fun()
    {
        set $VAR2
        for i in $VAR1; do
            #echo "$i" "$1"
            echo "aws lambda invoke --function-name $function_name --payload file://$WORKSPACE/post-deploy/prod/$i $WORKSPACE/post-deploy-responses/$function_name/$1"
            aws lambda invoke --function-name $function_name --payload file://$WORKSPACE/post-deploy/prod/$i $WORKSPACE/post-deploy-responses/$function_name/$1 --region $Aws_Region
            shift
        done
    }

    fun
else
    echo "No Test Cases Found"
fi

#rm -rf $WORKSPACE/file.txt $WORKSPACE/file1.txt




