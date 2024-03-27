module Cycle_Sort1 exposing (main)

import Array
import Browser exposing (..)
import Html exposing (..)
import List.Extra exposing (find, findIndex, getAt, removeAt)
import Random exposing (Seed, generate, initialSeed, int, maxInt, minInt, step)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg.Events exposing (onClick)
import Task
import Time


main : Program () Model Msg
main =
    Browser.document
        { init = init, view = view, update = update, subscriptions = \_ -> Sub.none }


view : Model -> Browser.Document Msg
view model =
    { title = "🍜🐿️", body = body model }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model 2 [] 0, getTime )


getTime : Cmd Msg
getTime =
    Task.perform OnTime Time.now


shuffleList : Random.Seed -> List a -> List a
shuffleList seed list =
    shuffleListHelper seed list []


shuffleListHelper : Random.Seed -> List a -> List a -> List a
shuffleListHelper seed source result =
    if List.isEmpty source then
        result
        -- end recursion done, final step

    else
        let
            indexGenerator =
                Random.int 0 (List.length source - 1)

            ( index, nextSeed ) =
                Random.step indexGenerator seed

            valAtIndex =
                List.Extra.getAt index source

            sourceWithoutIndex =
                List.Extra.removeAt index source
        in
        case valAtIndex of
            Just val ->
                shuffleListHelper nextSeed sourceWithoutIndex (val :: result)

            Nothing ->
                result


type Msg
    = NoOp
    | Click Int Int
    | OnTime Time.Posix


type alias Model =
    { circle_degree : Int
    , tau : List Int
    , start_time : Int
    }


set_model_time : Model -> Int -> Model
set_model_time model t =
    let
        ( ddeg, _ ) =
            Random.step (Random.int 8 15) (initialSeed (modBy 100000 t))

        deg =
            ddeg

        mdl =
            { model | circle_degree = deg, start_time = t, tau = shuffleList (initialSeed (modBy 97536 t)) (List.range 0 (deg - 1)) }
    in
    swap_tau_indices mdl 0 1


swap_tau_indices : Model -> Int -> Int -> Model
swap_tau_indices model x0 x1 =
    let
        ix0 =
            Maybe.withDefault -1 (List.Extra.findIndex (\x -> x == x0) model.tau)

        ix1 =
            Maybe.withDefault -1 (List.Extra.findIndex (\x -> x == x1) model.tau)

        orig_tau =
            model.tau

        tau_prime =
            List.Extra.setAt ix0 x1 orig_tau

        tau_pprime =
            List.Extra.setAt ix1 x0 tau_prime

        tau_ppprime =
            List.Extra.splitAt (Maybe.withDefault -1 (List.Extra.findIndex (\x -> x == 0) tau_pprime)) tau_pprime

        tau_pppprime =
            Tuple.second tau_ppprime ++ Tuple.first tau_ppprime

        tau_p5rime =
            case tau_pppprime of
                h0 :: (h1 :: l) ->
                    if h1 > (h0 + 1) then
                        List.reverse tau_pppprime

                    else
                        tau_pppprime

                _ ->
                    tau_pppprime

        tau_p6rime =
            List.Extra.splitAt (Maybe.withDefault -1 (List.Extra.findIndex (\x -> x == 0) tau_p5rime)) tau_p5rime

        tau_res =
            Tuple.second tau_p6rime ++ Tuple.first tau_p6rime
    in
    { model | tau = tau_res }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Click x y ->
            ( swap_tau_indices model x y, Cmd.none )

        OnTime t ->
            ( set_model_time model (Time.posixToMillis t), Cmd.none )

        _ ->
            ( model, Cmd.none )


body : Model -> List (Html Msg)
body model =
    [ content model ]


prestyle : Html Msg
prestyle =
    let
        my_css =
            """body, button, div, html, svg
            { background-color: #000;
              cursor: crosshair;
              font-family: monospace;
              font-size: 64;
              display: block;
              position: absolute;
              top: 0.01%;
              left: 0.01%;
              width: 99.98%;
              height: 99.98%;
              fill: #999;
              color: #666; }"""
    in
    Html.node "style" [] [ Html.text my_css ]


content : Model -> Html Msg
content model =
    div []
        [ prestyle
        , svg [ viewBox "-1024 -1024 2048 2048" ]
            (background model ++ foreground model)
        ]


