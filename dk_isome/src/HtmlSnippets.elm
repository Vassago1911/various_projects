module HtmlSnippets exposing (prestyle, svg_to_html_frame, view_model, view_model_type)

import Browser exposing (Document)
import Html
import Svg
import Svg.Attributes exposing (viewBox)
import SvgSnippets exposing (CameraConstants, LevelBoundary, level_boundary, standard_background, stringy_viewbox)


prestyle : Html.Html msg
prestyle =
    let
        my_css =
            """body, button, div, html, svg, img { background-color: #000;
            cursor: crosshair; font-family: monospace; font-size: 64px; display: block;
            position: absolute; top: 0.01%; left: 0.01%; width: 99.98%;
            height: 99.98%; fill: #999; color: #666; }"""
    in
    Html.node "style" [] [ Html.text my_css ]


view_model : CameraConstants -> LevelBoundary -> List (Svg.Svg msg) -> Html.Html msg
view_model ccs lvl svg_content =
    let
        svg_standard_header =
            [ viewBox (stringy_viewbox ccs) ]
    in
    Svg.svg svg_standard_header svg_content


svg_to_html_frame : CameraConstants -> LevelBoundary -> List (Svg.Svg msg) -> Html.Html msg
svg_to_html_frame ccs lvl content =
    Html.div []
        (prestyle
            :: [ view_model
                    ccs
                    lvl
                    content
               ]
        )


type alias Model msg =
    { level_boundary : LevelBoundary
    , camera : CameraConstants
    , content : List (Svg.Svg msg)
    , title : String
    }


view_model_type : Model msg -> Document msg
view_model_type model =
    view_piper model.level_boundary model.camera model.title model.content


view_piper : LevelBoundary -> CameraConstants -> String -> List (Svg.Svg msg) -> Document msg
view_piper lvl ccs ttl cont =
    let
        std_content =
            [ standard_background, level_boundary lvl ]

        svg_frame =
            \ct -> [ svg_to_html_frame ccs lvl ct ]

        res =
            { title = ttl
            , body =
                svg_frame
                    (std_content
                        ++ cont
                    )
            }
    in
    res
