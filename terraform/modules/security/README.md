# Security & IAM Architecture

This module defines the security and identity model for the platform.
It describes **who is allowed to do what in AWS**, and **from which context**.

The design follows AWS and Kubernetes best practices and is intentionally
**production-grade** and **IRSA-ready**.

---

## Goals

- Explicit and auditable IAM boundaries
- Principle of least privilege
- Clear separation of responsibilities
- Compatibility with EKS, IRSA, and AI workloads
- Declarative, scalable configuration

---

## Core Concepts

### IAM Role = Identity, not Permissions

In AWS IAM:

- **Role** answers the question: *“Who are you?”*
- **Policy** answers the question: *“What are you allowed to do?”*

A role represents a **security boundary**.
Permissions are attached via policies.

---

### Trust Policy vs Permission Policy

Each IAM role has two distinct policy types.

#### 1. Trust policy (AssumeRole policy)

Defines **who is allowed to assume the role**.

Examples:
- `eks.amazonaws.com` → AWS EKS service
- `ec2.amazonaws.com` → EC2 instances
- `oidc.eks.amazonaws.com` → Kubernetes pods via IRSA

This policy **does not grant permissions**.

#### 2. Permission policies

Define **what actions are allowed** once the role is assumed.

Typical examples:
- `AmazonEKSClusterPolicy`
- `AmazonEKSWorkerNodePolicy`
- `AmazonEBSCSIDriverPolicy`

---

## Why Roles Are Separated

Even if multiple roles use the same principal
(e.g. `eks.amazonaws.com`), they represent **different identities**.

IAM does **not** model identity by principal alone.

Identity is determined by:
- which role is assumed
- from which context
- under which conditions

---

### Separation Rationale

| Component | Reason for Separate Role |
|--------|--------------------------|
| EKS Control Plane | Managed by AWS, cluster lifecycle only |
| Worker Nodes | EC2-level permissions |
| CSI Drivers | Storage lifecycle only |
| Load Balancer Controller | ALB / NLB lifecycle |
| Application Pods | Application-specific access |

This separation:
- limits blast radius
- enables fine-grained audit
- allows IRSA
- prevents privilege escalation

---

## Role Definition Model

Roles are declared declaratively using a single variable:

```hcl
iam_roles = {
  role-name = {
    principal = "aws-service"
    policies  = [policy-arn, ...]
  }
}
