package main

import "core:strings"

import sdl "vendor:sdl2"
import ttf "vendor:sdl2/ttf"

Text1 :: struct {
  texture : ^sdl.Texture,
  bounds : sdl.Rect,
}

create_text :: proc(app : ^App, text : string, size : f32 = 1) -> Text1 {
  ctext := strings.clone_to_cstring(text, context.temp_allocator)
  surface := ttf.RenderUTF8_Blended(app.font, ctext, { 255, 255, 255, 255 })
  defer sdl.FreeSurface(surface)

  texture := sdl.CreateTextureFromSurface(app.renderer, surface)

  bounds := sdl.Rect {}
  ttf.SizeUTF8(app.font, ctext, &bounds.w, &bounds.h)

  bounds.w = i32(f32(bounds.w) * size)
  bounds.h = i32(f32(bounds.h) * size)

  return {
    texture,
    bounds,
  }
}
