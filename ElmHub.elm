port module ElmHub exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, defaultValue, href, target)
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode exposing (Decoder)
import Http
import Table
import Auth
import SearchOptions


-- TYPE ALIAS


type alias SearchResult =
    { id : Int
    , name : String
    , stars : Int
    }


type alias Model =
    { query : String
    , results : List SearchResult
    , error : Maybe String
    , searchOptions : SearchOptions.Model
    , tableState : Table.State
    }



-- MODEL


initialModel : Model
initialModel =
    { query = ""
    , results = []
    , error = Nothing
    , searchOptions = SearchOptions.initialModel
    , tableState = Table.initialSort "Stars"
    }


init : ( Model, Cmd a )
init =
    ( initialModel, Cmd.none )



-- UPDATE


type Msg
    = DeleteById Int
    | SetQuery String
    | SearchElm
    | SearchJS
    | HandleGithubResponse (Result Http.Error (List SearchResult))
    | HandleGithubResponseFromJS (Result String (List SearchResult))
    | SearchOptions SearchOptions.Msg
    | SetTableState Table.State


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DeleteById id ->
            ( { model | results = model.results |> List.filter (\r -> r.id /= id) }, Cmd.none )

        SetQuery q ->
            ( { model | query = q, error = Nothing }, Cmd.none )

        SearchElm ->
            ( { model | error = Nothing }, searchGithubApi (githubApiUrl model) )

        SearchJS ->
            ( { model | error = Nothing }, searchGithubApiWithJS (githubApiUrl model) )

        HandleGithubResponse (Ok results) ->
            ( { model | results = results }, Cmd.none )

        HandleGithubResponse (Err error) ->
            ( { model | error = Just (handleHttpError error) }, Cmd.none )

        HandleGithubResponseFromJS (Ok results) ->
            ( { model | results = results }, Cmd.none )

        HandleGithubResponseFromJS (Err error) ->
            ( { model | error = Just error }, Cmd.none )

        SearchOptions searchOptionsMsg ->
            ( { model | searchOptions = SearchOptions.update searchOptionsMsg model.searchOptions }, Cmd.none )

        SetTableState tableState ->
            ( { model | tableState = tableState }, Cmd.none )


handleHttpError : Http.Error -> String
handleHttpError httpError =
    case httpError of
        Http.NetworkError ->
            "Are you sure the server is running?"

        Http.Timeout ->
            "Request timed out!"

        Http.BadUrl url ->
            "Invalid URL: " ++ url

        Http.BadStatus response ->
            case response.status.code of
                401 ->
                    "Unauthorized"

                404 ->
                    "Not found"

                code ->
                    "Error Code: " ++ (toString code)

        Http.BadPayload message _ ->
            "JSON Decoder Error: " ++ message


githubApiUrl : Model -> String
githubApiUrl model =
    let
        userFilter =
            if String.isEmpty model.searchOptions.userFilter then
                ""
            else
                "+user:" ++ model.searchOptions.userFilter
    in
        "https://api.github.com/search/repositories?access_token="
            ++ Auth.token
            ++ "&q="
            ++ model.query
            ++ "+in:"
            ++ model.searchOptions.searchIn
            ++ "+stars:>="
            ++ (model.searchOptions.minStars |> toString)
            ++ userFilter
            ++ "+language:elm&sort=stars&order=desc"



-- SUBSCRIPTIONS


port responseFromGithubApiWithJS : (Decode.Value -> a) -> Sub a


decodeResponseFromJS : Decode.Value -> Msg
decodeResponseFromJS json =
    HandleGithubResponseFromJS (json |> Decode.decodeValue githubDecoder)


subscriptions : a -> Sub Msg
subscriptions =
    \_ -> responseFromGithubApiWithJS decodeResponseFromJS



-- CMDs


searchGithubApi : String -> Cmd Msg
searchGithubApi query =
    let
        getRequest =
            Http.get query githubDecoder
    in
        Http.send HandleGithubResponse getRequest


port searchGithubApiWithJS : String -> Cmd a



-- DECODERS


githubDecoder : Decoder (List SearchResult)
githubDecoder =
    Decode.at [ "items" ]
        (Decode.list
            (Decode.map3 SearchResult
                (Decode.field "id" Decode.int)
                (Decode.field "full_name" Decode.string)
                (Decode.field "stargazers_count" Decode.int)
            )
        )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ viewElmHubHeader
        , viewSearchElmHubs model
        , viewErrorMessage model.error
        , viewElmHubs model.tableState model.results
        ]


viewElmHubHeader : Html a
viewElmHubHeader =
    header []
        [ h1 [] [ text "ElmHub" ]
        , span [ class "tagline" ] [ text "Like GitHub, but for Elm things." ]
        ]


viewSearchElmHubs : Model -> Html Msg
viewSearchElmHubs model =
    div [ class "search" ]
        [ (SearchOptions.view model.searchOptions) |> Html.map SearchOptions
        , viewSearchInput model.query
        ]


viewSearchInput : String -> Html Msg
viewSearchInput query =
    div [ class "search-input" ]
        [ input [ class "search-query", onInput SetQuery, defaultValue query ] []
        , button [ class "search-button", onClick SearchElm ] [ text "Search Elm" ]
        , button [ class "search-button", onClick SearchJS ] [ text "Search JS" ]
        ]


viewErrorMessage : Maybe String -> Html a
viewErrorMessage msg =
    case msg of
        Just description ->
            div [ class "error" ] [ text description ]

        Nothing ->
            div [] [ text "" ]


viewElmHubs : Table.State -> List SearchResult -> Html Msg
viewElmHubs currentTableState results =
    Table.view tableConfig currentTableState results


tableConfig : Table.Config SearchResult Msg
tableConfig =
    Table.config
        { toId = .id >> toString
        , toMsg = SetTableState
        , columns = [ starsCustomColumn, nameCustomColumn, deleteCustomColumn ]
        }


starsCustomColumn : Table.Column SearchResult Msg
starsCustomColumn =
    Table.veryCustomColumn
        { name = "Stars"
        , viewData = viewStarsColumn
        , sorter = Table.increasingOrDecreasingBy (.stars >> negate)
        }


viewStarsColumn : SearchResult -> Table.HtmlDetails Msg
viewStarsColumn searchResult =
    Table.HtmlDetails []
        [ span
            [ class "star-count" ]
            [ searchResult.stars |> toString |> text ]
        ]


nameCustomColumn : Table.Column SearchResult Msg
nameCustomColumn =
    Table.veryCustomColumn
        { name = "Name"
        , viewData = viewNameColumn
        , sorter = Table.increasingOrDecreasingBy .name
        }


viewNameColumn : SearchResult -> Table.HtmlDetails Msg
viewNameColumn searchResult =
    Table.HtmlDetails []
        [ a
            [ href ("https://github.com/" ++ searchResult.name), target "_blank" ]
            [ text searchResult.name ]
        ]


deleteCustomColumn : Table.Column SearchResult Msg
deleteCustomColumn =
    Table.veryCustomColumn
        { name = ""
        , viewData = viewDeleteColumn
        , sorter = Table.unsortable
        }


viewDeleteColumn : SearchResult -> Table.HtmlDetails Msg
viewDeleteColumn searchResult =
    Table.HtmlDetails []
        [ button
            [ class "hide-result", onClick (DeleteById searchResult.id) ]
            [ text "X" ]
        ]
