module Castle_Input exposing (main)

import Browser exposing (..)
import Browser.Events exposing (onAnimationFrameDelta, onKeyDown, onKeyUp)
import Html exposing (..)
import Html.Events.Extra.Mouse as Mouse
import Html.Events.Extra.Touch as Touch
import Json.Decode as Decode
import Set exposing (Set)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg.Events exposing (onMouseDown, onMouseUp)



--- BOILERPLATE = keyboard input + animation loop ---


main : Program () Model Msg
main =
    Browser.document
        { init = init, view = view, update = update, subscriptions = subscriptions }


toKey : String -> String
toKey event_key =
    case String.uncons event_key of
        Just ( char, "" ) ->
            String.fromChar char

        _ ->
            event_key


keyDecoder : Decode.Decoder String
keyDecoder =
    Decode.map toKey (Decode.field "key" Decode.string)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ onAnimationFrameDelta Tick
        , onKeyDown (Decode.map AddKey keyDecoder)
        , onKeyUp (Decode.map RemoveKey keyDecoder)
        ]



--- BOILERPLATE END ---
--- MODELLING ---


type Msg
    = NoOp
    | Tick Float
    | AddKey String
    | RemoveKey String
    | UI_Left_Down Mouse.Event
    | UI_Right_Down Mouse.Event
    | UI_Left_Up Mouse.Event
    | UI_Right_Up Mouse.Event
    | Touch_UI_Left_Down
    | Touch_UI_Right_Down
    | Touch_UI_Left_Up
    | Touch_UI_Right_Up


type alias Protagonist =
    { position : { x : Int, y : Int }, velocity : { x : Int, y : Int } }


type alias Model =
    { level_boundary : { left : Int, bottom : Int, right : Int, top : Int }
    , camera : { left : Int, top : Int, width : Int, height : Int }
    , protagonist_data : Protagonist
    , current_downed_keys : Set String
    , debug_label_text : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { level_boundary = { left = 128, bottom = 1920 + 64 - 256, right = 1920 + 64 - 64, top = 128 }
      , camera = { left = 0, top = 0, width = 2048, height = 2048 }
      , protagonist_data = Protagonist { x = 1024, y = 1024 } { x = 0, y = 0 }
      , current_downed_keys = Set.fromList []
      , debug_label_text = ""
      }
    , Cmd.none
    )



--- MODELLING END ---
--- UPDATE MODEL on MSG ---


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick delta ->
            --( { model | protagonist_data = move_protagonist model delta }, Cmd.none )
            ( model, Cmd.none )

        AddKey key ->
            ( { model | debug_label_text = "AddKey", current_downed_keys = Set.insert key model.current_downed_keys }, Cmd.none )

        RemoveKey key ->
            ( { model | debug_label_text = "RemoveKey", current_downed_keys = Set.remove key model.current_downed_keys }, Cmd.none )

        UI_Left_Down _ ->
            ( { model | debug_label_text = "UI_Left_Down", current_downed_keys = Set.insert "ArrowLeft" model.current_downed_keys }, Cmd.none )

        UI_Left_Up _ ->
            ( { model | debug_label_text = "UI_Left_Up", current_downed_keys = Set.remove "ArrowLeft" model.current_downed_keys }, Cmd.none )

        UI_Right_Down _ ->
            ( { model | debug_label_text = "UI_Right_Down", current_downed_keys = Set.insert "ArrowRight" model.current_downed_keys }, Cmd.none )

        UI_Right_Up _ ->
            ( { model | debug_label_text = "UI_Right_Up", current_downed_keys = Set.remove "ArrowRight" model.current_downed_keys }, Cmd.none )

        Touch_UI_Left_Down ->
            ( { model | debug_label_text = "Touch_UI_Left_Down", current_downed_keys = Set.insert "ArrowLeft" model.current_downed_keys }, Cmd.none )

        Touch_UI_Left_Up ->
            ( { model | debug_label_text = "Touch_UI_Left_Up", current_downed_keys = Set.remove "ArrowLeft" model.current_downed_keys }, Cmd.none )

        Touch_UI_Right_Down ->
            ( { model | debug_label_text = "Touch_UI_Right_Down", current_downed_keys = Set.insert "ArrowRight" model.current_downed_keys }, Cmd.none )

        Touch_UI_Right_Up ->
            ( { model | debug_label_text = "Touch_UI_Right_Up", current_downed_keys = Set.remove "ArrowRight" model.current_downed_keys }, Cmd.none )

        _ ->
            ( model, Cmd.none )



