module Main exposing (main)

import BootCss exposing (btn, prestyle)
import Browser exposing (Document, document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


type alias Model =
    { l : List Int }


type Msg
    = NoOp


content : List (Html Msg)
content =
    [ btn, btn, btn ]


html_view : Model -> Html Msg
html_view _ =
    div [ id "frame" ] (prestyle :: content)


main =
    document
        { init = init
        , view = \m -> { title = "http-api tests, beep!", body = [ html_view m ] }
        , update = update
        , subscriptions = subs
        }


subs : Model -> Sub Msg
subs _ =
    Sub.none


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model [ floor 0 ], Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( Model [ floor 0 ], Cmd.none )
