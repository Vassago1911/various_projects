module Main exposing (main)

import Browser exposing (Document, document)
import Css exposing (..)
import Css.Global exposing (body, global, html)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, src, title)
import Svg.Styled exposing (..)
import Svg.Styled.Attributes as SvgAttributes


{-| A plain old record holding a couple of theme colors.
-}
theme :
    { bg_color : Color
    , navbar_bg : Color
    , button_bg_color : Color
    , secondary : Color
    , primary : Color
    , font_dark : Color
    , font_hover_light : Color
    , font_light : Color
    }
theme =
    { bg_color = rgb 20 10 10
    , navbar_bg = rgb 0 0 0
    , button_bg_color = rgb 50 70 70
    , primary = hex "201"
    , secondary = rgb 250 240 230
    , font_dark = rgb 15 10 10
    , font_light = rgb 200 180 200
    , font_hover_light = rgb 220 200 230
    }


{-| A reusable button which has some styles pre-applied to it.
-}
btn : List (Html.Styled.Attribute msg) -> List (Html msg) -> Html msg
btn =
    Html.Styled.styled button
        [ margin (px 1)
        , color theme.font_light
        , backgroundColor theme.button_bg_color
        , border3 (px 1) solid (rgb 32 32 32)
        , borderRadius (px 64)
        , hover
            [ fontWeight bold
            , color theme.font_hover_light
            , backgroundColor (rgba 64 20 128 0.75)

            --, textDecoration underline
            ]
        ]


{-| A reusable button which has some styles pre-applied to it.
-}
pan_btn : List (Html.Styled.Attribute msg) -> List (Html msg) -> Html msg
pan_btn =
    Html.Styled.styled button
        [ margin (px 1)
        , color theme.font_light
        , backgroundColor (rgb 10 10 10)
        , border3 (px 0) solid (rgb 32 32 32)
        , borderRadius (px 64)
        , hover
            [ fontWeight bold
            , color theme.font_hover_light
            , backgroundColor (rgba 96 16 32 0.75)

            --, textDecoration underline
            ]
        ]


{-| A reusable style. Css.batch combines multiple styles into one, much
like mixins in CSS preprocessors.
-}
paragraphFont : Style
paragraphFont =
    Css.batch
        [ fontFamilies [ "monospace" ]
        , fontSize (px 8)
        , fontWeight normal
        ]


main_svg : Html Msg
main_svg =
    svg [ SvgAttributes.viewBox "0 0 2048 2048" ]
        [ rect
            [ SvgAttributes.x "0"
            , SvgAttributes.y "0"
            , SvgAttributes.width "2048"
            , SvgAttributes.height "2048"
            , SvgAttributes.fill "#110"
            ]
            []
        , path
            [ SvgAttributes.fill "#100"
            , SvgAttributes.strokeWidth "0"
            , SvgAttributes.d "M 2048,0 l -2048,2048 L 0,0 z"
            ]
            []
        , path
            [ SvgAttributes.fill "#000"
            , SvgAttributes.strokeWidth "0"
            , SvgAttributes.d "M 2048,0 l -2048,2048 L 2048,2048 z"
            ]
            []
        ]


