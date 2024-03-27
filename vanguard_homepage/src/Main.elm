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
    , node_coods : List ( Int, Int )
    , current_seed : Int
    , new_labels : List String
    }


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

        node x y =
            circle
                [ fill "#090000"
                , cx (String.fromInt (modBy 1792 x + 128))
                , cy (String.fromInt (modBy 1792 y + 128))
                , r "16"
                , Svg.Attributes.width
                    (String.fromInt (model.level_boundary.right - model.level_boundary.left))
                , Svg.Attributes.height
                    (String.fromInt (model.level_boundary.bottom - model.level_boundary.top))
                , stroke "#0291"
                , strokeWidth "0"
                ]
                []

        node_label x y ix =
            Svg.text_
                [ Svg.Attributes.x (String.fromInt (modBy 1792 x - 4))
                , Svg.Attributes.y (String.fromInt (modBy 1792 y + 15))
                , Svg.Attributes.fontSize "48px"
                ]
                [ Svg.text (some_standard_label ix) ]

        node_from_tuple xx =
            node (Tuple.first xx) (Tuple.second xx)

        label_from_tuple xx ix =
            node_label (Tuple.first xx) (Tuple.second xx) ix

        nodes =
            List.map node_from_tuple model.node_coods

        labels =
            List.map2 label_from_tuple model.node_coods (List.range 0 (List.length model.node_coods))

        svg_content =
            [ bg, level_boundary ] ++ nodes ++ labels
    in
    svg svg_standard_header svg_content


body : Model -> List (Html Msg)
body model =
    [ div [] (prestyle :: [ view_model model ]) ]


view : Model -> Browser.Document Msg
view model =
    { title = "Toppyng🎂", body = body model }


gen_int : Model -> ( Model, Int )
gen_int model =
    let
        cur_seed =
            model.current_seed

        ( new_int, seed0 ) =
            Random.step (Random.int 100 1500) (Random.initialSeed cur_seed)

        ( new_seed, _ ) =
            Random.step (Random.int -24987 36451) seed0
    in
    ( { model | current_seed = 19 * new_seed }, new_int )


gen_int_pair : Model -> ( Model, ( Int, Int ) )
gen_int_pair model =
    let
        ( mdl0, i0 ) =
            gen_int model

        ( mdl1, i1 ) =
            gen_int mdl0
    in
    ( mdl1, ( i0, i1 ) )


gen_int_list : Model -> Int -> ( Model, List ( Int, Int ) )
gen_int_list model n =
    let
        ( nmdl, pair ) =
            gen_int_pair model
    in
    ( nmdl
    , if n == 0 then
        []

      else
        [ pair ] ++ Tuple.second (gen_int_list nmdl (n - 1))
    )


init : () -> ( Model, Cmd Msg )
init _ =
    ( { level_boundary = { left = 64, bottom = 1920 + 64, right = 1920 + 64, top = 64 }
      , camera = { left = 0, top = 0, width = 2048, height = 2048 }
      , new_labels = standard_label_list
      , node_coods = [] --set below
      , current_seed = 0 --set below
      }
    , Task.perform OnTime Time.now
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnTime ptime ->
            let
                nmdl =
                    { model | current_seed = Time.posixToMillis ptime }

                nmdl2 =
                    { nmdl | node_coods = Tuple.second (gen_int_list nmdl 64) }

                candidate_nodes =
                    nmdl2.node_coods

                bool_id tf =
                    tf

                nodes_collide node1 node2 =
                    if
                        Basics.max
                            (abs (Tuple.first node1 - Tuple.first node2))
                            (abs (Tuple.second node1 - Tuple.second node2))
                            < 120
                    then
                        if node1 /= node2 then
                            True

                        else
                            False

                    else
                        False

                node_collides nodes node =
                    if List.any bool_id (List.map (nodes_collide node) nodes) then
                        True

                    else
                        False

                ( collision_nodes, nds ) =
                    List.partition (node_collides candidate_nodes) candidate_nodes
            in
            ( { nmdl2 | node_coods = nds }
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
