#!/Library/Frameworks/Python.framework/Versions/3.10/bin/python3
import ipaddress
import os 
import json

def gen_ip_prefix (base_cidr,new_prefix):
    ips = []
    for ip in base_cidr.subnets(new_prefix=new_prefix):
        ips.append(ip)
    return ips
 
  
if __name__ == "__main__": 
    base_cidr = ipaddress.IPv4Network("100.64.0.0/10")
    new_prefix = 30
    num_of_ips_cidrs = 3050

    ip_list = gen_ip_prefix(base_cidr,new_prefix)
    index = 0
    with open("ip_cidrs.txt",'w') as rng:
        for ip in ip_list:
            if index >= num_of_ips_cidrs:
                break
            rng.write(f'{ip},')
            index +=1