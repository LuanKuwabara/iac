output "vpca" {
   value = module.vpca.vpc
}

output "cidra" {
  value = module.vpca.vpc_cidr_block
  
}

output "subspus" {
    value = module.vpca.subnet-dmz-0
}
output "sgnagios" {
  value     = module.sg_nagios.sgoutput
  sensitive = false
}
