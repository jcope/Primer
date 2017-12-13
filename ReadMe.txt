1) Attach Volumes
-> 8GB:: i-09d3b899 (Primer-Ubuntu2):/dev/sda1 
-> 50GB:: i-09d3b899 (Primer-Ubuntu2):/dev/sdf (Prime Data)

2) Connect to Host
-> ssh admin@ec2-54-165-114-97.compute-1.amazonaws.com -vvv -i PrimerKey.pem

3) Mount Data Volume
-> lsblk
-> sudo mount /dev/xvdf /data/