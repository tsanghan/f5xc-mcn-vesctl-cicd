resource "volterra_namespace" "my_namespace" {
  count = var.create_ves_namespace ? 1 : 0
  name  = local.namespace
}

resource "volterra_known_label_key" "volterra_known_label_key" {
  key         = "${local.name}-key"
  namespace   = "shared"
  description = "Label-Key for ${local.name}"
}

resource "volterra_known_label" "my_label" {
  key         = "${local.name}-key"
  namespace   = "shared"
  value       = "${local.name}-value"
  description = "Label for ${local.name}"

  depends_on = [volterra_known_label_key.volterra_known_label_key]
}

# resource "volterra_workload_flavor" "large_workload_flavor" {
#   name      = "${local.name}-large-flavor"
#   namespace = "shared"

#   vcpus             = 2
#   memory            = 16000
#   ephemeral_storage = 4000
# }

resource "volterra_healthcheck" "my_health_check" {
  for_each  = local.origin_pools
  name      = each.value.health_check_name
  namespace = local.namespace

  http_health_check {
    use_origin_server_name = true
    path                   = each.value.health_check_path
  }
  healthy_threshold   = local.health_check["threshold"]
  interval            = local.health_check["interval"]
  timeout             = local.health_check["timeout"]
  unhealthy_threshold = local.health_check["unhealthy_threshold"]
  jitter_percent      = local.health_check["jitter_percent"]

  depends_on = [
    time_sleep.wait_for_namespace,
  ]
}

resource "volterra_origin_pool" "my_origin_pool" {
  for_each               = local.origin_pools
  name                   = each.value.origin_pool_name
  namespace              = local.namespace
  loadbalancer_algorithm = local.loadbalancer_algorithm
  healthcheck {
    name      = volterra_healthcheck.my_health_check[each.key].name
    namespace = local.namespace
  }
  origin_servers {
    k8s_service {
      service_name = each.value.service_name
      site_locator {
        virtual_site {
          name      = local.origin_pool_virtual_site
          namespace = "shared"
        }
      }
    }
  }
  port               = each.value.origin_pool_port
  no_tls             = true
  endpoint_selection = "LOCAL_PREFERRED"

  depends_on = [
    volterra_namespace.my_namespace,
    volterra_virtual_site.my_vsite,
    volterra_healthcheck.my_health_check,
  ]
}

resource "volterra_http_loadbalancer" "my_load_balancer" {
  lifecycle {
    ignore_changes = [labels]
  }
  name      = format("%s-lb-tf", local.name)
  namespace = local.namespace
  domains   = [local.domains]
  # default_route_pools {
  #   pool {
  #     name      = var.origin_pool
  #     namespace = var.namespace
  #   }
  #   weight   = var.weight
  #   priority = var.priority
  # }
  http {
    port                 = local.http_port
    dns_volterra_managed = true
  }
  no_challenge = true
  round_robin  = true
  # multi_lb_app                    = true
  disable_rate_limit              = true
  service_policies_from_namespace = true
  disable_bot_defense             = true
  disable_waf                     = true
  user_id_client_ip               = true

  dynamic "routes" {
    for_each = local.routes
    content {
      simple_route {
        path {
          prefix = routes.value["prefix"]
        }
        origin_pools {
          pool {
            name = routes.value["origin_pool_name"]
          }
        }
        http_method = "ANY"
      }
    }
  }

  depends_on = [
    volterra_namespace.my_namespace,
    volterra_origin_pool.my_origin_pool,
  ]
}

resource "volterra_virtual_site" "my_vsite" {
  name      = "${local.name}-vsite"
  namespace = "shared"

  site_selector {
    expressions = ["${local.name}-key in (${local.name}-value)"]
  }

  site_type = "CUSTOMER_EDGE"

}

# resource "volterra_cloud_credentials" "aws_cred" {
#   name      = format("%s-cred", var.site_name)
#   namespace = "system"
#   aws_secret_key {
#     access_key = var.aws_access_key
#     secret_key {
#       blindfold_secret_info {
#         location = format("string:///%s", var.aws_secret_key_blindfold)
#       }
#     }
#   }
# }

resource "volterra_aws_vpc_site" "my_aws_vpc_site" {
  name       = local.site_name
  namespace  = "system"
  aws_region = local.aws_region
  # disk_size  = "80"
  labels = {
    "${local.name}-key" = "${local.name}-value"
  }

  default_blocked_services = true
  enable_internet_vip      = true
  direct_connect_disabled  = true
  egress_gateway_default   = true
  f5_orchestrated_routing  = true
  f5xc_security_group      = true

  ssh_key = local.ssh_pub_key

  aws_cred {
    #name      = volterra_cloud_credentials.aws_cred.name
    name      = "learnf5-aws"
    namespace = "system"
  }

  instance_type = "m5.4xlarge"

  vpc {
    new_vpc {
      name_tag     = local.site_name
      primary_ipv4 = local.aws_vpc_cidr
    }
  }

  ingress_gw {
    allowed_vip_port {
      use_http_https_port = true
    }
    aws_certified_hw = "aws-byol-voltmesh"
    az_nodes {
      aws_az_name = local.aws_az
      local_subnet {
        subnet_param {
          ipv4 = local.outside_subnet_cidr_block
        }
      }
    }
    performance_enhancement_mode {
      perf_mode_l7_enhanced = true
    }

  }
  no_worker_nodes         = true
  logs_streaming_disabled = true
}

resource "volterra_tf_params_action" "apply_aws_vpc" {
  site_name        = volterra_aws_vpc_site.my_aws_vpc_site.name
  site_kind        = "aws_vpc_site"
  action           = "apply"
  wait_for_action  = true
  ignore_on_update = true
}

resource "time_sleep" "wait_for_namespace" {
  create_duration  = "60s"
  destroy_duration = "10s"

  depends_on = [volterra_namespace.my_namespace]
}

resource "time_sleep" "wait_for_vsite" {
  create_duration  = "10s"
  destroy_duration = "60s"

  depends_on = [volterra_virtual_site.my_vsite]
}

resource "volterra_virtual_k8s" "my_vk8s" {
  name      = "${local.name}-vk8s"
  namespace = local.namespace
  vsite_refs {
    name      = "${local.name}-vsite"
    namespace = "shared"
  }

  depends_on = [
    volterra_namespace.my_namespace,
    time_sleep.wait_for_vsite
  ]
}

resource "volterra_api_credential" "my_kubeconfig" {
  created_at            = timestamp()
  name                  = "${local.name}-vk8s-api-cred"
  api_credential_type   = "KUBE_CONFIG"
  virtual_k8s_namespace = local.namespace
  virtual_k8s_name      = "${local.name}-vk8s"
  expiry_days           = 14

  depends_on = [volterra_virtual_k8s.my_vk8s]
}