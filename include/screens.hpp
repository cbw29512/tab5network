#pragma once
#include "app_state.hpp"
namespace pocket {
bool display_ready();
void draw_screen(const State& state);
void touch_at(Controller& controller, int x, int y);
}  // namespace pocket
