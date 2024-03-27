module Content exposing (content)

import Svg exposing (Svg)
import SvgSnippets exposing (LevelBoundary, clr_iso_tile)


content : LevelBoundary -> List (Svg msg)
content bdy =
    let
        btile =
            clr_iso_tile bdy "#100e"

        itile0 =
            clr_iso_tile bdy "#110e"

        itile1 =
            clr_iso_tile bdy "#111e"

        dimension =
            { x = 20, y = 60 }

        ixs { x, y } =
            gen_cross_product x y

        it x =
            let
                x0 =
                    Tuple.first (Tuple.second x)

                x1 =
                    Tuple.second (Tuple.second x)
            in
            if (x1 > 0) && (x1 < (dimension.x - 1)) && (x0 > 1) && (x0 < dimension.y - 2) then
                case modBy 2 x0 of
                    0 ->
                        itile1 x0 x1

                    _ ->
                        itile0 x0 x1

            else
                btile x0 x1

        its xs =
            List.map it xs
    in
    its (ixs dimension)


gen_cross_product : Int -> Int -> List ( Int, ( Int, Int ) )
gen_cross_product n m =
    let
        ixs i =
            List.map (\x -> ( i, x )) (List.range 0 (n - 1))

        iys =
            List.map ixs (List.range 0 (m - 1))

        res =
            iys
    in
    List.map2 (\x y -> ( x, y )) (List.range 0 (n * m - 1)) (List.concat res)
