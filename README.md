# Abla MVC

Abla MVC is an experimental, precompiled web framework written in Abla. The
repository root is the reusable library; the authenticated demo site and its
deployment configuration live in `examples/showcase`.

The current library provides:

- a typed HTML tree with attribute and text escaping;
- the compile-time `$mvcview` HTML subparser;
- expression interpolation and dynamic attributes;
- `onclick={action(argument)}` syntax for typed server and client actions;
- automatic server-action registration and POST dispatch;
- automatic extraction of `@client (int) -> int` handlers to WebAssembly;
- a browser runtime that chooses the Wasm export or server RPC; and
- HTTP, form, response, and static-response helpers.

## Use the library today

Abla currently resolves relative modules and `abla/...` standard-library
modules. It does not yet fetch Git or GitHub package dependencies. Until the
package RFC lands, include this repository beside an application and import its
public composition root by relative path:

```abla
#import("../../abla-mvc/src/abla-mvc.ab")

fun page(value: int): MvcHtml = $mvcview
    <main>
        <h1>Hello from Abla MVC</h1>
        <span id="counter">{value}</span>
        <button onclick={incrementCounter(1)} update="#counter">
            Increment
        </button>
    </main>
```

`abla.toml` records the package name, version, and public entry module in the
shape expected by Abla's early project support. The proposed Git dependency,
lockfile, cache, vendoring, and offline behavior is documented in
`../ablac/rfc/git-package-dependencies.md`.

## Build and test

The Abla compiler repository is expected at `../ablac`.

```sh
make test
make run
```

`make test` checks the reusable library and then the complete showcase,
including its generated browser Wasm module. `make run` starts the showcase at
<http://localhost:8080/>. Sign in with the intentionally demo-only credentials
`admin` / `admin`; `?query=1` exercises query parsing.

## Repository layout

```text
abla.toml
src/
  abla-mvc.ab          public library entry
  mvcview.ab           compile-time HTML and action integration
  html.ab              typed HTML and escaping
  actions.ab           server dispatch and browser runtime
  client_artifact.ab   @client Wasm artifact builder
  forms.ab             form decoding
  http.ab              MVC response helpers
  static.ab            CSS and Wasm response helpers
tests/                  focused library tests
examples/showcase/
  app.ab               native server composition root
  client.ab            browser artifact composition root
  controllers/
  models/
  views/
  assets/
  tests/
  icy.jsonnet          abla.oxente.pt deployment
```

Application-specific sessions, credentials, controllers, static-file paths,
styles, and Icy deployment metadata remain in the example. They are not part of
the framework API.

## Views and automatic actions

```abla
fun counterView(model: CounterModel): MvcHtml = $mvcview
    <section>
        <span id="counter">{model.counter}</span>
        <button onclick={incrementCounter(1)} update="#counter">
            Increment on server
        </button>
        <button onclick={incrementLocally(model.counter)} update="#counter">
            Increment in browser
        </button>
    </section>
```

An ordinary `(int) -> MvcAction` target gets a generated typed adapter and an
opaque action identifier in the server allowlist. An explicitly annotated
`@client (int) -> int` target becomes a deterministic WebAssembly export. The
view emits metadata rather than inline JavaScript, and the runtime loads the
client module once and falls back to the server action path where appropriate.

## Current limits

This is still a small developer-preview surface:

- elements require matching closing tags;
- attributes are quoted strings or `{Abla expressions}`;
- events are direct calls with exactly one non-negative integer argument;
- server results replace an HTML fragment;
- client results currently update text content;
- state and showcase sessions are process-local and in memory; and
- production CSRF protection, request limits, and hardened error handling have
  not landed yet.

The live showcase is deployed at <https://abla.oxente.pt/>. From
`examples/showcase`, `icy validate` and `icy deploy --watch` build and deploy
the configured service.

## License

Abla MVC is available under the Mozilla Public License 2.0, matching the Abla
compiler. See `LICENSE`.
