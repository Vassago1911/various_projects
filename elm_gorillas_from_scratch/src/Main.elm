module Main exposing (main)

import Browser exposing (Document, document)
import Browser.Events exposing (onKeyDown)
import Css exposing (..)
import Css.Global exposing (body, global, html)
import GorillaSprite exposing (gorilla)
import Html.Styled exposing (..)
import Svg.Styled exposing (..)
import Svg.Styled.Attributes exposing (..)


type alias Model =
    {}


initialModel =
    {}


type Msg
    = NoOp


type alias StarData =
    { x : Int
    , y : Int
    , color_str : String
    , scale : Float
    }


star : StarData -> Svg Msg
star { x, y, color_str, scale } =
    let
        star_ posx posy =
            [ ldr posx posy 8
            , lur posx posy 8
            , lud posx posy 8
            , llr posx posy 8
            ]

        ldr posx posy len =
            Svg.Styled.line
                [ Svg.Styled.Attributes.stroke color_str
                , Svg.Styled.Attributes.strokeWidth "3px"
                , Svg.Styled.Attributes.x1 (String.fromInt (posx - len))
                , Svg.Styled.Attributes.x2 (String.fromInt (posx + len))
                , Svg.Styled.Attributes.y1 (String.fromInt (posy - len))
                , Svg.Styled.Attributes.y2 (String.fromInt (posy + len))
                ]
                []

        lur posx posy len =
            Svg.Styled.line
                [ Svg.Styled.Attributes.stroke color_str
                , Svg.Styled.Attributes.strokeWidth "3px"
                , Svg.Styled.Attributes.x1 (String.fromInt (posx + len))
                , Svg.Styled.Attributes.x2 (String.fromInt (posx - len))
                , Svg.Styled.Attributes.y1 (String.fromInt (posy - len))
                , Svg.Styled.Attributes.y2 (String.fromInt (posy + len))
                ]
                []

        lud posx posy len =
            Svg.Styled.line
                [ Svg.Styled.Attributes.stroke color_str
                , Svg.Styled.Attributes.strokeWidth "3px"
                , Svg.Styled.Attributes.x1 (String.fromInt posx)
                , Svg.Styled.Attributes.x2 (String.fromInt posx)
                , Svg.Styled.Attributes.y1 (String.fromInt (posy - 2 * len))
                , Svg.Styled.Attributes.y2 (String.fromInt (posy + 2 * len))
                ]
                []

        llr posx posy len =
            Svg.Styled.line
                [ Svg.Styled.Attributes.stroke color_str
                , Svg.Styled.Attributes.strokeWidth "3px"
                , Svg.Styled.Attributes.x1 (String.fromInt (posx - 2 * len))
                , Svg.Styled.Attributes.x2 (String.fromInt (posx + 2 * len))
                , Svg.Styled.Attributes.y1 (String.fromInt posy)
                , Svg.Styled.Attributes.y2 (String.fromInt posy)
                ]
                []
    in
    Svg.Styled.foreignObject
        [ Svg.Styled.Attributes.x (String.fromInt x)
        , Svg.Styled.Attributes.y (String.fromInt y)
        , Svg.Styled.Attributes.width "64"
        , Svg.Styled.Attributes.height "64"
        , Svg.Styled.Attributes.transform ("scale(" ++ String.fromFloat scale ++ ")")
        ]
        [ Svg.Styled.svg
            [ Svg.Styled.Attributes.viewBox "0 0 64 64"
            ]
            (star_ 32 32)
        ]


some_color : Int -> String
some_color ix =
    case modBy 6 ix of
        0 ->
            "#6006"

        1 ->
            "#3406"

        2 ->
            "#1356"

        3 ->
            "#1066"

        4 ->
            "#2236"

        5 ->
            "#5136"

        _ ->
            "#2426"


star_cds : List StarData
star_cds =
    let
        xs =
            List.map (\x -> 64 * x) (List.range 0 64)

        ys =
            List.map (\x -> 64 * x) (List.range 0 32)

        append_ys_to_x ix =
            List.map (\y -> ( ix, y )) ys

        xys =
            List.concat (List.map append_ys_to_x xs)

        clr x y =
            some_color (modBy 23 (7 * x + 3 * y))

        scl x y =
            1.0 + 0.2 * sin (toFloat (2 * x + 7) + toFloat (3 * y + 15))

        coods =
            List.map (\( x, y ) -> { x = x - 512, y = y - 64, color_str = clr x y, scale = scl x y }) xys
    in
    coods


starry_bg : List (Svg Msg)
starry_bg =
    List.map (\t -> star t)
        star_cds


svg_content : List (Svg Msg)
svg_content =
    [ rect
        [ Svg.Styled.Attributes.fill "#000"
        , Svg.Styled.Attributes.x "0"
        , Svg.Styled.Attributes.y "0"
        , Svg.Styled.Attributes.width "2048"
        , Svg.Styled.Attributes.height "2048"
        , Svg.Styled.Attributes.stroke "#101"
        , Svg.Styled.Attributes.strokeWidth "1px"
        , Svg.Styled.Attributes.clipPath "url(#clipRect)"
        ]
        []
    , Svg.Styled.clipPath [ Svg.Styled.Attributes.id "clipRect" ]
        [ rect
            [ Svg.Styled.Attributes.x "0"
            , Svg.Styled.Attributes.y "0"
            , Svg.Styled.Attributes.width "2048"
            , Svg.Styled.Attributes.height "2048"
            ]
            []
        ]
    ]
        ++ starry_bg
        ++ [ gorilla 0 0
           , gorilla (2048 - 140) 0
           ]


svg_frame : Html Msg
svg_frame =
    svg
        [ Svg.Styled.Attributes.viewBox "0 0 2048 2048"
        , Svg.Styled.Attributes.width "98vw"
        , Svg.Styled.Attributes.height "98vh"
        , Svg.Styled.Attributes.clipPath "url(#clipRect)"
        ]
        svg_content


update : Msg -> Model -> Model
update _ _ =
    {}


content : Html Msg
content =
    div []
        [ global
            [ html
                [ Css.backgroundColor (rgb 0 0 0)
                , Css.fontFamilies [ "monospace" ]
                , Css.fontSize (px 12)
                , Css.fontWeight normal
                ]
            ]
        , global
            [ body
                [ Css.width (vw 100)
                , Css.height (vh 100)
                , Css.property "display" "flex"
                , Css.property "justify-content" "center"
                , Css.property "align-items" "center"
                ]
            ]
        , svg_frame
        ]


main : Program () Model Msg
main =
    Browser.document
        { view = \m -> { title = "🔮Gorillas💡", body = [ Html.Styled.toUnstyled content ] }
        , update = \msg -> \mdl -> ( update msg mdl, Cmd.none )
        , init = \_ -> ( initialModel, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
