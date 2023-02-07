# Terraform range function can only do a max range of 1024.
# Therefore using this script to generate a list of range upto 2048 
# Use this to iterate over in terraform
# 
import json
# Change to change range. 2000 is the maximum allowed in avx microseg as of 6.8
total_policy = 4000
policy_list = []
for i in range(1,total_policy+1,1):
    num_str = str(i)
#    policy_list.append('\"{}\"'.format(num_str))
    policy_list.append(num_str)
    
#print(policy_list)
#print(json.dumps(policy_list))
with open("range.txt",'w') as rng:
    rng.write(json.dumps(policy_list))