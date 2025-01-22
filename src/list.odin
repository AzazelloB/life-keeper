package main

import "core:fmt"
import sdl "vendor:sdl2"

draw_list :: proc(app : ^App, list : List, bounds : ^sdl.Rect) {  
  sdl.SetRenderDrawColor(app.renderer, expand_values(list.color))

  sdl.RenderFillRect(app.renderer, bounds)

  child_size : i32 = 0

  switch list.type {
    case .HORIZONTAL: {
      child_size = bounds.x + bounds.w / i32(len(list.components))
    }

    case .VERTICAL: {
      child_size = bounds.y + bounds.h / i32(len(list.components))
    }
  }

  for component, i in list.components {
    child_bounds : sdl.Rect

    switch list.type {
      case .HORIZONTAL: {
        child_bounds = {
          x = child_size * i32(i) + child_size / 2,
          y = bounds.y + bounds.h / 2,
        }
      }
  
      case .VERTICAL: {
        child_bounds = {
          x = bounds.x + bounds.w / 2,
          y = child_size * i32(i) + child_size / 2,
        }
      }
    }

    switch c in component {
      case Button: {
        draw_button(app, c, &child_bounds)
      }

      case List: {
        draw_list(app, c, &child_bounds)
      }

      case Text: {
        panic("Not Implemented")
      }
    }
  }
}
