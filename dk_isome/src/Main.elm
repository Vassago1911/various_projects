module Main exposing (main)

import Array
import Browser exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Random
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Task
import Time


type Msg
    = NoOp
    | OnTime Time.Posix


type alias Model =
    { level_boundary : { left : Int, bottom : Int, right : Int, top : Int }
    , camera : { left : Int, top : Int, width : Int, height : Int }
    , tiles : List (List Int)
    , seed : Random.Seed
    }


gen_int : Model -> ( Model, Int )
gen_int model =
    let
        cur_seed =
            model.seed

        ( new_int, seed0 ) =
            Random.step (Random.int 100 1500) cur_seed

        ( new_seed, _ ) =
            Random.step (Random.int -24987 36451) seed0
    in
    ( { model | seed = Random.initialSeed (19 * new_seed) }, new_int )


standard_label_list : List String
standard_label_list =
    [ "🐮"
    , "🦊"
    , "🐺"
    , "🐷"
    , "🐹"
    , "🐰"
    , "🐻"
    , "🐨"
    , "🐢"
    , "🐸"
    , "🦋"
    , "🦭"
    , "🐙"
    , "🐝"
    , "🌹"
    , "🌻"
    , "🌼"
    , "🪺"
    , "🍒"
    , "🍉"
    , "🌶️"
    , "🥨"
    , "🍟"
    , "🥗"
    , "🦞"
    , "🦑"
    , "🎃"
    , "🏆"
    , "🎨"
    , "🌍"
    , "🧭"
    , "🌋"
    , "🌝"
    , "🪐"
    , "🌈"
    , "⚡"
    , "🎵"
    , "📯"
    , "👑"
    , "💎"
    , "🎩"
    , "💰"
    , "💡"
    , "🕯️"
    , "🔑"
    , "🪬"
    , "🧿"
    , "🛋️"
    , "🛏️"
    , "🚪"
    , "🧬"
    , "🔬"
    , "📡"
    , "🥷"
    , "🧕"
    , "🧠"
    , "🦴"
    , "👀"
    , "✊"
    , "🖖"
    , "👽"
    , "👾"
    , "😈"
    , "✍️"
    , "🙏"
    , "🫶"
    , "🌾"
    , "🧚"
    , "🧜"
    , "🧛"
    , "🧞"
    , "🐞"
    , "🪲"
    , "🪱"
    , "🦠"
    , "💐"
    , "🕸️"
    , "🐌"
    , "🐜"
    , "☘️"
    , "🍀"
    , "🍄"
    , "🍇"
    , "🫒"
    , "🥑"
    , "🥝"
    , "🍍"
    , "🥜"
    , "🥦"
    , "🥒"
    ]


some_standard_label : Int -> String
some_standard_label ix =
    let
        labels =
            Array.fromList standard_label_list

        n =
            Array.length labels

        iix =
            modBy n ix

        label =
            Maybe.withDefault "H" (Array.get iix labels)
    in
    label


prestyle : Html Msg
prestyle =
    let
        my_css =
            """body, button, div, html, svg, img { background-color: #000;
            cursor: crosshair; font-family: monospace; font-size: 64px; display: block;
            position: absolute; top: 0.01%; left: 0.01%; width: 99.98%;
            height: 99.98%; fill: #999; color: #666; }"""
    in
    Html.node "style" [] [ Html.text my_css ]


stringy_viewbox : Model -> String
stringy_viewbox model =
    String.fromInt model.camera.left
        ++ " "
        ++ String.fromInt model.camera.top
        ++ " "
        ++ String.fromInt model.camera.width
        ++ " "
        ++ String.fromInt model.camera.height


