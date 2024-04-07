module Stars exposing (starry_bg)

import Svg.Styled exposing (..)
import Svg.Styled.Attributes exposing (..)


type alias StarData =
    { x : Int
    , y : Int
    , color_str : String
    , scale : Float
    }


star : StarData -> Svg msg
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


star_color : Int -> String
star_color ix =
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
            star_color (modBy 23 (7 * x + 3 * y))

        scl x y =
            1.0 + 0.2 * sin (toFloat (2 * x + 7) + toFloat (3 * y + 15))

        coods =
            List.map (\( x, y ) -> { x = x - 512, y = x - y - 64, color_str = clr x y, scale = scl x y }) xys
                ++ List.map (\( x, y ) -> { x = 2048 + 512 - x - y, y = 2048 + 128 - y, color_str = clr x y, scale = scl x y }) xys
    in
    coods


starry_bg : List (Svg msg)
starry_bg =
    List.map (\t -> star t)
        star_cds
