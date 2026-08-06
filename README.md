# Abla MVC

Abla MVC is an experimental, precompiled web framework written in Abla. The
repository root is the reusable library; the authenticated demo site and its
deployment configuration live in `examples/showcase`.

The current library provides:

- a typed HTML tree with attribute and text escaping;
- the compile-time `$mvcview` HTML subparser;
- expression interpolation and dynamic attributes;
- `onclick={action(...)}` syntax for typed server and client actions;
- automatic server-action registration and POST dispatch;
- automatic extraction of integer-only `@client` handlers to WebAssembly;
- declarative polling with anonymous per-tab session identity;
- configurable browser runtime and cache-safe asset helpers;
- a browser runtime that chooses the Wasm export or server RPC; and
- HTTP, form, response, and static-response helpers.

## Use the library today

Import Abla MVC through Abla's GitHub package provider:

```abla
import github("AndreBaltazar8/abla-mvc")

fun page(value: int): MvcHtml = $mvcview
    <main>
        <h1>Hello from Abla MVC</h1>
        <span id="counter">{value}</span>
        <button onclick={incrementCounter(1)} update="#counter">
            Increment
        </button>
    </main>
```

Resolve the dependency once from your application's project directory:

```sh
ablac package update --project .
```

This records the resolved GitHub HEAD revision in `abla.lock`. Commit that
lockfile so ordinary and `--offline` builds use the same immutable revision;
run `package update` again only when you intend to refresh dependencies. For
local framework development, a relative import of `src/abla-mvc.ab` remains
useful.

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

Server actions may take no arguments or any number of `int` and `string`
arguments:

```abla
fun clearCounter(): MvcAction =
    replace("#counter", mvcHtmlText("0"))

fun labelCounter(value: int, label: string): MvcAction =
    replace("#counter", mvcHtmlText("$label: $value"))

fun controls(value: int): MvcHtml = $mvcview
    <div>
        <button onclick={clearCounter()} update="#counter">Clear</button>
        <button
            onclick={labelCounter(value, "Current")}
            update="#counter"
        >Label</button>
    </div>
```

Client actions may take any number of integer arguments and must return an
integer. String client actions are reserved until Abla MVC has a stable string
ABI for Wasm.

## Declarative polling

Use `poll`, `every`, and `update` to refresh an HTML fragment without writing
browser JavaScript:

```abla
fun presence(): MvcHtml = $mvcview
    <p id="presence" poll="/presence" every="5s" update="#presence">
        Loading presence...
    </p>
```

The runtime requests the endpoint immediately and then at the configured
interval. It prevents overlapping requests, pauses while the page is hidden,
and stops when the polling element leaves the document. Poll requests include
an `Abla-Session` header containing a random ID scoped to the current browser
tab. Applications decide whether and how to retain that session on the server.

## Runtime and caching

The default runtime continues to work at `/__abla/mvc.js`. Applications can
configure versioned asset and action paths with a handler:

```abla
val runtime = mvcBrowserRuntimeOptions(
    "/assets/abla-mvc-client.wasm?v=2026-08-03",
    "/__abla/action/",
    "force-cache"
)
application.get("/__abla/mvc.js", mvcBrowserRuntimeHandler(runtime))
```

Runtime JavaScript responses use `Cache-Control: no-store`. An application can
use `mvcNoStore`, `mvcPublicCache`, or `mvcImmutableCache` with any response.
Use immutable caching only when the asset URL contains a content or revision
fingerprint. Abla's HTTP router automatically serves `HEAD` through the
matching `GET` route while suppressing the body on the wire.

## HTML syntax

`$mvcview` supports custom element names, hyphenated and namespaced
attributes, boolean attributes, single- or double-quoted values, dynamic Abla
expressions, HTML void elements, and explicit self-closing elements:

```abla
fun field(): MvcHtml = $mvcview
    <custom-field aria-label='Name' data-ready disabled>
        <input name="name" required>
        <svg><path xlink:href="#icon" /></svg>
    </custom-field>
```

## Current limits

This is still a small developer-preview surface:

- views currently require one root element;
- event handlers must be direct calls;
- server action parameters are limited to integers and strings;
- client action parameters and results are limited to integers;
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