--- UPDATE MODEL END ---
--- VIEW ---


prestyle : Html Msg
prestyle =
    let
        my_css =
            """body, button, div, html, #svg { background-color: #000; cursor: crosshair; font-family: monospace; font-size: 64; display: block; position: absolute; top: 0.01%; left: 0.01%; width: 99.98%; height: 99.98%; fill: #999; color: #666; }"""
    in
    Html.node "style" [] [ Html.text my_css ]


grid_cell : Int -> Int -> Svg Msg
grid_cell iy ix =
    rect
        [ x (String.fromInt (64 * ix))
        , y (String.fromInt (64 * iy))
        , width "64"
        , height "64"
        , fill "#000"
        , strokeWidth "4"
        , stroke "#222"
        ]
        []


grid_row : Int -> Int -> List (Svg Msg)
grid_row length row_index =
    let
        f_rect =
            grid_cell row_index

        col_ixs =
            List.range 1 (length - 2)

        row =
            List.map f_rect col_ixs
    in
    row


grid_ : Int -> Int -> List (Svg Msg)
grid_ row_count col_count =
    let
        rrow =
            grid_row col_count

        row_ixs =
            List.range 1 (row_count - 2)

        rows =
            List.concat (List.map rrow row_ixs)
    in
    rows


grid : List (Svg Msg)
grid =
    grid_ 32 32


level : List (Svg Msg)
level =
    let
        bdy_cell iy ix =
            rect
                [ x (String.fromInt (64 * ix))
                , y (String.fromInt (64 * iy))
                , width "64"
                , height "64"
                , fill "#036"
                , strokeWidth "2"
                , stroke "#259"
                ]
                []

        bdy_cell2 ix iy =
            bdy_cell iy ix

        boundary =
            List.map (bdy_cell 1) (List.range 1 30)
                ++ List.map (bdy_cell 30) (List.range 1 30)
                ++ List.map (bdy_cell2 1) (List.range 2 29)
                ++ List.map (bdy_cell2 30) (List.range 2 29)
    in
    boundary
        ++ List.map (bdy_cell 5) (List.range 25 29)
        ++ List.map (bdy_cell 6) [ 24 ]
        ++ List.map (bdy_cell 7) [ 23 ]
        ++ List.map (bdy_cell 8) [ 22 ]
        ++ List.map (bdy_cell 9) [ 21 ]
        ++ List.map (bdy_cell 10) (List.range 2 5 ++ [ 20 ])
        ++ List.map (bdy_cell 11) [ 6, 19 ]
        ++ List.map (bdy_cell 12) [ 7, 18 ]
        ++ List.map (bdy_cell 13) [ 8, 17 ]
        ++ List.map (bdy_cell 14) (List.range 9 16)
        ++ List.map (bdy_cell 15) [ 8, 17 ]
        ++ List.map (bdy_cell 16) [ 7, 18 ]
        ++ List.map (bdy_cell 17) [ 6, 19 ]
        ++ List.map (bdy_cell 18) (List.range 2 5 ++ List.range 20 29)
        ++ List.map (bdy_cell 19) [ 6, 19, 21 ]
        ++ List.map (bdy_cell 20) [ 7, 18, 21 ]
        ++ List.map (bdy_cell 21) [ 8, 17, 21 ]
        ++ List.map (bdy_cell 22) (List.range 9 29)
        ++ List.map (bdy_cell 23) [ 8, 12 ]
        ++ List.map (bdy_cell 24) [ 7, 12 ]
        ++ List.map (bdy_cell 25) [ 6, 12 ]
        ++ List.map (bdy_cell 26) (List.range 2 5 ++ List.range 12 17 ++ List.range 25 29)
        ++ List.map (bdy_cell 27) [ 6, 18, 24 ]
        ++ List.map (bdy_cell 28) [ 7, 19, 23 ]
        ++ List.map (bdy_cell 29) [ 8, 20, 22 ]


body : Model -> Int -> List (Html Msg)
body model i =
    [ div []
        (prestyle
            :: [ svg [ id "svg", viewBox "0 0 2048 2048" ]
                    (rect
                        [ x "0", y "0", width "2048", height "2048", fill "#000", strokeWidth "4", stroke "#111" ]
                        []
                        :: grid
                        ++ level
                    )
               ]
        )
    ]


view : Model -> Browser.Document Msg
view model =
    { title = "🍜🐿️", body = body model 0 }



--- VIEW END ---
