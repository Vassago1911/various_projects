module BootCss exposing (btn, prestyle)

import Html exposing (Html, button, node, text)
import Html.Attributes exposing (class, style)


btn : Html msg
btn =
    button
        [ style "color" "#000f"
        , style "background" "#445"
        , style "margin" "2px"
        , style "cursor" "pointer"
        , style "border" "solid"
        , style "border-color" "#111"
        , class "hoverable"
        ]
        [ text "HALLO" ]


prestyle : Html msg
prestyle =
    let
        my_css =
            """* {
              font-family: monospace;
              font-size: 16px;
              font-weight: bold;
            }
            .hoverable:hover {
                border-color: #902
            }
            h1 {
              font-size: 24px;
            }
            body {
              color: #eee;
              background: #110808;
            }
            a {
              color: #809fff;
            }

            body.light-theme {
              color: #222;
              background: #fff;
            }
            body.light-theme a {
              color: #0033cc;
            }
            """
    in
    Html.node "style" [] [ Html.text my_css ]
