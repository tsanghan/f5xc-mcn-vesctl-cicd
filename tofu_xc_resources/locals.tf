locals {
  name                      = var.name
  namespace                 = var.name
  site_name                 = "${var.name}-vpc"
  origin_pool_virtual_site  = "${var.name}-vsite"
  aws_region                = var.aws_region
  ssh_pub_key               = var.ssh_pub_key
  aws_vpc_cidr              = var.aws_vpc_cidr
  aws_az                    = var.aws_az
  outside_subnet_cidr_block = var.outside_subnet_cidr_block
  ## Load Balancer
  http_port              = var.http_port
  loadbalancer_algorithm = var.loadbalancer_algorithm
  domains                = "${var.name}.${var.xc_base_domain}"
  routes = [
    {
      prefix           = "/api/inventory"
      origin_pool_name = "${var.name}-inventory-pool"
    },
    {
      prefix           = "/api/recommendations"
      origin_pool_name = "${var.name}-recommendations-pool"
    },
    {
      prefix           = "/images"
      origin_pool_name = "${var.name}-api-pool"
    },
    {
      prefix           = "/api"
      origin_pool_name = "${var.name}-api-pool"
    },
    {
      prefix           = "/"
      origin_pool_name = "${var.name}-spa-pool"
    },
  ]
  ## origin pools
  origin_pools = {
    api = {
      origin_pool_name  = "${var.name}-api-pool"
      origin_pool_port  = 8000
      service_name      = "api.${var.name}"
      health_check_name = "${var.name}-api-hc"
      health_check_path = "/api-documentation/"
    }
    recommendations = {
      origin_pool_name  = "${var.name}-recommendations-pool"
      origin_pool_port  = 8001
      service_name      = "recommendations.${var.name}"
      health_check_name = "${var.name}-recommendations-hc"
      health_check_path = "/api/recommendations"
    }
    inventory = {
      origin_pool_name  = "${var.name}-inventory-pool"
      origin_pool_port  = 8002
      service_name      = "inventory.${var.name}"
      health_check_name = "${var.name}-inventory-hc"
      health_check_path = "/api/inventory"
    }
    spa = {
      origin_pool_name  = "${var.name}-spa-pool"
      origin_pool_port  = 8080
      service_name      = "spa.${var.name}"
      health_check_name = "${var.name}-spa-hc"
      health_check_path = "/"
    }
  }
  ## Health check
  health_check = var.health_check
  #   health_check = {
  #     threshold           = 3
  #     interval            = 15
  #     timeout             = 3
  #     unhealthy_threshold = 1
  #     jitter_percent      = 30
  #   }
}