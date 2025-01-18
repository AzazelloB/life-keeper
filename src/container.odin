package main

import sdl "vendor:sdl2"

draw_horizontal :: proc(app : ^App, container : ^Container, bounds : ^sdl.Rect) {  
  sdl.SetRenderDrawColor(
    app.renderer,
    container.color.r,
    container.color.g,
    container.color.b,
    container.color.a,
  )

  sdl.RenderFillRect(app.renderer, bounds)

  child_containter_width := bounds.w / i32(len(container.components))

  for component, i in container.components {
    bounds := sdl.Rect {
      x = child_containter_width * i32(i) + child_containter_width / 2,
      y = bounds.h / 2,
    }

    switch &c in component {
      case Button: {
        draw_button(app, &c, &bounds)
      }

      case Container: {
        panic("Not Implemented")
      }

      case Text: {
        panic("Not Implemented")
      }
    }
  }
}
