import json
import subprocess

# Read the input JSON and extract variables
input_json = json.loads(input())
namespace = input_json["NAMESPACE"]
number_pods = input_json["NUMBER_PODS"]
helm_installation_name = input_json["HELM_INSTALLATION_NAME"]
efs_id = input_json["EFS_ID"]
aws_region = input_json["AWS_REGION"]

# Create EFS access points for logs Pods
fsap_dict = {}
for counter in range(int(number_pods)):
    cmd = f'aws efs describe-access-points --region {aws_region}'
    output = subprocess.check_output(cmd, shell=True)
    output_json = json.loads(output)
    for access_point in output_json["AccessPoints"]:
        if access_point["RootDirectory"]["Path"] == f'/{namespace}/file-storage-{helm_installation_name}-sumologic-otelcol-metrics-{counter}':
            fsap_id = access_point["AccessPointId"]
            break
    else:
        cmd = f'aws efs create-access-point --file-system-id {efs_id} --posix-user Uid=1000,Gid=1000 --root-directory "Path=/{namespace}/file-storage-{helm_installation_name}-sumologic-otelcol-metrics-{counter},CreationInfo={{OwnerUid=1000,OwnerGid=1000,Permissions=777}}" --region {aws_region}'
        output = subprocess.check_output(cmd, shell=True)
        fsap_id = json.loads(output)["AccessPointId"]
    fsap_dict[f"fsap{counter}"] = fsap_id

# Output the JSON object with the values
json_obj = {"fs": fsap_dict}
print(json.dumps(fsap_dict))
