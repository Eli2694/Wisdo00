# VPC

A Virtual Private Cloud (VPC) spans all the Availability Zones (AZs) in a region and is always associated with a CIDR range (for both IPv4 and IPv6). This CIDR range defines the pool of internal network addresses available for use within the VPC.

Within a VPC, subnets are created for each specific Availability Zone. You can create multiple subnets within the same AZ to segment and organize your resources. Subnets allow you to logically isolate resources, simplify network management, and enforce security boundaries.

When a VPC is created, an associated route table is automatically generated. This route table contains the default routing rules that enable communication between the components within the VPC. This automatically created route table is known as the **main route table**.

**Our architecture distinguishes between two types of subnets: public and private.**  
- **Public subnets:** These subnets are configured to allow internet access for the resources hosted within them. A subnet is considered public when it is associated with a route table that includes a default route (0.0.0.0/0) pointing to an internet gateway.
- **Private subnets:** These subnets do not allow direct internet access because they are associated with a route table that lacks such a route. This setup helps in isolating sensitive resources from direct exposure to the internet.
