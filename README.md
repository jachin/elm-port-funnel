# Funneling Your Ports

[billstclair/elm-port-funnel](https://package.elm-lang.org/packages/billstclair/elm-port-funnel/latest) allows you to use a single outgoing/incoming pair of `port`s to communicate with the JavaScript for any number of `PortFunnel`-aware modules.

On the JavaScript side, you pick a directory for `PortFunnel.js` and the JavaScript files for all the other `PortFunnel`-aware modules. Some boilerplate JS in your `index.html` file loads `PortFunnel.js`, and tells it the names of the other JavaScript files. It takes care of loading them and wiring them up.

On the Elm side, you create the two ports, tell the `PortFunnel` module about them with a `Config` instance, call the action functions from the `PortFunnel`-aware modules in response to events, and dispatch off of the `name` field in the `GenericMessage` you get from your subscription port, to `process` that message in each specific module, and handle its `result`.
