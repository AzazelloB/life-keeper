package main

import sdl "vendor:sdl2"

Position :: enum {
  CENTER
}

draw_button :: proc(app : ^App, button : Button, bounds : ^sdl.Rect, position : Position = .CENTER) {
  // TODO use glyphs
  // TODO stop rendering text inside button,
  // contents of button should be handleled as any other component
  text := create_text(app, button.component.(Text).text)

  PADDING_X :: 20
  PADDING_Y :: 15

  button_bounds := sdl.Rect {
    x = bounds.x,
    y = bounds.y,
    w = text.bounds.w + PADDING_X * 2,
    h = text.bounds.h + PADDING_Y * 2,
  }
  text_bounds := sdl.Rect {
    x = bounds.x + PADDING_X,
    y = bounds.y + PADDING_Y,
    w = text.bounds.w,
    h = text.bounds.h,
  }

  switch position {
    case .CENTER: {
      button_bounds.x -= button_bounds.w / 2
      button_bounds.y -= button_bounds.h / 2
      text_bounds.x -= button_bounds.w / 2
      text_bounds.y -= button_bounds.h / 2
    }
  }
  
  mouse_pos := get_mouse_pos()

  if sdl.PointInRect(&mouse_pos, &button_bounds) {
    sdl.SetRenderDrawColor(
      app.renderer,
      button.color.r,
      button.color.g,
      button.color.b,
      u8(f32(button.color.a) * 0.25),
    )
    
    sdl.SetCursor(sdl.CreateSystemCursor(.HAND))
  } else {
    sdl.SetRenderDrawColor(app.renderer, 0, 0, 0, 0)
  }

  sdl.RenderFillRect(app.renderer, &button_bounds)
  
  sdl.SetTextureColorMod(
    text.texture,
    button.color.r,
    button.color.g,
    button.color.b,
  )

  sdl.RenderCopy(app.renderer, text.texture, nil, &text_bounds)

  if just_pressed(app, &button_bounds) {
    button.callback()

    // button.animation_progress = 1
  }

  sdl.SetRenderDrawColor(app.renderer, expand_values(button.color))

  THICKNESS :: 3

  sdl.RenderFillRect(
    app.renderer,
    &{
      button_bounds.x + button_bounds.w / 2 - i32(f16(button_bounds.w) * button.animation_progress) / 2,
      button_bounds.y + button_bounds.h - THICKNESS,
      i32(f16(button_bounds.w) * button.animation_progress),
      THICKNESS,
    },
  )
}
