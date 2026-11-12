import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam_community/colour

/// Named ANSI colors or RGB channels, clamped to 0–255 when rendered.
pub type Color {
  Black
  Red
  Green
  Yellow
  Blue
  Magenta
  Cyan
  White
  Color(red: Int, green: Int, blue: Int)
}

pub type ColorError {
  InvalidHex
}

pub type Style {
  Style(
    foreground: Option(Color),
    background: Option(Color),
    bold: Bool,
    italic: Bool,
    underline: Bool,
  )
}

/// Create a style with no colors or attributes enabled.
pub fn new() -> Style {
  Style(None, None, False, False, False)
}

/// Set the text color.
pub fn foreground(style: Style, color: Color) -> Style {
  Style(..style, foreground: Some(color))
}

/// Set the background color.
pub fn background(style: Style, color: Color) -> Style {
  Style(..style, background: Some(color))
}

/// Enable bold text.
pub fn bold(style: Style) -> Style {
  Style(..style, bold: True)
}

/// Enable italic text.
pub fn italic(style: Style) -> Style {
  Style(..style, italic: True)
}

/// Enable underlined text.
pub fn underline(style: Style) -> Style {
  Style(..style, underline: True)
}

/// Wrap styled text in ANSI SGR codes and a trailing reset.
/// An unstyled value returns the original text unchanged.
pub fn render(style: Style, text: String) -> String {
  let codes = build_codes(style)
  case codes {
    [] -> text
    _ -> "\u{001b}[" <> string.join(codes, ";") <> "m" <> text <> "\u{001b}[0m"
  }
}

fn build_codes(style: Style) -> List(String) {
  let attrs =
    [#(style.bold, "1"), #(style.italic, "3"), #(style.underline, "4")]
    |> list.filter_map(fn(item) {
      case item.0 {
        True -> Ok(item.1)
        False -> Error(Nil)
      }
    })

  let fg = case style.foreground {
    Some(color) -> [color_to_code(color, True)]
    None -> []
  }

  let bg = case style.background {
    Some(color) -> [color_to_code(color, False)]
    None -> []
  }

  list.flatten([attrs, fg, bg])
}

fn color_to_code(color: Color, is_fg: Bool) -> String {
  let offset = case is_fg {
    True -> 0
    False -> 10
  }

  case color {
    Black -> int.to_string(30 + offset)
    Red -> int.to_string(31 + offset)
    Green -> int.to_string(32 + offset)
    Yellow -> int.to_string(33 + offset)
    Blue -> int.to_string(34 + offset)
    Magenta -> int.to_string(35 + offset)
    Cyan -> int.to_string(36 + offset)
    White -> int.to_string(37 + offset)
    Color(red, green, blue) ->
      string.join(
        [
          int.to_string(38 + offset),
          "2",
          int.to_string(int.clamp(red, 0, 255)),
          int.to_string(int.clamp(green, 0, 255)),
          int.to_string(int.clamp(blue, 0, 255)),
        ],
        ";",
      )
  }
}

/// Parse six hex digits, with an optional leading `#`.
pub fn hex(value: String) -> Result(Color, ColorError) {
  let digits = string.remove_prefix(value, "#")

  case string.byte_size(digits) == 6 {
    False -> Error(InvalidHex)
    True ->
      case colour.from_rgb_hex_string("#" <> digits) {
        Ok(c) -> {
          let #(r, g, b, _) = colour.to_rgba(c)

          let r_int = float.round(r *. 255.0)
          let g_int = float.round(g *. 255.0)
          let b_int = float.round(b *. 255.0)

          Ok(Color(r_int, g_int, b_int))
        }
        Error(Nil) -> Error(InvalidHex)
      }
  }
}
