module Main exposing (main)

import Browser exposing (Document, document)
import Browser.Events exposing (onKeyDown)
import Css exposing (..)
import Css.Global exposing (body, global, html)
import GorillaSprite exposing (gorilla)
import Html.Styled exposing (..)
import Stars exposing (starry_bg)
import Svg.Styled exposing (..)
import Svg.Styled.Attributes exposing (..)


type alias Model =
    {}


initialModel =
    {}


type Msg
    = NoOp


mod1 : Float -> Float
mod1 s =
    s - toFloat (floor s)


ht2048 : Float -> Int
ht2048 s =
    128 + floor (1417 * sin (mod1 (17 * s)))


step128 : Float -> Int
step128 s =
    64 + floor (256 * mod1 (256 * s))


skyscrapers : List (Svg Msg)
skyscrapers =
    let
        theta =
            832040.0 / 514229.0

        theta2 =
            theta / 2

        heights =
            List.map (\n -> ht2048 (theta2 + theta * toFloat n + theta2 * toFloat (modBy 3 n))) (List.range 0 256)

        left0 =
            -32

        dlefts =
            List.map (\n -> step128 (theta2 + theta * toFloat n + (0.0415962 * theta2) * toFloat (modBy 5 n))) (List.range 0 257)

        lefts =
            List.map (\n -> List.sum (List.take n dlefts)) (List.range 0 256)

        lhs =
            List.map3 (\x -> \y -> \z -> { left = x, top = y, dleft = z }) lefts heights dlefts

        skscrp_rect x y d =
            [ rect
                [ Svg.Styled.Attributes.fill "#111"
                , Svg.Styled.Attributes.x (String.fromInt x)
                , Svg.Styled.Attributes.y (String.fromInt y)
                , Svg.Styled.Attributes.width (String.fromInt d)
                , Svg.Styled.Attributes.height "2048"
                , Svg.Styled.Attributes.stroke "#222"
                , Svg.Styled.Attributes.strokeWidth "1px"
                ]
                []
            ]

        skscrps =
            List.concat (List.map3 (\left -> \top -> \dleft -> skscrp_rect left top dleft) lefts heights dlefts)
    in
    skscrps


svg_content : List (Svg Msg)
svg_content =
    let
        frame =
            [ rect
                [ Svg.Styled.Attributes.fill "#000"
                , Svg.Styled.Attributes.x "2048"
                , Svg.Styled.Attributes.y "-2048"
                , Svg.Styled.Attributes.width "2048"
                , Svg.Styled.Attributes.height "9192"
                , Svg.Styled.Attributes.strokeWidth "0px"
                ]
                []
            , rect
                [ Svg.Styled.Attributes.fill "#000"
                , Svg.Styled.Attributes.x "-2048"
                , Svg.Styled.Attributes.y "-2048"
                , Svg.Styled.Attributes.width "2048"
                , Svg.Styled.Attributes.height "9192"
                , Svg.Styled.Attributes.strokeWidth "0px"
                ]
                []
            , rect
                [ Svg.Styled.Attributes.fill "#000"
                , Svg.Styled.Attributes.x "-2048"
                , Svg.Styled.Attributes.y "2048"
                , Svg.Styled.Attributes.width "9192"
                , Svg.Styled.Attributes.height "2048"
                , Svg.Styled.Attributes.strokeWidth "0px"
                ]
                []
            , rect
                [ Svg.Styled.Attributes.fill "#000"
                , Svg.Styled.Attributes.x "-2048"
                , Svg.Styled.Attributes.y "-2048"
                , Svg.Styled.Attributes.width "9192"
                , Svg.Styled.Attributes.height "2048"
                , Svg.Styled.Attributes.strokeWidth "0px"
                ]
                []
            ]
    in
    [ rect
        [ Svg.Styled.Attributes.fill "#000"
        , Svg.Styled.Attributes.x "0"
        , Svg.Styled.Attributes.y "0"
        , Svg.Styled.Attributes.rx "16"
        , Svg.Styled.Attributes.ry "16"
        , Svg.Styled.Attributes.width "2048"
        , Svg.Styled.Attributes.height "2048"
        , Svg.Styled.Attributes.stroke "#6662"
        , Svg.Styled.Attributes.strokeWidth "8px"
        ]
        []
    ]
        ++ starry_bg
        ++ skyscrapers
        ++ [ gorilla 0 0
           , gorilla (2048 - 140) 0
           ]
        ++ frame


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
        , svg
            [ Svg.Styled.Attributes.viewBox "0 0 2048 2048"
            , Svg.Styled.Attributes.width "98vw"
            , Svg.Styled.Attributes.height "98vh"
            ]
            svg_content
        ]


main : Program () Model Msg
main =
    Browser.document
        { view = \m -> { title = "🔮Gorillas💡", body = [ Html.Styled.toUnstyled content ] }
        , update = \msg -> \mdl -> ( update msg mdl, Cmd.none )
        , init = \_ -> ( initialModel, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
