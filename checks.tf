# check blocks run after every plan and apply and emit a warning (without blocking) when an
# invariant is violated. They are the place to enforce module-wide consistency.

# The module does nothing without at least one workspace.
check "has_workspaces" {
  assert {
    condition     = length(var.log_analytics_workspaces) > 0
    error_message = "No log_analytics_workspaces were supplied, so this module creates nothing."
  }
}
