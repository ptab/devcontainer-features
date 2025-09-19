# helix-language-server-proxy

Installs a proxy to support running containerized language servers in Helix.

## How to use

1. Add this feature to your devcontainer:
   ```json
   "features": {
       "ghcr.io/ptab/devcontainer-features/helix-language-server-proxy:0": {}
   }
   ```
2. Configure your favorite language server(s) in `languages.toml`:
   ```toml
   [language-server.bash-language-server]
   command = "devcontainer"
   args = [ "exec", "--workspace-folder", ".", "helix-language-server-proxy", "bash-language-server", "start" ]
   ```

## Why is this needed?

A few weeks ago I decided to give [Helix](https://helix-editor.com/) a shot.
Coming from VSCode, the first thing I tried to do was to replicate my workflow based on [Development Containers](https://containers.dev/).
Unfortunately, it doesn't look like Helix is yet ready for this (as shown by [helix-editor/helix #5454](https://github.com/helix-editor/helix/issues/5454) and [helix-editor/helix #7472](https://github.com/helix-editor/helix/issues/7472)).
I did manage to make it start a containerized language server, but it would invariably terminate after a couple of seconds. Not great.

I looked around for inspiration, and eventually found in the [README](https://github.com/lspcontainers/lspcontainers.nvim#process-id) of [lspcontainers.nvim](https://github.com/lspcontainers/lspcontainers.nvim) something very familiar:

> The LSP spec allows a client to send its process id to a language server, so that the server can exit immediately when it detects that the client is no longer running.  
> This feature fails to work properly on a containerized language server because the host and the container do not share the container namespace by default.  
> A container can share a process namespace with the host by passing the `--pid=host` flag to docker/podman, although it should be noted that this somewhat reduces isolation.  
> It is also possible to simply disable the process id detection.  
> ...  
> This is required for several LSPs, and they will exit immediately if this is not specified.

This explains the issue I was seeing!
To address this, the first thing I tried was to start my devcontainer with `--pid=host`, but that did not seen to make any difference as the language server still stopped after a few seconds.

My next step was to configure Helix to stop it from sending the `processId` parameter. Unfortunately [this behaviour is non-configurable at the moment](https://github.com/helix-editor/helix/blob/d0218f7e78bc0c3af4b0995ab8bda66b9c542cf3/helix-lsp/src/client.rs#L560), and so this was also not an option.

The only other thing I could think of was to write a small script to intercept the JSON-RPC messages sent by Helix to the language servers, and remove in-transit the `params.processId` field from the `initialize` message before it reaches its destination.
And what do you know, it actually worked!

This repository makes this hacky solution a bit easier to manage by wrapping it as a devcontainer feature.

## FAQ

_Can I also use this for my formatters?_
You _can_, but Helix won't make it easy. Check out [ptab/helix-language-servers](https://github.com/ptab/helix-language-servers) for a working solution.
