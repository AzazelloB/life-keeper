package main

import "core:mem"

import sdl "vendor:sdl2"

Anchor :: enum {
  TOP_LEFT,
  TOP_CENTER,
  TOP_RIGHT,
  RIGHT_CENTER,
  RIGHT_BOTTOM,
  BOTTOM_CENTER,
  BOTTOM_LEFT,
  LEFT_CENTER,
  CENTER,
}

Percentage :: f16
Pixel :: u16

Padding :: struct {
  top : Pixel,
  right : Pixel,
  bottom : Pixel,
  left : Pixel,
}

Color :: sdl.Color

Component :: union { List, Button, Text }

Element :: union {
  Window,
  Widget,
  List,
  Button,
  Text,
}

Text :: struct {
  text : string,
  color : Color,
}

Button :: struct {
  callback : proc(),
  padding : Padding,
  color : Color,
  animation_progress : f16,
  component : union { List, Text },
}

List :: struct {
  type : enum { HORIZONTAL, VERTICAL },
  // TODO: probably should be on widget
  padding : Padding,
  space : Pixel,
  color : Color,
  components : [dynamic]Component,
}

Widget :: struct {
  width : Percentage,
  height : Percentage,

  max_width : Pixel,
  max_height : Pixel,

  anchor : Anchor,

  component : Component,
}

Window :: struct {
  bounds : sdl.Rect,
  widgets : [dynamic]Widget,
}

get_layout :: proc(app : ^App, layout_allocator : mem.Allocator) -> Window {
  context.allocator = layout_allocator

  return Window {
    bounds = { 0, 0, app.window_width, app.window_height },
    widgets = {
      {
        max_width = 200,
        // width = .3,
        height = 1,
        anchor = .LEFT_CENTER,
        component = List {
          type = .VERTICAL,
          padding = { 15, 0, 15, 0 },
          space = 5,
          color = { 200, 140, 0, 255 },
          components = {
            Button {
              component = Text { "Button", { 255, 255, 255, 255 } }
            },
            // Button {
            //   component = Container {
            //     components = {
            //       Text { ">", { 255, 255, 255, 255 } },
            //       Text { "Click", { 255, 255, 255, 255 } },
            //     }
            //   }
            // },
            // Button {},
          }
        }
      },
      // Widget {
      //   width = 1,
      //   height = 1,
      //   anchor = .RIGHT_CENTER,
      //   component = Text { "Not Implemented", { 255, 255, 255, 255 } },
      // },
    },
  }
}
