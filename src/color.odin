package main

import sdl "vendor:sdl2"

HSLA :: struct {
  h: f32,
  s: f32,
  l: f32,
  a: f32,
}

rgba_to_hsla :: proc(color : sdl.Color) -> HSLA {
  max := f32(max(color.r, max(color.g, color.b))) / 255.0
  min := f32(min(color.r, min(color.g, color.b))) / 255.0

  h: f32
  s: f32
  l := (max + min) / 2.0

  if max == min {
    h = 0.0
    s = 0.0
  } else {
    d := max - min
    s = l > 0.5 ? d / (2.0 - max - min) : d / (max + min)

    if max == f32(color.r) / 255.0 {
      h = (f32(color.g) / 255.0 - f32(color.b) / 255.0) / d + (color.g < color.b ? 6.0 : 0.0 )
    } else if max == f32(color.g) / 255.0 {
      h = (f32(color.b) / 255.0 - f32(color.r) / 255.0) / d + 2.0
    } else {
      h = (f32(color.r) / 255.0 - f32(color.g) / 255.0) / d + 4.0
    }

    h /= 6.0
  }

  a := f32(color.a) / 255.0

  return HSLA { h, s, l, a }
}

hsla_to_rgba :: proc(hsla : HSLA) -> sdl.Color {
  r: f32
  g: f32
  b: f32

  if hsla.s == 0.0 {
    r = hsla.l
    g = hsla.l
    b = hsla.l
  } else {
    q := hsla.l < 0.5 ? hsla.l * (1.0 + hsla.s) : hsla.l + hsla.s - hsla.l * hsla.s
    p := 2.0 * hsla.l - q

    hue_to_rgb := proc(p: f32, q: f32, t: f32) -> f32 {
      t := t

      if t < 0.0 { t += 1.0 }
      if t > 1.0 { t -= 1.0 }
      if t < 1.0 / 6.0 { return p + (q - p) * 6.0 * t }
      if t < 1.0 / 2.0 { return q }
      if t < 2.0 / 3.0 { return p + (q - p) * (2.0 / 3.0 - t) * 6.0 }

      return p
    }

    r = hue_to_rgb(p, q, hsla.h + 1.0 / 3.0)
    g = hue_to_rgb(p, q, hsla.h)
    b = hue_to_rgb(p, q, hsla.h - 1.0 / 3.0)
  }

  return sdl.Color {
    r = u8(r * 255.0),
    g = u8(g * 255.0),
    b = u8(b * 255.0),
    a = u8(hsla.a * 255.0),
  }
}

lighten :: proc(color: sdl.Color, amount: f32 = 0.1) -> sdl.Color {
  hsla := rgba_to_hsla(color)
  hsla.l += amount
  if hsla.l > 1.0 {
    hsla.l = 1.0
  }
  return hsla_to_rgba(hsla)
}

darken :: proc(color: sdl.Color, amount: f32 = 0.1) -> sdl.Color {
  hsla := rgba_to_hsla(color)
  hsla.l -= amount
  if hsla.l < 0.0 {
    hsla.l = 0.0
  }
  return hsla_to_rgba(hsla)
}
