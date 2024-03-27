module Main2 exposing (main)

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


basic_bg : Model -> Html Msg
basic_bg model =
    let
        stringy_viewbox =
            String.fromInt model.camera.left
                ++ " "
                ++ String.fromInt model.camera.top
                ++ " "
                ++ String.fromInt model.camera.width
                ++ " "
                ++ String.fromInt model.camera.height

        svg_standard_header =
            [ viewBox stringy_viewbox ]

        bg =
            rect [ fill "#111", x "0", y "0", width "2048", height "2048", stroke "#666", strokeWidth "1" ] []

        level_boundary =
            rect
                [ fill "#090000"
                , x (String.fromInt model.level_boundary.left)
                , y (String.fromInt model.level_boundary.top)
                , width (String.fromInt (model.level_boundary.right - model.level_boundary.left))
                , height (String.fromInt (model.level_boundary.bottom - model.level_boundary.top))
                , stroke "#090909"
                , strokeWidth "8"
                ]
                []

        ui_buttons =
            [ rect
                [ fill "#060606"
                , x (String.fromInt (model.level_boundary.right - 128))
                , y (String.fromInt (model.level_boundary.bottom + 64))
                , width "128"
                , height "128"
                , stroke "#222"
                , strokeWidth "3"

                --, onMouseDown UI_Right_Down
                --, onMouseUp UI_Right_Up
                , Mouse.onDown UI_Right_Down
                , Mouse.onUp UI_Right_Up
                , Touch.onStart (always Touch_UI_Right_Down)
                , Touch.onEnd (always Touch_UI_Right_Up)
                ]
                []
            , rect
                [ fill "#060606"
                , x (String.fromInt (model.level_boundary.right - 128 - 136))
                , y (String.fromInt (model.level_boundary.bottom + 64))
                , width "128"
                , height "128"
                , stroke "#222"
                , strokeWidth "3"

                --, onMouseDown UI_Left_Down
                --, onMouseUp UI_Left_Up
                , Mouse.onDown UI_Left_Down
                , Mouse.onUp UI_Left_Up
                , Touch.onStart (always Touch_UI_Left_Down)
                , Touch.onEnd (always Touch_UI_Left_Up)
                ]
                []
            , Svg.text_
                [ x (String.fromInt (model.level_boundary.right - 96))
                , y (String.fromInt (model.level_boundary.bottom + 192 - 16))
                , fontFamily "monospace"
                , fontSize "128"
                , fill "#999"
                , Mouse.onDown UI_Right_Down
                , Mouse.onUp UI_Right_Up
                , Touch.onStart (always Touch_UI_Right_Down)
                , Touch.onEnd (always Touch_UI_Right_Up)
                ]
                [ Svg.text ">" ]
            , Svg.text_
                [ x (String.fromInt (model.level_boundary.right - 128 - 112))
                , y (String.fromInt (model.level_boundary.bottom + 192 - 16))
                , fontFamily "monospace"
                , fontSize "128"
                , fill "#999"
                , Mouse.onDown UI_Left_Down
                , Mouse.onUp UI_Left_Up
                , Touch.onStart (always Touch_UI_Left_Down)
                , Touch.onEnd (always Touch_UI_Left_Up)
                ]
                [ Svg.text "<" ]
            ]

        debug_label =
            [ Svg.text_
                [ x (String.fromInt (model.level_boundary.left + 64))
                , y (String.fromInt (model.level_boundary.bottom + 128 + 64))
                , fontFamily "monospace"
                , fontSize "128"
                , fill "#606"
                ]
                [ Svg.text model.debug_label_text ]
            ]

        svg_content =
            [ bg, level_boundary, protagonist model ] ++ ui_buttons ++ debug_label
    in
    svg svg_standard_header svg_content


protagonist : Model -> Html Msg
protagonist model =
    let
        prot =
            rect
                [ fill "#662"
                , x (String.fromInt (model.protagonist_data.position.x - 8))
                , y (String.fromInt (model.protagonist_data.position.y - 8))
                , width "16"
                , height "16"
                , stroke "#331"
                , strokeWidth "2"
                ]
                []
    in
    prot


prestyle : Html Msg
prestyle =
    let
        my_css =
            """body, button, div, html, svg { background-color: #000; cursor: crosshair; font-family: monospace; font-size: 64; display: block; position: absolute; top: 0.01%; left: 0.01%; width: 99.98%; height: 99.98%; fill: #999; color: #666; }"""
    in
    Html.node "style" [] [ Html.text my_css ]


body : Model -> Int -> List (Html Msg)
body model i =
    [ div [] (prestyle :: [ basic_bg model ]) ]


view : Model -> Browser.Document Msg
view model =
    { title = "🍜🐿️", body = body model 0 }


move_protagonist : Model -> Float -> Protagonist
move_protagonist model delta =
    let
        left =
            Set.member "ArrowLeft" model.current_downed_keys

        right =
            Set.member "ArrowRight" model.current_downed_keys

        up =
            Set.member "ArrowUp" model.current_downed_keys

        down =
            Set.member "ArrowDown" model.current_downed_keys

        h_dir =
            if right then
                1

            else if left then
                -1

            else
                0

        fps_factor =
            delta * 0.01

        speed =
            fps_factor * 55

        gravity =
            fps_factor * 20

        jump_velocity =
            -48

        --TODO, update player y-velocity here
        vel =
            { x = floor (speed * h_dir), y = 0 }

        prot =
            model.protagonist_data

        pos =
            model.protagonist_data.position

        new_pos =
            { pos
                | x = clamp model.level_boundary.left model.level_boundary.right (pos.x + vel.x)
                , y = clamp model.level_boundary.top model.level_boundary.bottom (pos.y + vel.y)
            }
    in
    { prot | position = new_pos }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick delta ->
            ( { model | protagonist_data = move_protagonist model delta }, Cmd.none )

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


main =
    Browser.document
        { init = init, view = view, update = update, subscriptions = subscriptions }
