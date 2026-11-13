#include "app_state.hpp"

namespace pocket {
bool requires_scope(Tool tool) {
  return tool != Tool::Wifi;
}
const char* tool_name(Tool tool) {
  switch (tool) {
    case Tool::Wifi: return "WI-FI SCAN";
    case Tool::Devices: return "DEVICES";
    case Tool::Ping: return "PING TEST";
    case Tool::Ports: return "PORT TEST";
    case Tool::Dns: return "DNS TEST";
    case Tool::All: return "RUN ALL";
    default: return "INVALID TOOL";
  }
}
bool Controller::select(Tool tool) {
  // Reject invalid/corrupted selections instead of displaying a false pass.
  if (static_cast<unsigned>(tool) > static_cast<unsigned>(Tool::All)) return false;
  if (state_.outcome == Outcome::Running) return false;
  ++state_.generation;
  state_.selected = tool;
  state_.screen = Screen::Details;
  // No host probe is possible without a reviewed, explicit authorization.
  if (requires_scope(tool) && !state_.authorized_scope) {
    state_.outcome = Outcome::ScopeRequired;
  } else {
    // Fail closed. Real driver adapters are NOT included in this milestone.
    state_.outcome = Outcome::Unsupported;
  }
  return true;
}
void Controller::set_scope_authorized(bool approved) {
  // No UI calls this yet. Later approval must be bound to a specific target.
  state_.authorized_scope = approved;
  ++state_.generation;
}
bool Controller::cancel() {
  if (state_.outcome != Outcome::Running) return false;
  ++state_.generation;  // Invalidates any eventual stale worker reply.
  state_.outcome = Outcome::Cancelled;
  return true;
}
void Controller::back() {
  if (state_.outcome == Outcome::Running) return;
  state_.screen = Screen::Home;
  state_.outcome = Outcome::Idle;
}
}  // namespace pocket
