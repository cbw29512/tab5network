#include "touch_layout.hpp"
namespace pocket {
bool inside(Rect r, int x, int y) {
  return r.width > 0 && r.height > 0 &&
         x >= r.x && y >= r.y && x < r.x + r.width && y < r.y + r.height;
}
Rect home_slot(int index, int width, int height) {
  constexpr int margin = 32, gap = 16, top = 146, bottom = 114;
  const int bw = (width - 2 * margin - 2 * gap) / 3;
  const int bh = (height - top - bottom - gap) / 2;
  if (index < 0 || index >= 6 || bw < 60 || bh < 60) return {0, 0, 0, 0};
  return {margin + (index % 3) * (bw + gap),
          top + (index / 3) * (bh + gap), bw, bh};
}
int home_hit(int x, int y, int width, int height) {
  for (int i = 0; i < 6; ++i) {
    if (inside(home_slot(i, width, height), x, y)) return i;
  }
  return -1;
}
Rect back_button(int, int height) { return {40, height - 112, 230, 70}; }
}  // namespace pocket
