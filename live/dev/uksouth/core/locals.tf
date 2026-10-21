locals {
  location    = "UK South"
  name_suffix = "uks-dev"

  tags = {
    owner   = "kenneth"
    purpose = "application infrastructure"
    chapter = "J02"
  }

  # Address plan. 10.20.0.0/16 is the AWS estate's payments-dev VPC; no overlap, so the
  # two can be joined by VPN later. Rules reference these, not retyped CIDRs.
  address_space = ["10.30.0.0/16"]
  subnet_cidrs = {
    app = ["10.30.1.0/24"] # workloads (VM with managed identity)
    pe  = ["10.30.2.0/24"] # private endpoints only (Key Vault)
  }
}
