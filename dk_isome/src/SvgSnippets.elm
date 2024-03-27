module SvgSnippets exposing (CameraConstants, DrawConstants, DrawInfo, LevelBoundary, PositionConstants, iso_tile, level_boundary, standard_background, stringy_viewbox)

import Svg exposing (..)
import Svg.Attributes exposing (..)


type alias CameraConstants =
    { camera : { left : Int, top : Int, width : Int, height : Int } }


stringy_viewbox : CameraConstants -> String
stringy_viewbox ccs =
    String.fromInt ccs.camera.left
        ++ " "
        ++ String.fromInt ccs.camera.top
        ++ " "
        ++ String.fromInt ccs.camera.width
        ++ " "
        ++ String.fromInt ccs.camera.height


standard_background : Svg msg
standard_background =
    rect
        [ fill "#000"
        , x "0"
        , y "0"
        , width "2048"
        , height "2048"
        , stroke "#0000"
        , strokeWidth "0"
        ]
        []


type alias LevelBoundary =
    { level_boundary : { left : Int, top : Int, right : Int, bottom : Int } }


level_boundary : LevelBoundary -> Svg msg
level_boundary mdl =
    rect
        [ fill "#090000"
        , x (String.fromInt mdl.level_boundary.left)
        , y (String.fromInt mdl.level_boundary.top)
        , Svg.Attributes.width
            (String.fromInt (mdl.level_boundary.right - mdl.level_boundary.left))
        , Svg.Attributes.height
            (String.fromInt (mdl.level_boundary.bottom - mdl.level_boundary.top))
        , stroke "#0099"
        , strokeWidth "1"
        ]
        []


type alias PositionConstants =
    { xstr : String
    , ystr : String
    }


type alias DrawConstants =
    { vstr : String
    , mvstr : String
    , wstr : String
    , mwstr : String
    , hstr : String
    , mhstr : String
    }


type alias DrawInfo =
    { pos : PositionConstants
    , cs : DrawConstants
    }


iso_tile : Int -> Int -> Svg msg
iso_tile x y =
    let
        csts =
            { c = 16, v = 2, w = 3, h = 5, ax = x, ay = y }

        tstr_constants { c, v, w, h, ax, ay } =
            DrawInfo
                (PositionConstants
                    (String.fromInt ax)
                    (String.fromInt ay)
                )
                (DrawConstants
                    (String.fromInt (v * c))
                    (String.fromInt (-v * c))
                    (String.fromInt (w * c))
                    (String.fromInt (-w * c))
                    (String.fromInt (h * c))
                    (String.fromInt (-h * c))
                )

        c_info =
            tstr_constants csts

        tile_draw =
            String.concat [ "" ]

        tile_ceil_from_bc info =
            String.concat
                [ "M "
                , info.pos.xstr
                , ","
                , info.pos.ystr
                , " "
                , "m "
                , "0"
                , ","
                , info.cs.mhstr
                , " "
                , "l "
                , info.cs.mwstr
                , ","
                , info.cs.mvstr
                , " "
                , "l "
                , info.cs.wstr
                , ","
                , info.cs.mvstr
                , " "
                , "l "
                , info.cs.wstr
                , ","
                , info.cs.vstr
                , " "
                , "l "
                , info.cs.mwstr
                , ","
                , info.cs.vstr
                , " "
                ]

        tile_left_from_bc info =
            String.concat
                [ "M "
                , info.pos.xstr
                , ","
                , info.pos.ystr
                , " "
                , "l "
                , info.cs.mwstr
                , ","
                , info.cs.mvstr
                , " "
                , "l "
                , "0,"
                , info.cs.mhstr
                , " "
                , "l "
                , info.cs.wstr
                , ","
                , info.cs.vstr
                , " "
                , "l 0,"
                , info.cs.hstr
                , " "
                ]

        tile_right_from_bc info =
            String.concat
                [ "M "
                , info.pos.xstr
                , ","
                , info.pos.ystr
                , " "
                , "l "
                , info.cs.wstr
                , ","
                , info.cs.mvstr
                , " "
                , "l "
                , "0,"
                , info.cs.mhstr
                , " "
                , "l "
                , info.cs.mwstr
                , ","
                , info.cs.vstr
                , " "
                , "l 0,"
                , info.cs.hstr
                , " "
                ]

        tile_from_bc constants =
            tile_left_from_bc constants
                ++ tile_right_from_bc constants
                ++ tile_ceil_from_bc constants

        res =
            Svg.path
                [ fill "#26210060"
                , stroke "#111f"
                , strokeWidth "2"
                , Svg.Attributes.d (tile_from_bc c_info)
                ]
                []
    in
    res
