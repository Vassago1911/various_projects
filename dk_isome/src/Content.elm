module Content exposing (content)

import Svg exposing (Svg)
import SvgSnippets exposing (iso_tile)


content : List (Svg msg)
content =
    [ iso_tile 512 512
    , iso_tile 768 568
    ]
