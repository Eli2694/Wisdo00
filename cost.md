**Load Balancer:** An Application Load Balancer has an hourly cost (~$0.0225/hour, about $16/month) plus a small per-GB or per-request charge. If our site has heavy traffic, the LCU (Load Balancer Capacity Unit) charges could add perhaps another $10–20/month.

**CloudFront CDN:** CloudFront pricing is based on data transfer out and number of requests. The **good news** is that AWS free tier includes 1 TB of data transfer out via CloudFront for the first year. Beyond that, data transfer from CloudFront is around $0.085 per GB (in North America, tiered pricing might lower it as volume grows). If your site serves 100 GB/month through CloudFront, that’s about $8.5. If it serves 1 TB (1024 GB), that’s about $87. 

**NAT Gateway:** Each NAT Gateway costs ~$0.045/hour (around $32/month) **each**, plus $0.05 per GB processed. If we have one per AZ (for redundancy), that doubles it. NAT costs can surprisingly become significant if the app downloads or transfers a lot of data out. For moderate use (say 100 GB out to internet via NAT per month), that’s an additional $5.

**ECS / Fargate** Fargate charges per vCPU/hour and per GB/hour of memory used. Assuming a moderate task size (e.g., 1 vCPU and 2 GB memory per task): vCPU: $0.04048/hour - > $43.2/month.
- Small tasks (~0.25 vCPU, 512 MB): ~$12/month each
- Larger tasks (e.g., 2 vCPU, 4 GB RAM): ~$90/month each

**AWS WAF** 
- Web ACL (Access Control List): $5 per Web ACL/month, 
- Rules: $1 per rule/month (managed rules or custom),
- Requests: $0.60 per million requests

**AWS Shield (Standard and Advanced):**
- AWS Shield Standard: Automatically included (free), provides basic DDoS protection for CloudFront and API Gateway.
- AWS Shield Advanced (optional): $3,000/month. Advanced is rarely necessary unless dealing with high-risk, mission-critical apps.