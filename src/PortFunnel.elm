module PortFunnel exposing
    ( Config(..), PortDesc, GenericMessage, EncodeDecode
    , makeConfig, getFunnelCmd, makeSimulatorConfig
    , encodeMessage, decodeMessage, encodeBackend, decodeBackend, process
    )

{-| PortFunnel allows you to use multiple ports easily.

You create a single outgoing/incoming pair of ports, and PortFunnel does the rest.

Some very simple JavaScript boilerplate directs `PortFunnel.js` to load and wire up all the other PortFunnel-aware JavaScript files. You write one simple case statement to choose which port package's message is coming in, and then write package-specific code to handle each one.


## Types

@docs Config, PortDesc, GenericMessage, EncodeDecode


## Configuration

@docs makeConfig, getFunnelCmd, makeSimulatorConfig


## API

@docs encodeMessage, decodeMessage, encodeBackend, decodeBackend, process

-}

import Dict exposing (Dict)
import Json.Encode as JE exposing (Value)


{-| A generic message that goes over the wire to/from the port JavaScript.
-}
type alias GenericMessage =
    { portName : String
    , command : String
    , args : List ( String, Value )
    }


{-| Bundling up JSON Encoder and Decoder for the specific port types.
-}
type alias EncodeDecode message =
    { encode : message -> GenericMessage
    , decode : GenericMessage -> Result String message
    }


{-| Everything we need to know to route one port module's messages.
-}
type PortDesc message backend result state
    = PortDesc
        { name : String
        , messageEncodeDecode : EncodeDecode message
        , backendEncodeDecode : EncodeDecode backend
        , process : message -> state -> ( state, result )
        }


{-| Package up your ports or a simluator.
-}
type Config msg
    = Config
        { funnelCmd : GenericMessage -> Cmd msg
        , simulator : Maybe (GenericMessage -> Maybe GenericMessage)
        }


{-| Make a `Config` for a real outgoing port
-}
makeConfig : (GenericMessage -> Cmd msg) -> Config msg
makeConfig funnelCmd =
    Config
        { funnelCmd = funnelCmd
        , simulator = Nothing
        }


{-| Get the `funnelCmd` from a `Config`, if it has one.
-}
getFunnelCmd : Config msg -> Maybe (GenericMessage -> Cmd msg)
getFunnelCmd (Config config) =
    case config.simulator of
        Nothing ->
            Just config.funnelCmd

        Just _ ->
            Nothing


{-| Make a `Config` that enables running your code in `elm reactor`.

The arg is a port simulator, which translates a message sent to an optional response.

-}
makeSimulatorConfig : (GenericMessage -> Maybe GenericMessage) -> Config msg
makeSimulatorConfig simulator =
    Config
        { funnelCmd = \_ -> Cmd.none
        , simulator = Just simulator
        }


{-| Encode a message to a GenericMessage
-}
encodeMessage : PortDesc message backend result state -> message -> GenericMessage
encodeMessage (PortDesc portDesc) message =
    portDesc.messageEncodeDecode.encode message


{-| Decode a message from a GenericMessage
-}
decodeMessage : PortDesc message backend result state -> GenericMessage -> Result String message
decodeMessage (PortDesc portDesc) genericMessage =
    portDesc.messageEncodeDecode.decode genericMessage


{-| Encode a backend to a GenericMessage
-}
encodeBackend : PortDesc message backend result state -> backend -> GenericMessage
encodeBackend (PortDesc portDesc) message =
    portDesc.backendEncodeDecode.encode message


{-| Decode a backend from a GenericMessage
-}
decodeBackend : PortDesc message backend result state -> GenericMessage -> Result String backend
decodeBackend (PortDesc portDesc) genericMessage =
    portDesc.backendEncodeDecode.decode genericMessage


{-| Process a messsage.
-}
process : PortDesc message backend result state -> message -> state -> ( state, result )
process (PortDesc portDesc) message state =
    portDesc.process message state
