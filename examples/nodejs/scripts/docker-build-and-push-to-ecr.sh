#!/bin/bash
for ARGUMENT in "$@"
do
   K=$(echo $ARGUMENT | cut -f1 -d=)
   KEY=${K:2}
   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+3}"

   export "$KEY"="$VALUE"
done

if [ -z "$applicationName" ]
then
    echo "applicationName cannot be empty"
    exit
fi

if [ -z "$env" ]
then
    echo "env cannot be empty"
    exit
fi

if [ -z "$region" ]
then
    echo "region cannot be empty"
    exit
fi

if [ -z "$awsAccountId" ]
then
    echo "awsAccountId cannot be empty"
    exit
fi


docker build -t  $awsAccountId.dkr.ecr.$region.amazonaws.com/$applicationName-$env:latest -f ./examples/nodejs/server/Dockerfile  .

docker push $awsAccountId.dkr.ecr.$region.amazonaws.com/$applicationName-$env:latest
