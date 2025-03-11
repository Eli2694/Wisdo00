https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-vpc-origins.html

You can use CloudFront to deliver content from applications that are hosted in your virtual private cloud (VPC) private subnets. You can use Application Load Balancers (ALBs), Network Load Balancers (NLBs), and EC2 instances in private subnets as VPC origins.

Here are some reasons why you might want to use VPC origins:

Security – VPC origins is designed to enhance the security posture of your application by placing your load balancers and EC2 instances in private subnets, making CloudFront the single point of entry. User requests go from CloudFront to the VPC origins over a private, secure connection, providing additional security for your applications.

Management – VPC origins reduces the operational overhead required for secure connectivity between CloudFront and origins. You can move your origins to private subnets with no public access, and you don’t have to implement access control lists (ACLs) or other mechanisms to restrict access to your origins. This way, you don't have to invest in undifferentiated development work to secure your web applications with CloudFront.

Scalability and performance – VPC origins helps you to secure your web applications, freeing up time to focus on growing your critical business applications while improving security and maintaining high-performance and global scalability with CloudFront. VPC origins streamlines security management and reduces operational complexity so that you can use CloudFront as the single point of entry for your applications.

**Prerequisites:**

Before you create a VPC origin for your CloudFront distribution, you must complete the following:

Create a virtual private cloud (VPC) on Amazon VPC.

Your VPC must be in the same AWS account as your CloudFront distribution.

Your VPC must be in one of the AWS Regions that are supported for VPC origins. (https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-vpc-origins.html)

For information about creating a VPC, see Create a VPC plus other VPC resources in the Amazon VPC User Guide.

Include the following in your VPC:

Internet gateway – Required so that your VPC can receive traffic from the internet. The internet gateway is not used for routing traffic to origins inside the subnet, and you don’t need to update the routing policies.

Private subnet with at least one available IPv4 address – **CloudFront routes to your subnet by using an elastic network interface (ENI) that CloudFront creates after your define your private origin CloudFront resource.** You must have at least one available IPv4 address in your private subnet so that the ENI creation process can succeed. The IPv4 address can be private, and there is no additional cost for it.