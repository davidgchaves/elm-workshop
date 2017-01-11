module Main exposing (..)

import Html exposing (program)
import ElmHub exposing (Model, Msg)


main : Program Never Model Msg
main =
    Html.program
        { init = ElmHub.init
        , view = ElmHub.view
        , update = ElmHub.update
        , subscriptions = ElmHub.subscriptions
        }
