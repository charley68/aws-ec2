
load_balancer_ingress = [{ protocol="tcp", 
              from_port = 80, 
              to_port=80, 
              cidr_blocks = ["0.0.0.0/0"]}]

project_name = "SteveEC2-Project2"

private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
azs = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
