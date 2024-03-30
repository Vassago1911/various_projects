module Main exposing (main)

import Browser exposing (Document, document)
import Browser.Events exposing (onKeyDown)
import Css exposing (..)
import Css.Global exposing (body, global, html)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import Html.Styled.Events exposing (onClick)
import Json.Decode as Decode


label : List (Attribute Msg) -> List (Html Msg) -> Html Msg
label =
    styled div [ backgroundColor (rgb 64 64 64), color (rgb 164 164 164) ]


type Msg
    = NoOp
    | AddKey String
    | ButtonClick


type alias Model =
    { keys : List String, cnt : Int }


initialModel =
    { keys = [], cnt = 0 }


keyDecoder : Decode.Decoder String
keyDecoder =
    Decode.map (\x -> x) (Decode.field "key" Decode.string)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ onKeyDown (Decode.map AddKey keyDecoder) ]


main : Program () Model Msg
main =
    Browser.document
        { view = \m -> { title = "🔮Harbinger💡", body = List.map Html.Styled.toUnstyled [ view m ] }
        , update = update
        , init = \_ -> ( initialModel, Cmd.none )
        , subscriptions = subscriptions
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ButtonClick ->
            ( { model | cnt = model.cnt + 1 }, Cmd.none )

        AddKey key ->
            ( { model | keys = key :: model.keys, cnt = model.cnt + 1 }, Cmd.none )

        _ ->
            ( model, Cmd.none )


btn : Html Msg
btn =
    button
        [ css
            [ fontSize (px 16)
            , color (rgb 128 128 128)
            , border3 (px 1) solid (rgb 64 64 64)
            , borderRadius (px 4)
            , backgroundColor (rgb 32 32 32)
            , property "text-transform" "lowercase"
            , fontFamilies [ "monospace" ]
            , hover [ backgroundColor (rgb 128 128 128), color (rgb 32 32 32) ]
            ]
        , onClick ButtonClick
        ]
        [ text "HALLO" ]


lbl : String -> Html Msg
lbl txt =
    label
        [ css
            [ fontSize (px 16)
            , color (rgb 128 128 128)
            , border3 (px 0) solid (rgb 64 64 64)
            , borderRadius (px 2)
            , backgroundColor (rgb 32 32 32)
            , hover [ backgroundColor (rgb 128 64 64), color (rgb 32 32 32) ]
            ]
        ]
        [ text txt ]


view : Model -> Html Msg
view model =
    div
        [ css [ backgroundColor (rgb 0 0 0) ]
        ]
        [ global [ html [ backgroundColor (rgb 0 0 0), fontFamilies [ "monospace" ], fontSize (px 12), fontWeight normal, property "text-transform" "lowercase" ] ]
        , global [ body [ width (vw 100), height (vh 100), property "display" "flex", property "justify-content" "center", property "align-items" "center", property "text-transform" "lowercase" ] ]
        , btn
        , lbl ("TEST: " ++ String.concat model.keys ++ "     ctr: " ++ String.fromInt model.cnt)
        ]
