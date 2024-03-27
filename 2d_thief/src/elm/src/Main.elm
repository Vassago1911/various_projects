module Main exposing (main)

import Browser exposing (..)
import Html exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)


type Msg
    = NoOp


type alias Model =
    { level_boundary : { left : Int, bottom : Int, right : Int, top : Int }
    , camera : { left : Int, top : Int, width : Int, height : Int }
    }


prestyle : Html Msg
prestyle =
    let
        my_css =
            """body, button, div, html, svg { background-color: #000; cursor: crosshair; font-family: monospace; font-size: 64; display: block; position: absolute; top: 0.01%; left: 0.01%; width: 99.98%; height: 99.98%; fill: #999; color: #666; }"""
    in
    Html.node "style" [] [ Html.text my_css ]


svg_room : Int -> Int -> Int -> Int -> Svg Msg
svg_room p_x p_y p_width p_height =
    rect
        [ fill "#111"
        , x (String.fromInt p_x)
        , y (String.fromInt p_y)
        , width (String.fromInt p_width)
        , height (String.fromInt p_height)
        , stroke "#222"
        , strokeWidth (String.fromInt 8)
        ]
        []


standard_svg_room : Int -> Int -> Int -> Svg Msg
standard_svg_room p_x p_y p_width =
    svg_room p_x p_y p_width 64


jail_intro : Model -> Html Msg
jail_intro model =
    let
        stringy_viewbox =
            String.fromInt model.camera.left
                ++ " "
                ++ String.fromInt model.camera.top
                ++ " "
                ++ String.fromInt model.camera.width
                ++ " "
                ++ String.fromInt model.camera.height

        svg_standard_header =
            [ viewBox stringy_viewbox ]

        bg =
            rect [ fill "#333", x "0", y "0", width "2048", height "2048", stroke "#666", strokeWidth "1" ] []

        level_boundary =
            rect
                [ fill "#090000"
                , x (String.fromInt model.level_boundary.left)
                , y (String.fromInt model.level_boundary.top)
                , width (String.fromInt (model.level_boundary.right - model.level_boundary.left))
                , height (String.fromInt (model.level_boundary.bottom - model.level_boundary.top))
                , stroke "#000"
                , strokeWidth "8"
                ]
                []

        rooms =
            [ standard_svg_room (1920 - 128 - 16 - 8 - 512) (1920 - 64 - 16 - 8) (64 + 512)
            , standard_svg_room (1920 - 128 - 16 - 8) (1920 - 8) 128
            , standard_svg_room (1920 - 8) (1920 - 8) 64
            , standard_svg_room (1920 - 64 - 8) (1920 - 64 - 16 - 8) 128
            , standard_svg_room (1920 - 2 * 128 - 16 - 3 * 8) (1920 - 8) 128
            , standard_svg_room (1920 - 3 * 128 - 16 - 5 * 8) (1920 - 8) 128
            , standard_svg_room (1920 - 4 * 128 - 16 - 7 * 8) (1920 - 8) 128
            , standard_svg_room (1920 - 5 * 128 - (512 - 128) - 16 - 9 * 8) (1920 - 8) 512
            , standard_svg_room (1920 - 5 * 128 - (2 * 512 - 128) - 16 - 11 * 8) (1920 - 8) 512
            , svg_room (1920 - 13 * 128 - 16 - 13 * 8 - 64) (1920 - 8 - 64) (128 + 64) 128

            {- , standard_svg_room (1920 - 13 * 128 - 16 - 13 * 8 - 64) (1920 - 64 - 16 - 8) 512
               , standard_svg_room (1920 - 9 * 128 - 16 - 11 * 8 - 64) (1920 - 64 - 16 - 8) 512
            -}
            , standard_svg_room (1920 - 5 * 128 - 16 - 9 * 8 - 64) (1920 - 64 - 16 - 8) 112
            ]

        svg_content =
            [ bg, level_boundary ] ++ rooms
    in
    svg svg_standard_header svg_content


content : Model -> Int -> Html Msg
content model i =
    let
        stringy_viewbox =
            String.fromInt model.camera.left
                ++ " "
                ++ String.fromInt model.camera.top
                ++ " "
                ++ String.fromInt model.camera.width
                ++ " "
                ++ String.fromInt model.camera.height

        svg_standard_header =
            [ viewBox stringy_viewbox ]

        svg_bg =
            [ rect [ fill "#111", x "0", y "0", width "2048", height "2048", stroke "#666", strokeWidth "1" ] [] ]
    in
    case i of
        _ ->
            jail_intro model


body : Model -> Int -> List (Html Msg)
body model i =
    [ div [] (prestyle :: [ content model i ]) ]


view : Model -> Browser.Document Msg
view model =
    { title = "🍜🐿️", body = body model 0 }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { level_boundary = { left = 64, bottom = 1920 + 64, right = 1920 + 64, top = 64 }
      , camera = { left = 0, top = 0, width = 2048, height = 2048 }
      }
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
        { init = init, view = view, update = update, subscriptions = subscriptions }
