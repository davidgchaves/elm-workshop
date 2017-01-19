module SearchOptions exposing (Model, Msg, initialModel, update, view)

import Html exposing (..)
import Html.Attributes exposing (class, defaultValue, placeholder, selected, type_, value)
import Html.Events exposing (on, onInput)
import Json.Decode as Decode


-- TYPE ALIAS


type alias Model =
    { minStars : Int
    , minStarsError : Maybe String
    , searchIn : String
    , userFilter : String
    }



-- MODEL


initialModel : Model
initialModel =
    { minStars = 5
    , minStarsError = Nothing
    , searchIn = "name"
    , userFilter = ""
    }



-- UPDATE


type Msg
    = SetMinStars String
    | SetSearchIn String
    | SetUserFilter String


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetMinStars minStarsStr ->
            case String.toInt minStarsStr of
                Ok minStars ->
                    { model | minStars = minStars, minStarsError = Nothing }

                Err _ ->
                    { model | minStarsError = Just "Need a number!" }

        SetSearchIn searchIn ->
            { model | searchIn = searchIn }

        SetUserFilter userFilter ->
            { model | userFilter = userFilter }



-- CUSTOM EVENT HANDLERS


onBlurWithTargetValue : (String -> a) -> Attribute a
onBlurWithTargetValue toMsg =
    on "blur" (Decode.map toMsg Html.Events.targetValue)


onChange : (String -> a) -> Attribute a
onChange toMsg =
    on "change" (Decode.map toMsg Html.Events.targetValue)



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "search-options" ]
        [ viewMinStars model.minStars model.minStarsError
        , viewUserFilter model.userFilter
        , viewSearchIn
        ]


viewMinStars : Int -> Maybe String -> Html Msg
viewMinStars minStars minStarsError =
    div [ class "search-option" ]
        [ viewMinStarsInput minStars
        , viewMinStarsError minStarsError
        ]


viewMinStarsInput : Int -> Html Msg
viewMinStarsInput minStars =
    div []
        [ label [ class "top-label" ] [ text "Minimum Stars" ]
        , input
            [ type_ "text"
            , onBlurWithTargetValue SetMinStars
            , defaultValue (toString minStars)
            ]
            []
        ]


viewMinStarsError : Maybe String -> Html a
viewMinStarsError minStarsError =
    case minStarsError of
        Just error ->
            div [ class "stars-error" ] [ text error ]

        Nothing ->
            div [] [ text "" ]


viewUserFilter : String -> Html Msg
viewUserFilter userFilter =
    div [ class "search-option" ]
        [ label [ class "top-label" ] [ text "Owned By" ]
        , input
            [ type_ "text"
            , onInput SetUserFilter
            , placeholder "Github Username"
            , defaultValue userFilter
            ]
            []
        ]


viewSearchIn : Html Msg
viewSearchIn =
    div [ class "search-option" ]
        [ label [ class "top-label" ] [ text "Search In" ]
        , select [ onChange SetSearchIn ]
            [ option [ value "name", selected True ] [ text "Name" ]
            , option [ value "description" ] [ text "Description" ]
            , option [ value "name,description" ] [ text "Name & Description" ]
            ]
        ]
