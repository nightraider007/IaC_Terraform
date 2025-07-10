# -------------------------------------------------------------
# TERRAFORM DEPLOYMENT: RBAC INHERITANCE & CONTROL Vs DATA PLANE ACCESS
# -------------------------------------------------------------
#
# ✅ CONTEXT: TERRAFORM authenticates to AZURE using a SERVICE PRINCIPAL,
# which is an APPLICATION OBJECT registered via APP REGISTRATION.
# Its credentials (CLIENT ID + CLIENT SECRET) are configured in the provider block.
#
# ✅ PROBLEM: Although the SERVICE PRINCIPAL had the CONTRIBUTOR role 
# on the KEY VAULT (inherited), it was **unable to manage secrets**.
# This is because:
#
# - CONTRIBUTOR grants CONTROL PLANE rights (e.g., creating the KEY VAULT)
# - It **does NOT** grant DATA PLANE rights (e.g., writing/reading secrets)
#
# ✅ INITIAL WORKAROUND:
# The SERVICE PRINCIPAL was assigned:
# - KEY VAULT SECRETS OFFICER (can create/update/delete secrets)
# - KEY VAULT SECRETS USER (can read/list secrets)
#
# These roles were assigned **directly on the KEY VAULT**, which worked...
# ❗ UNTIL THE KEY VAULT WAS DESTROYED AND RECREATED.
# At that point, all manually applied role assignments were lost.
#
# ✅ ROOT CAUSE:
# - ROLE ASSIGNMENTS on resources are **ephemeral** when applied to child resources
# - TERRAFORM destroy-recreate cycles do **not preserve RBAC bindings** on deleted objects
#
# ✅ ROBUST SOLUTION:
# - Grant the SERVICE PRINCIPAL the **same roles** (KEY VAULT SECRETS OFFICER + USER)
#   **AT THE RESOURCE GROUP LEVEL**
# - Also assign **USER ACCESS ADMINISTRATOR** (or OWNER) at the RESOURCE GROUP level
#
# ✅ OUTCOME:
# - ROLE ASSIGNMENTS are inherited automatically by the KEY VAULT on creation
# - RBAC-BASED SECRET MANAGEMENT is consistent and stable
# - Avoids reassigning roles after each destroy/apply
#
# -----------------------
# TL;DR - LESSONS LEARNED
# -----------------------
# 🔹 CONTRIBUTOR is not enough for KEY VAULT SECRET management
# 🔹 Assign DATA PLANE roles at a higher scope (RESOURCE GROUP) for inheritance
# 🔹 Assign USER ACCESS ADMINISTRATOR to allow role assignments via TERRAFORM
# 🔹 Use ENABLE_RBAC_AUTHORIZATION = TRUE to ensure RBAC is respected
# 🔹 Never rely on resource-level role assignments for ephemeral resources
#
# ✅ RESULT: This approach makes the deployment **REPEATABLE, ROBUST, and IDIOT-PROOF**.
