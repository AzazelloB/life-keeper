package main

import "base:runtime"

import "core:fmt"
import "core:mem"
import "core:mem/virtual"
import "core:os"
import "core:time"

import sdl "vendor:sdl2"
import ttf "vendor:sdl2/ttf"

App :: struct {
	window:         ^sdl.Window,
	window_width:   i32,
	window_height:  i32,
	renderer:       ^sdl.Renderer,
	layout:         Window,
	needs_rerender: bool,
	dt:             f64,
	font:           ^ttf.Font,
	events:         [dynamic]sdl.Event,
}

init :: proc(app: ^App) {
	// might need .AUDIO and .TIMER later
	if sdl.Init({.VIDEO, .EVENTS}) < 0 {
		fmt.eprintln("Failed to init sdl: %s", sdl.GetError())
		os.exit(1)
	}

	if ttf.Init() < 0 {
		fmt.eprintln("Failed to init ttf: %s", ttf.GetError())
		os.exit(1)
	}

	app.window = sdl.CreateWindow(
	"Life Keeper",
	sdl.WINDOWPOS_CENTERED,
	sdl.WINDOWPOS_CENTERED,
	1280,
	720,
	{.SHOWN, .RESIZABLE, .ALLOW_HIGHDPI},
	// NOTE: For .ALLOW_HIGHDPI On macOS NSHighResolutionCapable must be set true
	// in the application's Info.plist for this to have any effect.
	)

	if app.window == nil {
		fmt.eprintln("Failed to create window: %s", sdl.GetError())
		os.exit(1)
	}

	app.renderer = sdl.CreateRenderer(app.window, -1, {.PRESENTVSYNC})

	if app.renderer == nil {
		fmt.eprintfln("Failed to create renderer: %s", sdl.GetError())
		os.exit(1)
	}

	app.font = ttf.OpenFont("./assets/Martian_Mono/MartianMono-VariableFont_wdth,wght.ttf", 32)
}

cleanup :: proc(app: ^App) {
	sdl.DestroyWindow(app.window)
	sdl.DestroyRenderer(app.renderer)

	sdl.Quit()

	ttf.CloseFont(app.font)

	ttf.Quit()

	delete(app.events)
}

poll_events :: proc(app: ^App) -> (window_stay_open: bool) {
	event: sdl.Event

	for sdl.PollEvent(&event) {
		append(&app.events, event)

		#partial switch event.type {
		case .QUIT:
			{
				return false
			}

		case .KEYDOWN:
			{
				when ODIN_DEBUG {
					if event.key.keysym.sym == .ESCAPE {
						return false
					}
				}
			}

		case .WINDOWEVENT:
			{
				#partial switch event.window.event {
				case .SHOWN, .RESIZED:
					{
						sdl.GetWindowSize(app.window, &app.window_width, &app.window_height)

						request_rerender(app)
					}
				}
			}
		}
	}

	return true
}

clear_events :: proc(app: ^App) {
	clear(&app.events)
}

prepare_frame :: proc(app: ^App) {
	sdl.SetRenderDrawColor(app.renderer, 15, 0, 30, 255)
	sdl.RenderClear(app.renderer)

	sdl.SetRenderDrawBlendMode(app.renderer, .BLEND)

	sdl.SetCursor(sdl.GetDefaultCursor())
}

draw_frame :: proc(app: ^App) {
	for widget in app.layout.widgets {
		bounds: sdl.Rect

		switch widget.anchor {
		case .TOP_LEFT:
			{
				panic("Not Implemented")
			}

		case .TOP_CENTER:
			{
				panic("Not Implemented")
			}

		case .TOP_RIGHT:
			{
				panic("Not Implemented")
			}

		case .RIGHT_CENTER:
			{
				panic("Not Implemented")
			}

		case .RIGHT_BOTTOM:
			{
				panic("Not Implemented")
			}

		case .BOTTOM_CENTER:
			{
				panic("Not Implemented")
			}

		case .BOTTOM_LEFT:
			{
				panic("Not Implemented")
			}

		case .LEFT_CENTER:
			{
				bounds = {
					x = app.layout.bounds.x,
					y = app.layout.bounds.y,
					w = i32(max(u16(f16(app.layout.bounds.w) * widget.width), widget.max_width)),
					h = i32(max(u16(f16(app.layout.bounds.h) * widget.height), widget.max_height)),
				}
			}

		case .CENTER:
			{
				panic("Not Implemented")
			}
		}

		switch c in widget.component {
		case List:
			{
				draw_list(app, c, &bounds)
			}

		case Button:
			{
				draw_button(app, c, &bounds)
			}

		case Text:
			{
				panic("Not Implemented")
			}
		}
	}

	sdl.RenderPresent(app.renderer)
}

request_rerender :: proc(app: ^App) {
	app.needs_rerender = true
}

need_rerender :: proc(app: ^App) -> bool {
	return app.needs_rerender
}

set_rerender_complete :: proc(app: ^App) {
	app.needs_rerender = false
}

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}

			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}

			mem.tracking_allocator_destroy(&track)
		}
	}

	app: App

	init(&app)
	defer cleanup(&app)

	layout_arena: virtual.Arena
	layout_allocator := virtual.arena_allocator(&layout_arena)

	start := time.tick_now()

	for {
		app.dt = time.duration_seconds(time.tick_lap_time(&start))

		poll_events(&app) or_break

		if need_rerender(&app) {
			virtual.arena_destroy(&layout_arena)

			app.layout = get_layout(&app, layout_allocator)

			set_rerender_complete(&app)
		}

		prepare_frame(&app)

		draw_frame(&app)

		clear_events(&app)
	}
}
