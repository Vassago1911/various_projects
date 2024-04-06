module Main exposing (main)

import Browser exposing (Document, document)
import Browser.Events exposing (onKeyDown)
import Css exposing (..)
import Css.Global exposing (body, global, html)
import Html.Styled exposing (..)
import Svg.Styled exposing (..)
import Svg.Styled.Attributes exposing (..)


type alias Model =
    {}


initialModel =
    {}


type Msg
    = NoOp


svg_content : List (Svg Msg)
svg_content =
    [ Svg.Styled.text_ [] [ Svg.Styled.text "hallo" ] ]


svg_frame : Html Msg
svg_frame =
    svg [ Svg.Styled.Attributes.viewBox "0 0 2048 2048" ] svg_content


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
