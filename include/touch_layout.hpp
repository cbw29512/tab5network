#pragma once
namespace pocket {
// Layout is expressed in display pixels and shared by drawing and hit-testing.
struct Rect { int x; int y; int width; int height; };
Rect home_slot(int index, int width, int height);
int home_hit(int x, int y, int width, int height);
Rect back_button(int width, int height);
bool inside(Rect r, int x, int y);
}  // namespace pocket
