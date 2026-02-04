# Network Architecture

This module defines the **network foundation** of the platform.
It is responsible for creating a secure, scalable, and production-ready
AWS networking layout used by EKS and all future workloads.

The module is intentionally minimal, explicit, and aligned with
AWS best practices for Kubernetes platforms.

---

## Goals

- Provide a stable networking baseline for EKS
- Support multi-AZ deployments
- Enforce clear separation between public and private traffic
- Enable secure outbound access for private workloads
- Be reproducible, auditable, and environment-aware

---

## Core Design Principles

### VPC as a Dedicated Platform Boundary

A dedicated VPC is created per environment.
This VPC acts as the **security and networking boundary** for the entire platform.

Key properties:
- No shared VPC between unrelated workloads
- Explicit CIDR ranges per environment
- DNS support enabled (required for Kubernetes)

---

### Public vs Private Subnets

The network is split into two subnet types:

#### Public Subnets
- Have direct route to the Internet Gateway
- Used for:
    - NAT Gateways
    - Load Balancers (ALB / NLB)
- Do **not** host application workloads

#### Private Subnets
- No direct internet access
- Used for:
    - EKS worker nodes
    - Application workloads
- Outbound access is provided via NAT Gateways

This separation ensures:
- minimal public attack surface
- controlled egress traffic
- alignment with AWS Well-Architected Framework

---

### Multi-AZ by Design

The module supports multiple Availability Zones.

Key ideas:
- AZs are discovered dynamically via AWS API
- The number of AZs is environment-dependent
- Subnet CIDR blocks are explicitly aligned with AZ order

This allows:
- cost-efficient dev environments
- high-availability production environments
- deterministic subnet placement

---

## Routing Model

### Internet Gateway

- A single Internet Gateway is attached to the VPC
- Used exclusively by public subnets

Purpose:
- Provide inbound and outbound internet access where required

---

### NAT Gateways

- One NAT Gateway per public subnet (per AZ)
- Each NAT Gateway has its own Elastic IP

Why per-AZ NAT:
- Avoid cross-AZ traffic
- Improve availability
- Align with AWS recommendations

---

### Route Tables

#### Public Route Table
- Associated with public subnets
- Default route (`0.0.0.0/0`) → Internet Gateway

#### Private Route Tables
- One route table per private subnet
- Default route (`0.0.0.0/0`) → NAT Gateway in the same AZ

This ensures:
- private workloads can reach the internet
- inbound traffic to private subnets is blocked
- AZ-local routing

---

## Data & Computed Configuration

### Availability Zones Discovery

The module dynamically queries available AZs
instead of hardcoding them.

This allows:
- region portability
- resilience to AWS AZ naming differences
- cleaner configuration

---

### Locals as a Computation Layer

All derived values (AZ lists, subnet maps, routing associations)
are computed in `locals.tf`.

This keeps:
- input variables simple
- resource blocks readable
- logic centralized and testable

Locals are used to:
- map AZs to CIDR blocks
- normalize lists into maps
- drive `for_each` loops deterministically

---

## File Responsibilities

| File | Responsibility |
|----|----------------|
| `vpc.tf` | VPC definition and core settings |
| `subnets.tf` | Public and private subnet creation |
| `routes.tf` | Internet Gateway, NAT Gateways, and route tables |
| `data.tf` | AWS data sources (Availability Zones) |
| `locals.tf` | All computed logic and normalization |
| `variables.tf` | Explicit input contract |
| `outputs.tf` | Exposed network identifiers |

---

## What This Module Does NOT Do

This module intentionally does **not**:
- Create security groups
- Create EKS resources
- Attach IAM roles
- Define application networking rules

Those concerns are handled by:
- Security module
- EKS module
- Application-level configuration

---

## Summary

This module establishes the **networking backbone** of the platform.

It provides:
- deterministic subnet layout
- secure routing
- multi-AZ readiness
- clean separation of concerns

All higher-level platform components
(EKS, IAM, applications, AI workloads)
are built **on top of this foundation**.
