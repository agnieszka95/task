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

2) regions: holds region-specific TF configurations
Each region has its own main.tf and environment-specific .tfvars files for customization.
Call the VPC, NAT Gateway, and EKS modules.
Use terraform workspace to manage production and testing environments.

3) variables.tf:
   stores common variables used across the project - region, environment, VPC CIDR, subnet CIDRs, EKS cluster name, etc.

5) providers.tf:
   defines the AWS provider and other required providers

Region Configuration (regions/eu-north-1/main.tf)

**Deployment**
Initialize Terraform in each region directory.
Use terraform workspace select to choose the environment.
Run terraform plan and terraform apply.

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
Environment variable: The ENV APP_ENV=dev sets a default development environment.
Config setup: The RUN if [ "$APP_ENV" = "prod" ]; then mv config.prod config; fi command executes only when the APP_ENV is set to 'prod', renaming config.prod to config.
Production environment: The docker run command uses --env APP_ENV=prod to ensure the production config file is used.
