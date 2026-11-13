#include <cassert>
#include <cstdint>
#include <iostream>
#include "app_state.hpp"
#include "touch_layout.hpp"

int main() {
  using namespace pocket;
  Controller c;
  assert(c.state().screen == Screen::Home);
  assert(c.state().outcome == Outcome::Idle);
  assert(!c.state().authorized_scope);
  assert(!requires_scope(Tool::Wifi));
  assert(requires_scope(Tool::All));
  assert(!c.select(static_cast<Tool>(255)));
  assert(c.state().screen == Screen::Home);
  assert(c.select(Tool::All));
  assert(c.state().screen == Screen::Details);
  assert(c.state().outcome == Outcome::ScopeRequired);
  assert(!c.cancel()); // Never claims to cancel an inactive network job.
  c.back();
  assert(c.state().outcome == Outcome::Idle);
  assert(c.select(Tool::Wifi));
  assert(c.state().outcome == Outcome::Unsupported);
  assert(c.state().generation > 0);
  c.back();
  c.set_scope_authorized(true); // Unit-only future state; UI has no approval.
  assert(c.select(Tool::Ping));
  assert(c.state().outcome == Outcome::Unsupported);
  const int w = 1280, h = 720;
  for (int i = 0; i < 6; ++i) {
    const Rect r = home_slot(i, w, h);
    assert(home_hit(r.x + r.width / 2, r.y + r.height / 2, w, h) == i);
  }
  assert(home_hit(0, 0, w, h) == -1);
  assert(home_hit(-1, 200, w, h) == -1);
  assert(home_hit(20, 200, 100, 100) == -1);
  assert(inside(back_button(w, h), 50, h - 100));
  std::cout << "Controller + touch hitbox tests passed\n";
  return 0;
}
