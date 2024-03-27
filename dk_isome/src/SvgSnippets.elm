module SvgSnippets exposing (CameraConstants, DrawConstants, DrawInfo, LevelBoundary, PositionConstants, clr_iso_tile, level_boundary, standard_background, stringy_viewbox)

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


type alias TileDrawConstants =
    { c : Int
    , v : Int
    , w : Int
    , h : Int
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


tile_draw_constants : TileDrawConstants
tile_draw_constants =
    TileDrawConstants 16 2 3 7


draw_constants : DrawConstants
draw_constants =
    let
        int_constants =
            tile_draw_constants
    in
    DrawConstants
        (String.fromInt (int_constants.v * int_constants.c))
        (String.fromInt (-int_constants.v * int_constants.c))
        (String.fromInt (int_constants.w * int_constants.c))
        (String.fromInt (-int_constants.w * int_constants.c))
        (String.fromInt (int_constants.h * int_constants.c))
        (String.fromInt (-int_constants.h * int_constants.c))


iso_position : LevelBoundary -> Int -> Int -> PositionConstants
iso_position bdy row col =
    let
        csts =
            tile_draw_constants

        grid_step_x =
            2 * csts.c * csts.w

        grid_step_y =
            csts.c * csts.v

        x =
            grid_step_x * col + modBy 2 row * csts.c * csts.w

        y =
            grid_step_y * row

        bdy_offset_l =
            bdy.level_boundary.left + floor (0.5 * toFloat csts.c * toFloat csts.w)

        bdy_offset_t =
            bdy.level_boundary.top + csts.c * csts.h
    in
    PositionConstants
        (String.fromInt (bdy_offset_l + x))
        (String.fromInt (bdy_offset_t + y))


clr_iso_tile : LevelBoundary -> String -> Int -> Int -> Svg msg
clr_iso_tile bdy clr x y =
    let
        tstr_constants { ax, ay } =
            DrawInfo
                (iso_position bdy ax ay)
                draw_constants

        c_info =
            tstr_constants { ax = x, ay = y }

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
                [ fill clr
                , stroke "#000f"
                , strokeWidth "2"
                , Svg.Attributes.d (tile_from_bc c_info)
                ]
                []
    in
    res