background : Model -> List (Svg Msg)
background model =
    let
        ixs =
            List.range 0 (model.circle_degree - 1)

        ixs_off_one =
            [ model.circle_degree - 1 ] ++ List.range 0 (model.circle_degree - 2)

        ni =
            model.circle_degree

        nf =
            toFloat ni

        node_coods ix =
            { ix = ix
            , x = floor (720 * cos (2 * pi * (toFloat (modBy ni ix) / nf)))
            , y = floor (720 * sin (2 * pi * (toFloat (modBy ni ix) / nf)))
            }

        nodes =
            List.map node_coods ixs

        offset_nodes =
            List.map node_coods ixs_off_one

        node_to_svg_circ node =
            g []
                [ circle
                    [ cx (String.fromInt node.x)
                    , cy (String.fromInt node.y)
                    , r "42"
                    , fill "#5002"
                    , stroke "#6604"
                    , strokeWidth "12"
                    ]
                    []
                , circle
                    [ cx (String.fromInt node.x)
                    , cy (String.fromInt node.y)
                    , r "36"
                    , fill "#5003"
                    , stroke "#7056"
                    , strokeWidth "4"
                    ]
                    []
                ]

        node_pair_to_svg_line node1 node2 =
            g []
                [ line
                    [ onClick (Click node1.ix node2.ix)
                    , x1 (String.fromInt node1.x)
                    , y1 (String.fromInt node1.y)
                    , x2 (String.fromInt node2.x)
                    , y2 (String.fromInt node2.y)
                    , strokeWidth "80"
                    , stroke "#2126"
                    , strokeLinecap "round"
                    ]
                    []
                , line
                    [ onClick (Click node1.ix node2.ix)
                    , x1 (String.fromInt node1.x)
                    , y1 (String.fromInt node1.y)
                    , x2 (String.fromInt node2.x)
                    , y2 (String.fromInt node2.y)
                    , strokeWidth "72"
                    , stroke "#2229"
                    , strokeLinecap "round"
                    ]
                    []
                ]

        svg_nodes =
            List.map node_to_svg_circ nodes

        svg_lines =
            List.map2 node_pair_to_svg_line nodes offset_nodes

        svg_text =
            text_ [ x "-512", y "0", fontSize "42", color "#999", fill "#999", fontFamily "monospace" ]
                [ Svg.text (String.join " " (List.map String.fromInt model.tau)) ]
    in
    svg_lines
        ++ svg_nodes
        ++ [ svg_text ]



--++ [ svg_text ]


foreground : Model -> List (Svg Msg)
foreground model =
    let
        ixs =
            model.tau

        ixs_off_one =
            Maybe.withDefault [] (List.tail model.tau) ++ [ Maybe.withDefault -1 (List.head model.tau) ]

        ni =
            model.circle_degree

        nf =
            toFloat ni

        node_coods ix =
            { ix = ix
            , x = floor (672 * cos (2 * pi * (toFloat (modBy ni ix) / nf)))
            , y = floor (672 * sin (2 * pi * (toFloat (modBy ni ix) / nf)))
            }

        nodes =
            List.map node_coods ixs

        offset_nodes =
            List.map node_coods ixs_off_one

        node_to_svg_circ node =
            g []
                [ circle
                    [ cx (String.fromInt node.x)
                    , cy (String.fromInt node.y)
                    , r "12"
                    , fill "#0505"
                    , stroke "#0555"
                    , strokeWidth "2"
                    ]
                    []
                , circle
                    [ cx (String.fromInt node.x)
                    , cy (String.fromInt node.y)
                    , r "10"
                    , fill "#0505"
                    , stroke "#0535"
                    , strokeWidth "2"
                    ]
                    []
                ]

        node_pair_to_svg_line node1 node2 =
            g []
                [ line
                    [ x1 (String.fromInt node1.x)
                    , y1 (String.fromInt node1.y)
                    , x2 (String.fromInt node2.x)
                    , y2 (String.fromInt node2.y)
                    , strokeWidth "18"
                    , stroke "#3934"
                    , strokeLinecap "round"
                    ]
                    []
                , line
                    [ x1 (String.fromInt node1.x)
                    , y1 (String.fromInt node1.y)
                    , x2 (String.fromInt node2.x)
                    , y2 (String.fromInt node2.y)
                    , strokeWidth "10"
                    , stroke "#0839"
                    , strokeLinecap "round"
                    ]
                    []
                ]

        svg_nodes =
            List.map node_to_svg_circ nodes

        svg_lines =
            List.map2 node_pair_to_svg_line nodes offset_nodes
    in
    svg_lines ++ svg_nodes
