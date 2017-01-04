module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, defaultValue, href, target)
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode
import FakeResponse


type alias SearchResult =
    { id : Int
    , name : String
    , stars : Int
    }


type alias Model =
    { query : String
    , results : List SearchResult
    }


initialModel : Model
initialModel =
    { query = ""
    , results = fakeResults
    }



-- UPDATE


type Msg
    = DeleteById Int
    | SetQuery String


update : Msg -> Model -> Model
update msg model =
    case msg of
        DeleteById id ->
            { model | results = model.results |> List.filter (\r -> r.id /= id) }

        SetQuery q ->
            { model | query = q |> Debug.log "Debugging" }



-- DECODERS


fakeResults : List SearchResult
fakeResults =
    decodeResults FakeResponse.json


githubDecoder : Decode.Decoder (List SearchResult)
githubDecoder =
    Decode.field "items" searchResultsDecoder


searchResultsDecoder : Decode.Decoder (List SearchResult)
searchResultsDecoder =
    Decode.list searchResultDecoder


searchResultDecoder : Decode.Decoder SearchResult
searchResultDecoder =
    Decode.map3
        SearchResult
        (Decode.field "id" Decode.int)
        (Decode.field "full_name" Decode.string)
        (Decode.field "stargazers_count" Decode.int)


decodeResults : String -> List SearchResult
decodeResults json =
    case (json |> Decode.decodeString githubDecoder) of
        Ok searchResults ->
            searchResults

        Err error ->
            let
                _ =
                    Debug.log "Error Decoding with Github Decoder" error
            in
                []



-- VIEW


viewElmHubHeader : Html a
viewElmHubHeader =
    header []
        [ h1 [] [ text "ElmHub" ]
        , span [ class "tagline" ] [ text "Like GitHub, but for Elm things." ]
        ]


viewElmHubs : List SearchResult -> Html Msg
viewElmHubs results =
    ul [ class "results" ] (List.map viewSearchResults results)


viewSearchResults : SearchResult -> Html Msg
viewSearchResults result =
    li []
        [ span [ class "star-count" ]
            [ result.stars |> toString |> text ]
        , a [ href ("https://github.com/" ++ result.name), target "_blank" ]
            [ text result.name ]
        , button [ class "hide-result", onClick (DeleteById result.id) ] [ text "X" ]
        ]


viewSearchElmHubs : String -> Html Msg
viewSearchElmHubs query =
    div []
        [ input
            [ class "search-query"
            , onInput SetQuery
            , defaultValue query
            ]
            []
        , button [ class "search-button" ] [ text "Search" ]
        ]


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ viewElmHubHeader
        , viewSearchElmHubs model.query
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
