{
  name: 'abla-mvc',
  machine: 'oxente',
  targets: {
    production: {
      hooks: {
        build: 'make app',
      },
      services: {
        web: {
          type: 'abla-prebuilt',
          host: 'abla.oxente.pt',
          object_path: 'build/app.o',
          assets_path: 'assets',
          port: 8080,
        },
      },
    },
  },
}
