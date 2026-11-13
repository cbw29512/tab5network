#pragma once
#include <cstdint>

namespace pocket {
// Data schema v0: no network address or credential is stored at this stage.
enum class Tool : std::uint8_t { Wifi, Devices, Ping, Ports, Dns, All };
enum class Screen : std::uint8_t { Home, Details };
enum class Outcome : std::uint8_t {
  Idle, ScopeRequired, Unsupported, Running, Cancelled
};
struct State {
  Screen screen = Screen::Home;
  Tool selected = Tool::Wifi;
  Outcome outcome = Outcome::Idle;
  bool authorized_scope = false;
  std::uint32_t generation = 0;
};

// Pure state logic: no display or network side effects.
bool requires_scope(Tool tool);
const char* tool_name(Tool tool);
class Controller {
 public:
  const State& state() const { return state_; }
  bool select(Tool tool);
  void set_scope_authorized(bool approved);
  bool cancel();
  void back();
 private:
  State state_{};
};
}  // namespace pocket
