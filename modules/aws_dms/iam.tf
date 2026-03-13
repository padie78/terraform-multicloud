# # Nota: AWS requiere nombres exactos para estos roles si es la primera vez que usas DMS
# resource "aws_iam_role" "dms_vpc_role" {
#   name = "dms-vpc-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = { Service = "dms.amazonaws.com" }
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "dms_vpc_role_attachment" {
#   role       = aws_iam_role.dms_vpc_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
# }