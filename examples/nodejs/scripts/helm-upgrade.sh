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


helm upgrade --install $applicationName-$env ./helm/$applicationName --values=./helm/$applicationName/values.$env.yaml --set image.tag=latest,image.repository=$awsAccountId.dkr.ecr.$region.amazonaws.com/$applicationName-$env --set region=$region --debug --wait --force