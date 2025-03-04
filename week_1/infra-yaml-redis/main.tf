terraform {
  required_providers {
    tencentcloud = {
      source  = "tencentcloudstack/tencentcloud"
    }
  }
}

provider "tencentcloud" {
  region     = "ap-guangzhou"    # 替换为目标区域
}

# 读取 YAML 文件
locals {
  redis_config = yamldecode(file("${path.module}/redis.yaml"))
}

# 直接指定已知的 VPC 和子网 ID
variable "vpc_id" {
  default = "vpc-btv1oguh"
}

variable "subnet_id" {
  default = "subnet-lsbju97c"
}

# 获取安全组 ID
data "tencentcloud_security_groups" "default" {
  name = local.redis_config.redis.security_group_name
}

# 创建 Redis 实例
resource "tencentcloud_redis_instance" "my_redis" {
  availability_zone = local.redis_config.redis.availability_zone
  type_id           = 2  # 实例类型，8 表示 Redis 4.0 标准版
  password          = local.redis_config.redis.password
  mem_size          = local.redis_config.redis.memory_size * 1024  # 转换为 MB
  name              = local.redis_config.redis.instance_name
  port              = 6379
  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id
  security_groups   = [data.tencentcloud_security_groups.default.security_groups.0.security_group_id]
  tags              = local.redis_config.redis.tags
}