package main

import sdl "vendor:sdl2"

get_mouse_pos :: proc() -> sdl.Point {
	mouse_x: i32 = 0
	mouse_y: i32 = 0
	sdl.GetMouseState(&mouse_x, &mouse_y)

	return {mouse_x, mouse_y}
}

just_pressed :: proc(app: ^App, rect: ^sdl.Rect) -> bool {
	mouse_pos := get_mouse_pos()

	for e in app.events {
		#partial switch e.type {
		case .MOUSEBUTTONDOWN:
			{
				if sdl.PointInRect(&mouse_pos, rect) {
					return true
				}
			}
		}
	}

	return false
}

just_released :: proc(app: ^App) -> bool {
	for e in app.events {
		#partial switch e.type {
		case .MOUSEBUTTONUP:
			{
				return true
			}
		}
	}

	return false
}
