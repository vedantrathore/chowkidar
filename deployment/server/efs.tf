###################
# EFS 
###################
resource "aws_efs_file_system" "ecs_service_storage" {
  tags = {
    Name = "chowkidar-efs"
  }
}

resource "aws_efs_mount_target" "efs_mount_target" {
  count = length(var.private_subnet_ids)

  file_system_id  = aws_efs_file_system.ecs_service_storage.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [module.efs_sg.this_security_group_id]
}
