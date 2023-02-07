
# Enable Distributed Firewall Config
resource "aviatrix_distributed_firewalling_config" "dfw" {
  enable_distributed_firewalling = true
}

# Enable IntraVPC Distributed Firewall Config for all VPC
resource "aviatrix_distributed_firewalling_intra_vpc" "intraVPC_dfw" {
  count = var.enable_intraVPCdfw ? 1 : 0

  dynamic "vpcs" {
    for_each = local.az_intraVPC_vpc_info
    content {
      account_name = vpcs.value.account
      vpc_id       = vpcs.value.vpc_id
      region       = vpcs.value.region
    }
  }
}

# AVX VM based smart group with tag filter
/* resource "aviatrix_smart_group" "smart_groups_VMbased" {
  name = "aws-prod-vm"
  selector {
    match_expressions {
      type         = "vm"
      account_name = var.account_name
      #region       = "us-west-2"
      tags         = {
        role = "prod"
      }
    }
  }
}
 */
/* resource "aviatrix_app_domain" "app_domain_1" {

  name = "prod-appd"
  selector {
    match_expressions {
      type = "vm"
      tags = {
        Role = "prod"
      }
    }
  }
}

resource "aviatrix_app_domain" "app_domain_2" {
  name = "dev-appd"
  selector {
    match_expressions {
      type = "vm"
      tags = {
        Role = "dev"
      }
    }
  }
} */

# Aviatrix VPC based smart groups

/* resource "aviatrix_app_domain" "app_domain_1" {

  name = "prod-appd"
  selector {
    match_expressions {
      type         = "vpc"
      account_name = "qmar-aws-primary"
    }
  }
}

resource "aviatrix_app_domain" "app_domain_2" {
  name = "dev-appd"
  selector {
    match_expressions {
      type         = "vpc"
      account_name = "qmar-az-primary"
    }
  }
} */

# IP CIDR based smart groups

/* resource "aviatrix_app_domain" "ip_prefixes_app_domain" {
  name = "ips-appd"
  selector {

    dynamic "match_expressions" {
      for_each = toset(local.ip_cidrs)
      content {
        cidr = match_expressions.value
      }
    }


  }
 
}
*/



### Policies #### 
## Max 2K ##
/* 
resource "aviatrix_microseg_policy_list" "microseg_policy" {


  dynamic "policies" {
    for_each = toset(local.policy_list)
    content {
      name     = "rule_${policies.value}"
      action   = "PERMIT"
      priority = tonumber(policies.value)
      protocol = "TCP"
      logging  = true
      watch    = false
      src_app_domains = [
        aviatrix_app_domain.app_domain_1.uuid
      ]
      dst_app_domains = [
        aviatrix_app_domain.app_domain_2.uuid
      ]
      port_ranges {
        hi = 10000 + tonumber(policies.value)
        lo = 10000 + tonumber(policies.value)
      }
    }

  }
} */
