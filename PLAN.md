# Extract Moss, the Gleam terminal styling library

Moss is the standalone styling package for Sprig, Trunk, and the future Gleam TUI runtime. Use `moss` for both the package and the module. Reuse Sprig’s existing ANSI renderer and keep the current component and debugger output intact.

## Starting point

- `/Users/smitpatil/Projects/moss` already contains a scaffolded Gleam package. Put the renderer in its `src/moss.gleam` and use `test/moss_test.gleam` for its tests.
- `/Users/smitpatil/Projects/sprig` contains the implementation in `src/sprig.gleam` and its tests in `test/sprig_test.gleam`. The spinner, progress bar, and their examples and tests use this API.
- `/Users/smitpatil/Projects/trunk` currently depends on `../sprig` and uses it to style severity labels in `src/trunk.gleam`. Its test checks the output for all five levels.

## Moss API

- Keep `Color` with the eight named ANSI colors and `Color(red: Int, green: Int, blue: Int)` for RGB. Retain RGB channel clamping and parsing of six hex digits with an optional `#`. `hex` returns `Result(Color, ColorError)` with `InvalidHex` for malformed input.
- Use an opaque, immutable `Style` value that callers can compare with `==`. Keep `new()`, `foreground`, `background`, `bold`, `italic`, and `underline`. Setters return a new style and compose in Gleam pipelines.
- Keep `render(style, text) -> String` pure. An empty style returns the input unchanged. A styled span emits one opening ANSI SGR sequence and a trailing reset. Preserve the current output bytes during extraction.

```gleam
import moss

pub fn warning_label() -> String {
  moss.new()
  |> moss.foreground(moss.Yellow)
  |> moss.bold
  |> moss.render("WARN")
}
```

## How the TUI runtime will use it

The runtime stores text and `moss.Style` separately in its cell buffer. At redraw time it compares frames, groups adjacent changed cells on the same row with equal styles, and renders each run once. Start drawing in a known default terminal style so plain runs inherit the intended defaults. Trunk can use the same API to render a severity label immediately.

The runtime owns terminal I/O, cursor movement, screen state, input, layout, and Unicode display widths. Moss needs no terminal connection or runtime dependency. Start with one reset per styled run. Add style transitions only if runtime measurements show the extra escape sequences matter. The initial renderer accepts plain text spans. An embedded ANSI reset clears the current terminal style.

## Implementation order

1. Move the styling implementation and its tests from Sprig into Moss. Reuse the existing hex parser dependency and API behavior. Document the pipeline API and the runtime’s render boundary in Moss’s README.
2. Add `moss = { path = "../moss" }` to Sprig and migrate the component code, examples, and tests to `import moss`. Keep spinner frames, progress bar gradients, and their rendered output intact. Keep Sprig’s test runner working after moving the styling tests.
3. Switch Trunk’s dependency from Sprig to Moss and migrate the logger import. Preserve its plain severity strings, UTC timestamp, message text, and current palette. Refresh the manifests and document the sibling checkout requirement in both consumers.
4. Check for remaining callers of Sprig’s styling API, then remove the duplicate renderer. Keep the runtime, terminal capability detection, and theme APIs outside this first extraction.

## Done when

- Moss builds and passes its suite from its own checkout. Coverage includes named and RGB foreground and background, combined attributes, valid and invalid hex, RGB clamping, plain output, and resets.
- A Moss test exercises the runtime use case by comparing independently built equal styles and concatenating a multi-character styled run with plain and differently styled runs. Verify that the output resets before the following run.
- Sprig’s component tests and Trunk’s five-severity regression test pass. Run `gleam format --check src test`, `gleam check`, and `gleam test` in all three checkouts.
- Local dependency paths resolve to Moss for both consumers. Any CI checkout that runs the consumer suites needs access to the same Moss source.
