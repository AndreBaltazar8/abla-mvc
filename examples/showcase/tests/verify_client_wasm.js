const { readFileSync } = require("node:fs");

WebAssembly.instantiate(readFileSync(process.argv[2]), {}).then(
  ({ instance }) => {
    const names = Object.keys(instance.exports).filter((key) =>
      key.startsWith("abla_mvc_client_")
    );
    const reset = names.find((name) => instance.exports[name].length === 0);
    const increment = names.find((name) => instance.exports[name].length === 1);
    const add = names.find((name) => instance.exports[name].length === 2);
    if (!reset || !increment || !add) {
      throw new Error("generated MVC client exports are missing");
    }
    if (instance.exports[reset]() !== 0n) {
      throw new Error("generated no-argument MVC client action returned the wrong value");
    }
    if (instance.exports[increment](41n) !== 42n) {
      throw new Error("generated MVC client action returned the wrong value");
    }
    if (instance.exports[add](40n, 2n) !== 42n) {
      throw new Error("generated multi-parameter MVC client action returned the wrong value");
    }
  }
);
