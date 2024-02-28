## Task 1 - TF setup:

**Requirements**
- EKS in Stockholm (eu-north-1)
- Single Egress IP: ensure a single IP for outbound cluster traffic
- Multi-Region, multi-environment directory structure

**Terraform directory structure**
1. modules:
  - eks: defines EKS cluster configuration:
      - Create the EKS cluster, specifying the VPC and subnets.
      - Create worker node groups associated with the VPC and subnets.
      - Ensure worker nodes use a launch configuration configured to pass the correct private subnets to ensure traffic is routed through the NAT Gateway.
    
  - nat: configures the NAT Gateway logic:
      - Allocate an Elastic IP address.
      - Create a NAT Gateway in a public subnet.
      - Update the route table for private subnets to use the NAT Gateway.
    
  - vpc: manages VPC, subnets, route tables:
      - Create VPC, public and private subnets, Internet Gateway.
      - Set up route tables to direct internet traffic from private subnets via a NAT Gateway.

2. regions (regions/eu-north-1/main.tf):
  - Each region has its own main.tf and environment-specific .tfvars files for customization.
  - Call the VPC, NAT Gateway, and EKS modules.
  - Use terraform workspace to manage production and testing environments.

3. variables.tf:
  - stores common variables used across the project - region, environment, VPC CIDR, subnet CIDRs, EKS cluster name, etc.

5. providers.tf:
  - defines the AWS provider and other required providers

**Deployment**
  - Initialize Terraform in each region directory.
  - Use terraform workspace select to choose the environment.
  - Run terraform plan and terraform apply.

## Task 2 - Dockerize apps:

### GO app
This code sets up a basic HTTP server that listens on port 80 that serves a simple response for any request to the root URL ("/"). Before starting the server, it checks if a specific file (file.p12) exists in the current directory. If the file exists, it starts the server; otherwise, it prints an error message and terminates the program.

**Build the Docker image**
Run the following command in the directory where Dockerfile and Golang application files (main.go, file.p12) are located:
```
docker build -t my-golang-app .
```

**Run the Docker container**
```
docker run -p 8080:80 -v $(pwd)/file.p12:/app/file.p12 my-golang-app
```

This command will run the Docker container and map port 8080 on host to port 80 in the container. It also mounts the file.p12 from the host to the /app directory in the container.

**Accessing the app**
Access the Golang application by navigating to http://localhost:8080 in web browser.

### PHP app
This code checks the APP_ENV environment variable and prints the contents of the config file if the environment is production. Otherwise, it returns an HTTP 500 internal server error.

**Build the Docker image**
Run the following command in the directory where Dockerfile is located:
```
docker build -t my-php-app .
```

**Run the Docker container**
```
docker run -d -p 8080:80 --env APP_ENV=prod my-php-app 
```

**Explanation**
  - Environment variable: The ENV APP_ENV=dev sets a default development environment.
  - Config setup: The RUN if [ "$APP_ENV" = "prod" ]; then mv config.prod config; fi command executes only when the APP_ENV is set to 'prod', renaming config.prod to config.
  - Production environment: The docker run command uses --env APP_ENV=prod to ensure the production config file is used.

## Task 3 - Expose applications from previous point on single load balancer so that they will be accessible on paths /api/v1/ and /api/v2/

Using Application Load Balancer (ALB) for both applications, ensuring they are accessible at /api/v1/ and /api/v2/. I've never done that in AWS console but after done some research I came up with this:

1. Create an ALB
  - Create Load Balancer and choose Application Load Balancer.

  - Target Group 1 ("php-app-tg"):
    - Name: "php-app-tg"
    - Protocol: HTTP
    - Port: The port on which  PHP application container listens (80)
    - Health Checks: -
    - Targets: Select EC2 instances running the PHP container
  
  - Target Group 2 ("go-app-tg"):
    - Name: "php-app-tg"
    - Protocol: HTTP
    - Port: The port on which  PHP application container listens (80)
    - Health Checks: -
    - Targets: Select EC2 instances running the PHP container

2. Configure ALB listener rules

  - go to Listeners tab.
  - Create the following rules in order:
```
Rule 1:
Condition: Path is /api/v1/*
Action: Forward to "php-app-tg"
Rule 2:
Condition: Path is /api/v2/*
Action: Forward to "go-app-tg"
```

3. Access Your Applications
- Get the DNS name of ALB
- Access applications using these URLs:
```
PHP app: http://<ALB_DNS_NAME>/api/v1/
Golang app: http://<ALB_DNS_NAME>/api/v2/
```

## Task 4 - Configure HPA for those two applications that you have dockerized

**Prerequisites**
  - PHP and Golang applications deployed as Kubernetes Deployments

**Create HPAs**
  - Create HPA resources for PHP application:

```
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: php-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-app-deployment  # Replace with Deployment name
  minReplicas: 2  # Minimum number of pods
  maxReplicas: 10 # Maximum number of pods
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

  - Create HPA resources for GO application:
```
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: go-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: go-app-deployment  # Replace with Deployment name
  minReplicas: 2  # Minimum number of pods
  maxReplicas: 10 # Maximum number of pods
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70 
```

Apply these using:
```
kubectl apply -f <hpa_file.yaml>
```

How it Works:
  - The Metrics Server (if not installed, we shoudl install it) collects resource usage data (CPU, memory) from pods.
  - The HPA controller periodically checks these metrics against the targets defined.
  - If a target metric is being exceeded, the HPA will instruct Kubernetes to scale the number of pods in Deployment up or down.

## Task 5 - Setup RDS Postgresql/MySQL database using Terraform

General Steps

1. Create the aws_db_instance resource.
2. Define aws_security_group resources to control traffic - restrict access to the DB only from authorized sources.
3. Set up an aws_db_subnet_group - place RDS instances in private subnets and control access for enhanced security.
4. Apply the Configuration: run terraform init, terraform plan, and terraform apply.

Considerations:
- Backup and Snapshots
- High Availability:
  - For production environments, use multi-AZ deployments with multi_az = true in aws_db_instance resource.
- Read Replicas:
  - Create read replicas for scaling read operations.
