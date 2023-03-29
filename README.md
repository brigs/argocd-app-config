## Setup Docker Dev-Continers
Follow [instructions](https://code.visualstudio.com/docs/devcontainers/containers#_getting-started) for setting up Dev-Containers and installing [Dev Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) for vscode.

Once you have Development Continer in place, run the following to open the code inside a container:


1. Run the __Dev Contaienrs: ReOpen in Container.__ This will start building the dev container using the `devcontainer.json` file from `.devcontainer/`. You only build the dev container the first time and it can take a few minutes before its ready. 

2. After the build completes, VS Code will automatically connect to the container


## Generating manifest


Install npm dependencies inside `./dynamic-manifests`:
```
npm install
```

Running `generate` script should generate a simple manifest, using `jk` and `kustomize`

```
npm run generate
```