module Main2 exposing (main)

import Browser exposing (document)
import Content exposing (content)
import HtmlSnippets
    exposing
        ( prestyle
        , svg_to_html_frame
        , view_model
        , view_model_type
        )
import Svg exposing (Svg)
import SvgSnippets
    exposing
        ( CameraConstants
        , DrawConstants
        , DrawInfo
        , LevelBoundary
        , PositionConstants
        , iso_tile
        )


type Msg
    = NoOp


type alias Model =
    { level_boundary : LevelBoundary
    , camera : CameraConstants
    , content : List (Svg Msg)
    , title : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    let
        nmdl =
            { level_boundary = LevelBoundary { left = 64, bottom = 1920 + 64, right = 1920 + 64, top = 64 }
            , camera = CameraConstants { left = 0, top = 0, width = 2048, height = 2048 }
            , content = content
            , title = "DK Isometry 2 🎲"
            }
    in
    ( nmdl
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


main =
    Browser.document
        { init = init, view = view_model_type, update = update, subscriptions = subscriptions }
