module EventHandlers exposing (..)

import Html exposing (Attribute)
import Html.Events exposing (on)
import Json.Decode as Decode


onBlurWithTargetValue : (String -> a) -> Attribute a
onBlurWithTargetValue toMsg =
    on "blur" (Decode.map toMsg Html.Events.targetValue)


onChange : (String -> a) -> Attribute a
onChange toMsg =
    on "change" (Decode.map toMsg Html.Events.targetValue)