view_model : Model -> Html Msg
view_model model =
    let
        svg_standard_header =
            [ viewBox (stringy_viewbox model) ]

        bg =
            rect
                [ fill "#000"
                , x "0"
                , y "0"
                , Svg.Attributes.width "2048"
                , Svg.Attributes.height "2048"
                , stroke "#0000"
                , strokeWidth "0"
                ]
                []

        level_boundary =
            rect
                [ fill "#090000"
                , x (String.fromInt model.level_boundary.left)
                , y (String.fromInt model.level_boundary.top)
                , Svg.Attributes.width
                    (String.fromInt (model.level_boundary.right - model.level_boundary.left))
                , Svg.Attributes.height
                    (String.fromInt (model.level_boundary.bottom - model.level_boundary.top))
                , stroke "#0099"
                , strokeWidth "1"
                ]
                []

        tilepos i j =
            let
                oi =
                    248

                oj =
                    200

                ci =
                    62

                cj =
                    96

                cj2 =
                    2 * cj
            in
            "M " ++ String.fromInt (ci * i + oi) ++ "," ++ String.fromInt (cj * modBy 2 i + cj2 * j + oj)

        tile_rel =
            let
                c =
                    47

                vc =
                    floor (0.75 * c)

                d =
                    floor (1.5 * c)

                s =
                    " m "
                        ++ String.fromInt (2 * c)
                        ++ ",0 l "
                        ++ String.fromInt -c
                        ++ ","
                        ++ String.fromInt -vc
                        ++ " l "
                        ++ String.fromInt -c
                        ++ ","
                        ++ String.fromInt vc
                        ++ " l "
                        ++ String.fromInt c
                        ++ ","
                        ++ String.fromInt vc
                        ++ " l "
                        ++ String.fromInt c
                        ++ ","
                        ++ String.fromInt -vc
                        ++ " z"
            in
            s

        tile i j =
            Svg.path
                [ fill "#26210060"
                , stroke "#111f"
                , strokeWidth "2"
                , Svg.Attributes.d (tilepos i j ++ tile_rel)
                ]
                []

        isotile i j =
            let
                c =
                    16

                v =
                    2 * c

                h =
                    5 * c

                w =
                    3 * c

                vstr =
                    String.fromInt v

                wstr =
                    String.fromInt w

                hstr =
                    String.fromInt h

                pos =
                    tilepos i j

                pth =
                    String.concat
                        [ "m -"
                        , wstr
                        , ",0 "
                        , " l 0,-"
                        , hstr
                        , " l "
                        , wstr
                        , ","
                        , vstr
                        , " l 0,"
                        , hstr
                        , " l -"
                        , wstr
                        , ",-"
                        , vstr
                        , " m "
                        , wstr
                        , ","
                        , vstr
                        , " l "
                        , wstr
                        , ",-"
                        , vstr
                        , " l 0,-"
                        , hstr
                        , " l -"
                        , wstr
                        , ","
                        , vstr
                        , " l 0,"
                        , hstr
                        , " m 0,-"
                        , hstr
                        , " l -"
                        , wstr
                        , ",-"
                        , vstr
                        , " l "
                        , wstr
                        , ",-"
                        , vstr
                        , " l "
                        , wstr
                        , ","
                        , vstr
                        , " l -"
                        , wstr
                        , ","
                        , vstr
                        ]

                {-
                   , " m "
                   , wstr
                   , ",-"
                   , vstr
                   , " l -"
                   , wstr
                   , ",-"
                   , vstr
                   , " l -"
                   , wstr
                   , ","
                   , vstr
                   , " l 0,"
                   , hstr
                   ]
                -}
            in
            Svg.path
                [ fill "#262100ff"
                , stroke "#111f"
                , strokeWidth "2"
                , Svg.Attributes.d (tilepos i j ++ pth)
                ]
                []

        tiles_col js i =
            List.map (isotile i) js

        tiles is js =
            List.concat (List.map (tiles_col js) is)

        svg_content =
            [ bg, level_boundary ] ++ tiles (List.reverse (List.range -1 10)) (List.reverse (List.range 0 10))
    in
    svg svg_standard_header svg_content


body : Model -> List (Html Msg)
body model =
    [ div [] (prestyle :: [ view_model model ]) ]


view : Model -> Browser.Document Msg
view model =
    { title = "DK Isometry 🎲", body = body model }


init : () -> ( Model, Cmd Msg )
init _ =
    let
        nmdl =
            { level_boundary = { left = 64, bottom = 1920 + 64, right = 1920 + 64, top = 64 }
            , camera = { left = 0, top = 0, width = 2048, height = 2048 }
            , seed = Random.initialSeed 0 --set below
            , tiles =
                [ [] ]
            }
    in
    ( nmdl
    , Task.perform OnTime Time.now
    )


gen_int_list : Model -> ( Model, List Int )
gen_int_list model =
    let
        gi mdl =
            Random.step (Random.int 0 2) mdl.seed

        gi_list mdl n res =
            case n of
                0 ->
                    ( mdl, res )

                _ ->
                    let
                        ( nint, nseed ) =
                            gi mdl

                        nmdl =
                            { mdl | seed = nseed }
                    in
                    gi_list nmdl (n - 1) (nint :: res)
    in
    gi_list model 4096 []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnTime ptime ->
            let
                nmdl =
                    { model
                        | seed = Random.initialSeed (Time.posixToMillis ptime)
                    }
            in
            ( nmdl
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


main =
    Browser.document
        { init = init, view = view, update = update, subscriptions = subscriptions }
