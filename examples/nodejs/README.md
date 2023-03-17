## Pre-requisites
- helm
- aws cli
- kubectl
- eksctl

- ### Create eks cluster on aws
  
    ```
     eksctl create cluster -f ./examples/nodejs/aws/cluster.yaml
    ```
- ### Setup efs csi driver on aws after cluster is created  

    ```
     ./examples/nodejs/scripts/setup-efs-csi-driver.sh --clusterName=xyz --regionCode=abc --accountId=qwerty 
    ```  

- ### Create ECR repositories, an EKS cluster 
  
    ```
    ./examples/nodejs/scripts/create-ecr.sh --applicationName=eks-fargate-starter --env=qa --awsAccountId=XYZ --region=ap-south-1
    ```

- ### Create helm application
  
    ```
    ./examples/nodejs/scripts/create-helm-application.sh --applicationName=applicationName      
    ```

- ### Build and Push to ECR Cluster
    Before building the docker image and pushing to ecr update .env.local with proper values
    ```
     ./examples/nodejs/scripts/docker-build-and-push-to-ecr.sh --region=ap-south-1 --applicationName=eks-fargate-starter --env=qa --awsAccountId=XYZ
    ```

- ### Create EFS on aws for Elastisearch, Prometheus Server, Prometheus Alert Manager and Grafana
    After running below command it will create an elasctic file system and will display a table conisting  availabilty zone , so note down two different availabilty zone and  the subnets for your nodes are and note the four fileSystemId  
    ```
     ./examples/nodejs/scripts/create-efs.sh --clusterName=XYZ --regionCode=XYZ --securityGroupId=XYZ  
    ```

- ### Create mount target for Elastisearch, Prometheus Server, Prometheus Alert Manager and Grafana    
  
    ```
     ./examples/nodejs/scripts/create-mount-target.sh --elasticseachFId=XYZ --prometheusServerFId=XYZ --prometheusAlertManagerFId=XYZ --grafanaFId=XYZ
     --subnet1=XYZ --subnet2=XYZ --securityGroupId=XYZ
    ```  

- ### Create acess point for Elastisearch, Prometheus Server, Prometheus Alert Manager and Grafana    
  
    ```
     ./examples/nodejs/scripts/create-access-point.sh --elasticseachFId=XYZ --prometheusServerFId=XYZ --prometheusAlertManagerFId=XYZ --grafanaFId=XYZ
    ```

- ### Install ws-observability-chart
    Before installing the chart modify the values.yaml file with appropriate values  for efs file system and access point id for elasticsearch, prometheus-server, prometheus-alertmanager and grafana and then run the below command

    ```
     helm install eks ./ws-observability/ws-observability-chart -f ./values.yaml
    ```
- ### Install the backend on the eks cluster

     ```
     ./examples/nodejs/scripts/helm-upgrade.sh --region=XYZ --applicationName=XYZ --env=qa --awsAccountId=XYZ
     ```            
  