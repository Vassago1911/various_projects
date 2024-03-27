module Cycle_Sort exposing (main)

import Array
import Browser exposing (..)
import Html exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg.Events exposing (onClick)


main : Program () Model Msg
main =
    Browser.document
        { init = init, view = view, update = update, subscriptions = subscriptions }


view : Model -> Browser.Document Msg
view model =
    { title = "🍜🐿️", body = body model }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


init : () -> ( Model, Cmd Msg )
init _ =
    let
        deg =
            7
    in
    ( { circle_degree = deg
      , tau = List.range 0 (deg - 1)
      }
    , Cmd.none
    )


type Msg
    = NoOp
    | Click Int Int


type alias Model =
    { circle_degree : Int
    , tau : List Int
    }


find : List Int -> Int -> Int
find ll x =
    let
        subfind lll xx =
            ssubfind lll xx 0

        ssubfind lll xx ix =
            case lll of
                h :: l ->
                    if h == xx then
                        ix

                    else
                        ssubfind (Maybe.withDefault [] (List.tail lll)) xx (ix + 1)

                [] ->
                    -1
    in
    subfind ll x


edge_click : Model -> Int -> Int -> Model
edge_click model ix iy =
    -- Here we part ways, either ix iy are the indices of model.tau, or the values
    -- I should opt for indices, it would be faster [ is it values, though? ]
    -- TODO: IT IS!! values -> FIX!
    let
        arr_tau =
            Array.fromList model.tau

        vx =
            Maybe.withDefault 0 (Array.get ix arr_tau)

        vy =
            Maybe.withDefault 0 (Array.get iy arr_tau)

        m0_arr_tau =
            Array.set ix vy arr_tau

        m1_arr_tau =
            Array.set iy vx m0_arr_tau

        new_tau =
            Array.toList m1_arr_tau
    in
    { model | tau = new_tau }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Click ix iy ->
            ( edge_click model ix iy, Cmd.none )

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
            ([ rect [ x "-1024", y "-1024", width "2048", height "2048", fill "#111" ] [] ]
                ++ degree_n_circle model
            )
        ]


degree_n_circle : Model -> List (Svg Msg)
degree_n_circle model =
    let
        ni =
            model.circle_degree

        nf =
            toFloat ni

        node_coods ix =
            { ix = ix
            , x = floor (768 * cos (2 * pi * (toFloat (modBy ni ix) / nf)))
            , y = floor (768 * sin (2 * pi * (toFloat (modBy ni ix) / nf)))
            }

        cyc_tau =
            Maybe.withDefault [ 0 ] (List.tail model.tau)
                ++ [ Maybe.withDefault 0 (List.head model.tau) ]

        nodes =
            List.map node_coods model.tau

        offset_nodes =
            List.map node_coods cyc_tau

        node_to_svg_circ node =
            circle
                [ cx (String.fromInt node.x)
                , cy (String.fromInt node.y)
                , r "20"
                , fill "#500"
                , stroke "#705"
                , strokeWidth "10"
                ]
                []

        node_pair_to_svg_line node1 node2 =
            line
                [ onClick (Click node1.ix node2.ix)
                , x1 (String.fromInt node1.x)
                , y1 (String.fromInt node1.y)
                , x2 (String.fromInt node2.x)
                , y2 (String.fromInt node2.y)
                , strokeWidth "16"
                , stroke "#084"
                ]
                []

        svg_nodes =
            List.map node_to_svg_circ nodes

        svg_lines =
            List.map2 node_pair_to_svg_line nodes offset_nodes
    in
    svg_lines ++ svg_nodes
