const { readFileSync } = require("node:fs");

WebAssembly.instantiate(readFileSync(process.argv[2]), {}).then(
  ({ instance }) => {
    const name = Object.keys(instance.exports).find((key) =>
      key.startsWith("abla_mvc_client_")
    );
    if (!name) throw new Error("generated MVC client export is missing");
    if (instance.exports[name](41n) !== 42n) {
      throw new Error("generated MVC client action returned the wrong value");
    }
  }
);
