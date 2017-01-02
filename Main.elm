module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, href, target)
import Html.Events exposing (onClick)


type alias Result =
    { id : Int
    , name : String
    , stars : Int
    }


type alias Model =
    { results : List Result }


initialModel : Model
initialModel =
    { results =
        [ { id = 1
          , name = "TheSeamau5/elm-checkerboardgrid-tutorial"
          , stars = 66
          }
        , { id = 2
          , name = "grzegorzbalcerek/elm-by-example"
          , stars = 41
          }
        , { id = 3
          , name = "sporto/elm-tutorial-app"
          , stars = 35
          }
        , { id = 4
          , name = "jvoigtlaender/Elm-Tutorium"
          , stars = 10
          }
        , { id = 5
          , name = "sporto/elm-tutorial-assets"
          , stars = 7
          }
        ]
    }



-- UPDATE


type Msg
    = DeleteById Int


update : Msg -> Model -> Model
update msg model =
    case msg of
        DeleteById id ->
            { model | results = model.results |> List.filter (\r -> r.id /= id) }



-- VIEW


viewElmHubHeader : Html a
viewElmHubHeader =
    header []
        [ h1 [] [ text "ElmHub" ]
        , span [ class "tagline" ]
            [ text "Like GitHub, but for Elm things." ]
        ]


viewElmHubs : List Result -> Html Msg
viewElmHubs results =
    ul [ class "results" ] (List.map viewSearchResults results)


viewSearchResults : Result -> Html Msg
viewSearchResults result =
    li []
        [ span [ class "star-count" ]
            [ result.stars |> toString |> text ]
        , a [ href ("https://github.com/" ++ result.name), target "_blank" ]
            [ text result.name ]
        , button [ class "hide-result", onClick (DeleteById result.id) ] [ text "X" ]
        ]


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ viewElmHubHeader
        , viewElmHubs model.results
        ]



-- MAIN


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = initialModel
        , view = view
        , update = update
        }
