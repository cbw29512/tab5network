#include <Arduino.h>
#include <M5Unified.h>
#include "app_state.hpp"
#include "screens.hpp"

namespace {
pocket::Controller controller;
}
void setup() {
  Serial.begin(115200);
  // M5Unified initializes the revision-appropriate display/touch hardware.
  const auto config = M5.config();
  M5.begin(config);
  M5.Display.setRotation(1);  // Landscape: 1280x720 on the target Tab5.
  if (!pocket::display_ready()) {
    Serial.println("ERROR: Tab5 display initialization did not succeed");
    return;
  }
  // Boot directly into six touchscreen controls; no previous Pocket DM face,
  // animated avatar, physical-button navigation, or blocking splash screen.
  Serial.println("INFO: Tab5 Network Test Lab touch dashboard started");
  pocket::draw_screen(controller.state());
}
void loop() {
  M5.update();
  if (pocket::display_ready()) {
    // Read release events even when getCount() has fallen to zero.
    // This matches the manufacturer M5Unified touch-click example.
    const auto touch = M5.Touch.getDetail(0);
    if (touch.wasClicked()) pocket::touch_at(controller, touch.x, touch.y);
  }
  delay(15);
}