view : Model -> Html Msg
view _ =
    div
        [ Html.Styled.Attributes.css
            [ property "display" "grid"
            , property "grid-gap" "8px"
            , property "grid-template-areas"
                """
        "- head logo"
        "navl main noti"
        "foot foot help"
        """
            , property "grid-template-rows" "5vh 86vh 4vh"
            , property "grid-template-columns" "5vw 86vw 4vw"
            ]
        ]
        [ global [ html [ backgroundColor (rgb 0 0 0), fontFamilies [ "monospace" ], fontSize (px 12), fontWeight normal ] ]
        , global [ body [ width (vw 100), height (vh 100), property "display" "flex", property "justify-content" "center", property "align-items" "center" ] ]
        , div
            [ css
                [ property "grid-area" "logo"
                ]
            , Html.Styled.Attributes.title "Don't disturb the squirrel 🐿️ 💭"
            ]
            [ img
                [ src "desk_squirrel.svg"
                , css
                    [ borderRadius (px 512)
                    , hover [ backgroundColor (rgb 32 64 32) ]
                    , width (vw 5)
                    , height (vh 5)
                    , transform (scaleX 1)
                    ]
                ]
                []
            ]
        , header
            [ css
                [ property "grid-area" "head"
                , textAlign right

                --, border3 (px 2) solid (rgba 142 96 128 0.3)
                --, borderRadius (px 4)
                , color theme.font_light
                ]
            ]
            [ btn [ css [ fontSize (px 32) ], Html.Styled.Attributes.title "click_here" ] [ Html.Styled.text "📚" ]
            , btn [ css [ fontSize (px 32) ], Html.Styled.Attributes.title "click_here" ] [ Html.Styled.text "💸" ]
            , btn [ css [ fontSize (px 32) ], Html.Styled.Attributes.title "click_here" ] [ Html.Styled.text "🥼" ]
            , btn [ css [ fontSize (px 32) ], Html.Styled.Attributes.title "click_here" ] [ Html.Styled.text "🕸️" ]
            , btn [ css [ fontSize (px 32) ], Html.Styled.Attributes.title "click_here" ] [ Html.Styled.text "💩" ]
            , btn [ css [ fontSize (px 32) ], Html.Styled.Attributes.title "click_here" ] [ Html.Styled.text "🤦" ]
            , btn [ css [ fontSize (px 32) ], Html.Styled.Attributes.title "click_here" ] [ Html.Styled.text "🔬" ]
            , btn [ css [ fontSize (px 32) ], Html.Styled.Attributes.title "click_here" ] [ Html.Styled.text "🏴\u{200D}☠️" ]
            , btn [ css [ fontSize (px 32) ], Html.Styled.Attributes.title "click_here" ] [ Html.Styled.text "🌋" ]
            , btn [ css [ fontSize (px 32) ], Html.Styled.Attributes.title "click_here" ] [ Html.Styled.text "🃏" ]
            ]
        , nav
            [ css
                [ property "grid-area" "navl"
                ]
            ]
            [ btn [ css [ fontSize (px 16) ], Html.Styled.Attributes.title "click here" ] [ Html.Styled.text "🐿️" ]
            , btn [ css [ fontSize (px 16) ], Html.Styled.Attributes.title "click here" ] [ Html.Styled.text "🐘" ]
            , btn [ css [ fontSize (px 16) ], Html.Styled.Attributes.title "click here" ] [ Html.Styled.text "🐳" ]
            , btn [ css [ fontSize (px 16) ], Html.Styled.Attributes.title "click here" ] [ Html.Styled.text "🦫" ]
            , btn [ css [ fontSize (px 16) ], Html.Styled.Attributes.title "click here" ] [ Html.Styled.text "🦜" ]
            , btn [ css [ fontSize (px 16) ], Html.Styled.Attributes.title "click here" ] [ Html.Styled.text "🦆" ]
            , btn [ css [ fontSize (px 16) ], Html.Styled.Attributes.title "click here" ] [ Html.Styled.text "🦭" ]
            , btn [ css [ fontSize (px 16) ], Html.Styled.Attributes.title "click here" ] [ Html.Styled.text "🐇" ]
            , btn [ css [ fontSize (px 16) ], Html.Styled.Attributes.title "click here" ] [ Html.Styled.text "🐀" ]
            ]
        , main_
            [ css
                [ property "grid-area" "main"
                , border3 (px 1) solid (rgba 32 32 0 0.4)
                , borderRadius (px 4)
                , margin (px 16)
                , overflowX hidden
                , overflowY hidden
                ]
            ]
            [ div [ css [ textAlign right ] ]
                [ pan_btn [] [ Html.Styled.text "🔼" ]
                , pan_btn [] [ Html.Styled.text "🔽" ]
                , pan_btn [] [ Html.Styled.text "⬅️" ]
                , pan_btn [] [ Html.Styled.text "➡️" ]
                , pan_btn [] [ Html.Styled.text "➕" ]
                , pan_btn [] [ Html.Styled.text "➖" ]
                , main_svg
                ]
            ]
        , nav
            [ css
                [ property "grid-area" "noti"
                , textAlign center
                , border3 (px 2) solid (rgba 96 96 128 0.1)
                , borderRadius (px 4)
                , color theme.font_light
                ]
            ]
            [ btn [ css [ fontSize (px 12) ], Html.Styled.Attributes.title "click here" ] [ Html.Styled.text "🥜" ]
            , btn [ css [ fontSize (px 12) ], Html.Styled.Attributes.title "click here" ] [ Html.Styled.text "🥥" ]
            , btn [ css [ fontSize (px 12) ], Html.Styled.Attributes.title "click here" ] [ Html.Styled.text "🌰" ]
            , btn [ css [ fontSize (px 12) ], Html.Styled.Attributes.title "click here" ] [ Html.Styled.text "🍩" ]
            , btn [ css [ fontSize (px 12) ], Html.Styled.Attributes.title "click here" ] [ Html.Styled.text "🔩" ]
            , btn [ css [ fontSize (px 12) ], Html.Styled.Attributes.title "click here" ] [ Html.Styled.text "🍉" ]
            ]
        , footer
            [ css
                [ property "grid-area" "foot"
                , textAlign left
                ]
            ]
            [ btn [ css [ fontSize (px 16) ], Html.Styled.Attributes.title "click_here" ] [ Html.Styled.text "✉️" ] ]
        , nav
            [ css
                [ property "grid-area" "help"
                , textAlign right
                , color theme.font_light
                ]
            ]
            [ btn [ css [ fontSize (px 16) ], Html.Styled.Attributes.title "click_here" ] [ Html.Styled.text "🏥" ] ]
        ]


main : Program () Model Msg
main =
    Browser.document
        { view = \m -> { title = "🔮Harbinger💡", body = List.map Html.Styled.toUnstyled [ view m ] }
        , update = update
        , init = \_ -> ( initialModel, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


type Msg
    = DoSomething


type alias Model =
    ()


initialModel : Model
initialModel =
    ()
