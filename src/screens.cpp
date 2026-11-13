#include <M5Unified.h>
#include "screens.hpp"
#include "touch_layout.hpp"

namespace pocket {
namespace {
constexpr std::uint32_t kBg = 0x101925;
constexpr std::uint32_t kPanel = 0x21374c;
constexpr std::uint32_t kAccent = 0x62d7ed;
constexpr std::uint32_t kText = 0xf4f8fc;
constexpr std::uint32_t kMuted = 0xb3c4d5;

void title(const char* subtitle) {
  const int w = M5.Display.width();
  M5.Display.setTextDatum(middle_center);
  M5.Display.setTextSize(3);
  M5.Display.setTextColor(kText);
  M5.Display.drawString("TAB5 NETWORK TEST LAB", w / 2, 52);
  M5.Display.setTextSize(2);
  M5.Display.setTextColor(kAccent);
  M5.Display.drawString(subtitle, w / 2, 108);
}
void home() {
  const int w = M5.Display.width(), h = M5.Display.height();
  title("TOUCH A DIAGNOSTIC");
  for (int i = 0; i < 6; ++i) {
    const Rect r = home_slot(i, w, h);
    M5.Display.fillRoundRect(r.x, r.y, r.width, r.height, 18, kPanel);
    M5.Display.drawRoundRect(r.x, r.y, r.width, r.height, 18, kAccent);
    M5.Display.setTextColor(kText);
    M5.Display.setTextSize(3);
    M5.Display.drawString(tool_name(static_cast<Tool>(i)),
                          r.x + r.width / 2, r.y + r.height / 2);
  }
  M5.Display.setTextColor(kMuted);
  M5.Display.setTextSize(2);
  M5.Display.drawString("LAB PREVIEW - NETWORK PROBES DISABLED",
                        w / 2, h - 52);
}
void details(const State& state) {
  const int w = M5.Display.width(), h = M5.Display.height();
  title(tool_name(state.selected));
  M5.Display.setTextSize(3);
  M5.Display.setTextColor(kText);
  if (state.outcome == Outcome::ScopeRequired) {
    M5.Display.drawString("AUTHORIZED TARGET REQUIRED", w / 2, h / 2 - 56);
    M5.Display.setTextSize(2);
    M5.Display.drawString("Host testing is locked until target approval exists.",
                          w / 2, h / 2);
  } else {
    M5.Display.drawString("TEST BACKEND NOT INSTALLED", w / 2, h / 2 - 56);
    M5.Display.setTextSize(2);
    M5.Display.drawString("Hardware driver integration is pending.",
                          w / 2, h / 2);
  }
  M5.Display.setTextSize(2);
  M5.Display.setTextColor(kAccent);
  M5.Display.drawString("NO NETWORK PACKETS WERE SENT", w / 2, h / 2 + 64);
  const Rect b = back_button(w, h);
  M5.Display.fillRoundRect(b.x, b.y, b.width, b.height, 14, kPanel);
  M5.Display.drawRoundRect(b.x, b.y, b.width, b.height, 14, kAccent);
  M5.Display.setTextColor(kText);
  M5.Display.drawString("BACK TO HOME", b.x + b.width / 2, b.y + b.height / 2);
}
}  // namespace

bool display_ready() {
  return M5.Display.width() >= 640 && M5.Display.height() >= 400;
}
void draw_screen(const State& state) {
  if (!display_ready()) {
    Serial.println("ERROR: display size invalid; drawing refused");
    return;
  }
  M5.Display.fillScreen(kBg);
  if (state.screen == Screen::Home) home();
  else details(state);
}
void touch_at(Controller& controller, int x, int y) {
  if (!display_ready()) {
    Serial.println("ERROR: touch ignored because display is not ready");
    return;
  }
  const State before = controller.state();
  const int w = M5.Display.width(), h = M5.Display.height();
  if (before.screen == Screen::Home) {
    const int index = home_hit(x, y, w, h);
    if (index < 0) return;
    if (!controller.select(static_cast<Tool>(index))) {
      Serial.println("WARN: invalid or busy tool selection");
      return;
    }
    Serial.printf("INFO: selected %s, outcome=%u\n",
                  tool_name(controller.state().selected),
                  static_cast<unsigned>(controller.state().outcome));
  } else if (inside(back_button(w, h), x, y)) {
    controller.back();
  } else return;
  draw_screen(controller.state());
}
}  // namespace pocket
