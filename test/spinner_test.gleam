import gleam/list
import gleam/string
import gleeunit/should
import spinner
import sprig

pub fn default_spinner_test() {
  let value = spinner.new()
  spinner.render(value) |> should.equal("\u{001b}[38;2;0;229;29m⠋\u{001b}[0m")
  spinner.interval_ms(value) |> should.equal(80)
  value
  |> spinner.tick
  |> spinner.render
  |> should.equal("\u{001b}[38;2;0;229;29m⠙\u{001b}[0m")
  spinner.render(value) |> should.equal("\u{001b}[38;2;0;229;29m⠋\u{001b}[0m")
}

pub fn presets_loop_at_fixed_width_test() {
  list.each(
    [
      #(spinner.Dot, 10, 80, 1),
      #(spinner.Line, 4, 120, 1),
      #(spinner.MiniDot, 4, 100, 1),
      #(spinner.Jump, 7, 100, 1),
      #(spinner.Pulse, 6, 120, 1),
      #(spinner.Points, 3, 160, 3),
      #(spinner.Bounce, 8, 80, 5),
    ],
    fn(preset) {
      let #(variant, frame_count, interval, width) = preset
      let initial =
        spinner.new()
        |> spinner.variant(variant)
        |> spinner.style(sprig.new())
      spinner.interval_ms(initial) |> should.equal(interval)
      initial
      |> spinner.tick
      |> spinner.render
      |> should.not_equal(spinner.render(initial))
      let final =
        list.fold(list.repeat(Nil, frame_count * 2), initial, fn(value, _) {
          value |> spinner.render |> string.length |> should.equal(width)
          spinner.tick(value)
        })
      final |> should.equal(initial)
    },
  )
}

pub fn style_preserves_frame_test() {
  let style = sprig.new() |> sprig.foreground(sprig.Cyan) |> sprig.bold
  let value = spinner.new() |> spinner.tick |> spinner.style(style)
  spinner.render(value) |> should.equal("\u{001b}[1;36m⠙\u{001b}[0m")
  value
  |> spinner.tick
  |> spinner.render
  |> should.equal("\u{001b}[1;36m⠹\u{001b}[0m")

  value |> spinner.style(sprig.new()) |> spinner.render |> should.equal("⠙")
  spinner.interval_ms(value) |> should.equal(80)
}

pub fn switching_variant_resets_frame_and_preserves_style_test() {
  let value =
    spinner.new()
    |> spinner.style(sprig.new() |> sprig.foreground(sprig.Green))
    |> spinner.tick
    |> spinner.tick
    |> spinner.variant(spinner.Points)

  spinner.render(value) |> should.equal("\u{001b}[32m●··\u{001b}[0m")
  spinner.interval_ms(value) |> should.equal(160)
  value
  |> spinner.tick
  |> spinner.render
  |> should.equal("\u{001b}[32m·●·\u{001b}[0m")
}

pub fn switching_from_last_frame_to_shorter_preset_test() {
  let value =
    list.fold(list.repeat(Nil, 9), spinner.new(), fn(value, _) {
      spinner.tick(value)
    })
  spinner.render(value) |> should.equal("\u{001b}[38;2;0;229;29m⠏\u{001b}[0m")
  value
  |> spinner.variant(spinner.Line)
  |> spinner.render
  |> should.equal("\u{001b}[38;2;0;229;29m|\u{001b}[0m")
}

pub fn reselecting_variant_resets_frame_test() {
  spinner.new()
  |> spinner.tick
  |> spinner.variant(spinner.Dot)
  |> spinner.render
  |> should.equal("\u{001b}[38;2;0;229;29m⠋\u{001b}[0m")
}
