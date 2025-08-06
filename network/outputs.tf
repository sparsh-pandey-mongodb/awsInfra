output "vpc_id"            { value = aws_vpc.vpc.id }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
output "sg_id"             { value = aws_security_group.india_sg.id }
output "vpc_cidr"          { value = aws_vpc.vpc.cidr_block }
output "igw_id"            { value = aws_internet_gateway.igw.id }
output "route_table_id"    { value = aws_route_table.public_rt.id }

# terraform output -json > outputs.json 