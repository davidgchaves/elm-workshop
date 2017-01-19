port module ElmHub exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, defaultValue, href, placeholder, selected, target, type_, value)
import Html.Events exposing (on, onClick, onInput)
import Json.Decode as Decode exposing (Decoder)
import Http
import Auth
import Html.Keyed as Keyed


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
    , minStars : Int
    , minStarsError : Maybe String
    , searchIn : String
    , userFilter : String
    }



-- MODEL


initialModel : Model
initialModel =
    { query = ""
    , results = []
    , error = Nothing
    , minStars = 5
    , minStarsError = Nothing
    , searchIn = "name"
    , userFilter = ""
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
    | SetMinStars String
    | SetSearchIn String
    | SetUserFilter String


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

        SetMinStars minStarsStr ->
            case String.toInt minStarsStr of
                Ok minStars ->
                    ( { model | minStars = minStars, minStarsError = Nothing }, Cmd.none )

                Err _ ->
                    ( { model | minStarsError = Just "Need a number!" }, Cmd.none )

        SetSearchIn searchIn ->
            ( { model | searchIn = searchIn }, Cmd.none )

        SetUserFilter userFilter ->
            ( { model | userFilter = userFilter }, Cmd.none )


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
            if String.isEmpty model.userFilter then
                ""
            else
                "+user:" ++ model.userFilter
    in
        "https://api.github.com/search/repositories?access_token="
            ++ Auth.token
            ++ "&q="
            ++ model.query
            ++ "+in:"
            ++ model.searchIn
            ++ "+stars:>="
            ++ (model.minStars |> toString)
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
    div [ class "content" ]
        [ viewElmHubHeader
        , viewSearchElmHubs model
        , viewErrorMessage model.error
        , viewElmHubs model.results
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
        [ viewSearchOptions model
        , div [ class "search-input" ]
            [ input [ class "search-query", onInput SetQuery, defaultValue model.query ] []
            , button [ class "search-button", onClick SearchElm ] [ text "Search Elm" ]
            , button [ class "search-button", onClick SearchJS ] [ text "Search JS" ]
            ]
        ]



-- BEGIN VIEWSEARCHOPTIONS


viewSearchOptions : Model -> Html Msg
viewSearchOptions model =
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



-- END VIEWSEARCHOPTIONS


viewErrorMessage : Maybe String -> Html a
viewErrorMessage msg =
    case msg of
        Just description ->
            div [ class "error" ] [ text description ]

        Nothing ->
            div [] [ text "" ]


viewElmHubs : List SearchResult -> Html Msg
viewElmHubs results =
    Keyed.ul [ class "results" ] (List.map viewSearchResults results)


viewSearchResults : SearchResult -> ( String, Html Msg )
viewSearchResults result =
    ( toString result.id
    , li []
        [ span [ class "star-count" ]
            [ result.stars |> toString |> text ]
        , a [ href ("https://github.com/" ++ result.name), target "_blank" ]
            [ text result.name ]
        , button [ class "hide-result", onClick (DeleteById result.id) ] [ text "X" ]
        ]
    )
