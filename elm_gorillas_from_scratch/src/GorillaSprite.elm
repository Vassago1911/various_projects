module GorillaSprite exposing (gorilla)

import Svg.Styled exposing (..)
import Svg.Styled.Attributes exposing (..)


gorilla : Int -> Int -> Svg msg
gorilla posx posy =
    let
        torso =
            [ rect
                [ Svg.Styled.Attributes.fill "#220"
                , Svg.Styled.Attributes.x "123"
                , Svg.Styled.Attributes.y "110"
                , Svg.Styled.Attributes.rx "32"
                , Svg.Styled.Attributes.ry "32"
                , Svg.Styled.Attributes.width "142"
                , Svg.Styled.Attributes.height "180"
                , Svg.Styled.Attributes.stroke "#110"
                , Svg.Styled.Attributes.strokeWidth "4px"
                ]
                []
            ]

        pecs =
            [ rect
                [ Svg.Styled.Attributes.fill "#220"
                , Svg.Styled.Attributes.x "128"
                , Svg.Styled.Attributes.y "128"
                , Svg.Styled.Attributes.rx "16"
                , Svg.Styled.Attributes.ry "16"
                , Svg.Styled.Attributes.width "64"
                , Svg.Styled.Attributes.height "64"
                , Svg.Styled.Attributes.stroke "#110"
                , Svg.Styled.Attributes.strokeWidth "4px"
                ]
                []
            , rect
                [ Svg.Styled.Attributes.fill "#220"
                , Svg.Styled.Attributes.x "196"
                , Svg.Styled.Attributes.y "128"
                , Svg.Styled.Attributes.rx "16"
                , Svg.Styled.Attributes.ry "16"
                , Svg.Styled.Attributes.width "64"
                , Svg.Styled.Attributes.height "64"
                , Svg.Styled.Attributes.stroke "#110"
                , Svg.Styled.Attributes.strokeWidth "4px"
                ]
                []
            ]

        legs =
            [ rect
                [ Svg.Styled.Attributes.fill "#220"
                , Svg.Styled.Attributes.x "128"
                , Svg.Styled.Attributes.y "250"
                , Svg.Styled.Attributes.rx "16"
                , Svg.Styled.Attributes.ry "16"
                , Svg.Styled.Attributes.width "56"
                , Svg.Styled.Attributes.height "64"
                , Svg.Styled.Attributes.stroke "#110"
                , Svg.Styled.Attributes.strokeWidth "4px"
                ]
                []
            , rect
                [ Svg.Styled.Attributes.fill "#220"
                , Svg.Styled.Attributes.x "206"
                , Svg.Styled.Attributes.y "250"
                , Svg.Styled.Attributes.rx "16"
                , Svg.Styled.Attributes.ry "16"
                , Svg.Styled.Attributes.width "56"
                , Svg.Styled.Attributes.height "64"
                , Svg.Styled.Attributes.stroke "#110"
                , Svg.Styled.Attributes.strokeWidth "4px"
                ]
                []
            , rect
                [ Svg.Styled.Attributes.fill "#220"
                , Svg.Styled.Attributes.x "128"
                , Svg.Styled.Attributes.y "306"
                , Svg.Styled.Attributes.rx "16"
                , Svg.Styled.Attributes.ry "16"
                , Svg.Styled.Attributes.width "56"
                , Svg.Styled.Attributes.height "64"
                , Svg.Styled.Attributes.stroke "#110"
                , Svg.Styled.Attributes.strokeWidth "4px"
                ]
                []
            , rect
                [ Svg.Styled.Attributes.fill "#220"
                , Svg.Styled.Attributes.x "206"
                , Svg.Styled.Attributes.y "306"
                , Svg.Styled.Attributes.rx "16"
                , Svg.Styled.Attributes.ry "16"
                , Svg.Styled.Attributes.width "56"
                , Svg.Styled.Attributes.height "64"
                , Svg.Styled.Attributes.stroke "#110"
                , Svg.Styled.Attributes.strokeWidth "4px"
                ]
                []
            , rect
                [ Svg.Styled.Attributes.fill "#220"
                , Svg.Styled.Attributes.x "128"
                , Svg.Styled.Attributes.y "298"
                , Svg.Styled.Attributes.rx "16"
                , Svg.Styled.Attributes.ry "16"
                , Svg.Styled.Attributes.width "58"
                , Svg.Styled.Attributes.height "36"
                , Svg.Styled.Attributes.stroke "#110"
                , Svg.Styled.Attributes.strokeWidth "4px"
                ]
                []
            , rect
                [ Svg.Styled.Attributes.fill "#220"
                , Svg.Styled.Attributes.x "206"
                , Svg.Styled.Attributes.y "298"
                , Svg.Styled.Attributes.rx "16"
                , Svg.Styled.Attributes.ry "16"
                , Svg.Styled.Attributes.width "58"
                , Svg.Styled.Attributes.height "36"
                , Svg.Styled.Attributes.stroke "#110"
                , Svg.Styled.Attributes.strokeWidth "4px"
                ]
                []
            ]

        abs =
            [ rect
                [ Svg.Styled.Attributes.fill "#220"
                , Svg.Styled.Attributes.x "160"
                , Svg.Styled.Attributes.y "192"
                , Svg.Styled.Attributes.rx "8"
                , Svg.Styled.Attributes.ry "8"
                , Svg.Styled.Attributes.width "32"
                , Svg.Styled.Attributes.height "32"
                , Svg.Styled.Attributes.stroke "#110"
                , Svg.Styled.Attributes.strokeWidth "4px"
                ]
                []
            , rect
                [ Svg.Styled.Attributes.fill "#220"
                , Svg.Styled.Attributes.x "196"
                , Svg.Styled.Attributes.y "192"
                , Svg.Styled.Attributes.rx "8"
                , Svg.Styled.Attributes.ry "8"
                , Svg.Styled.Attributes.width "32"
                , Svg.Styled.Attributes.height "32"
                , Svg.Styled.Attributes.stroke "#110"
                , Svg.Styled.Attributes.strokeWidth "4px"
                ]
                []
            , rect
                [ Svg.Styled.Attributes.fill "#220"
                , Svg.Styled.Attributes.x "160"
                , Svg.Styled.Attributes.y "224"
                , Svg.Styled.Attributes.rx "8"
                , Svg.Styled.Attributes.ry "8"
                , Svg.Styled.Attributes.width "32"
                , Svg.Styled.Attributes.height "32"
                , Svg.Styled.Attributes.stroke "#110"
                , Svg.Styled.Attributes.strokeWidth "4px"
                ]
                []
            , rect
                [ Svg.Styled.Attributes.fill "#220"
                , Svg.Styled.Attributes.x "196"
                , Svg.Styled.Attributes.y "224"
                , Svg.Styled.Attributes.rx "8"
                , Svg.Styled.Attributes.ry "8"
                , Svg.Styled.Attributes.width "32"
                , Svg.Styled.Attributes.height "32"
                , Svg.Styled.Attributes.stroke "#110"
                , Svg.Styled.Attributes.strokeWidth "4px"
                ]
                []
            , rect
                [ Svg.Styled.Attributes.fill "#220"
                , Svg.Styled.Attributes.x "170"
                , Svg.Styled.Attributes.y "256"
                , Svg.Styled.Attributes.rx "8"
                , Svg.Styled.Attributes.ry "8"
                , Svg.Styled.Attributes.width "48"
                , Svg.Styled.Attributes.height "32"
                , Svg.Styled.Attributes.stroke "#110"
                , Svg.Styled.Attributes.strokeWidth "4px"
                ]
                []
            ]

        feet =
            [ rect
                [ Svg.Styled.Attributes.fill "#222"
                , Svg.Styled.Attributes.x "126"
                , Svg.Styled.Attributes.y "348"
                , Svg.Styled.Attributes.rx "8"
                , Svg.Styled.Attributes.ry "8"
                , Svg.Styled.Attributes.width "48"
                , Svg.Styled.Attributes.height "32"
                , Svg.Styled.Attributes.stroke "#110"
                , Svg.Styled.Attributes.strokeWidth "8px"
                ]
                []
            , rect
                [ Svg.Styled.Attributes.fill "#222"
                , Svg.Styled.Attributes.x "216"
                , Svg.Styled.Attributes.y "348"
                , Svg.Styled.Attributes.rx "8"
                , Svg.Styled.Attributes.ry "8"
                , Svg.Styled.Attributes.width "48"
                , Svg.Styled.Attributes.height "32"
                , Svg.Styled.Attributes.stroke "#110"
                , Svg.Styled.Attributes.strokeWidth "8px"
                ]
                []
            ]

        shoulders =
            [ rect
                [ Svg.Styled.Attributes.fill "#222"
                , Svg.Styled.Attributes.x "96"
                , Svg.Styled.Attributes.y "102"
                , Svg.Styled.Attributes.rx "16"
                , Svg.Styled.Attributes.ry "16"
                , Svg.Styled.Attributes.width "60"
                , Svg.Styled.Attributes.height "60"
                , Svg.Styled.Attributes.stroke "#110"
                , Svg.Styled.Attributes.strokeWidth "8px"
                , Svg.Styled.Attributes.transform "rotate(45,126,132)"
                ]
                []
            , rect
                [ Svg.Styled.Attributes.fill "#222"
                , Svg.Styled.Attributes.x "230"
                , Svg.Styled.Attributes.y "102"
                , Svg.Styled.Attributes.rx "16"
                , Svg.Styled.Attributes.ry "16"
                , Svg.Styled.Attributes.width "60"
                , Svg.Styled.Attributes.height "60"
                , Svg.Styled.Attributes.stroke "#110"
                , Svg.Styled.Attributes.strokeWidth "8px"
                , Svg.Styled.Attributes.transform "rotate(45,260,132)"
                ]
                []
            ]

        neck =
            [ rect
                [ Svg.Styled.Attributes.fill "#220"
                , Svg.Styled.Attributes.x "170"
                , Svg.Styled.Attributes.y "90"
                , Svg.Styled.Attributes.rx "16"
                , Svg.Styled.Attributes.ry "16"
                , Svg.Styled.Attributes.width "50"
                , Svg.Styled.Attributes.height "50"
                , Svg.Styled.Attributes.stroke "#110"
                , Svg.Styled.Attributes.strokeWidth "2px"
                ]
                []
            ]

        head =
            [ rect
                [ Svg.Styled.Attributes.fill "#220"
                , Svg.Styled.Attributes.x "150"
                , Svg.Styled.Attributes.y "30"
                , Svg.Styled.Attributes.rx "16"
                , Svg.Styled.Attributes.ry "16"
                , Svg.Styled.Attributes.width "90"
                , Svg.Styled.Attributes.height "80"
                , Svg.Styled.Attributes.stroke "#110"
                , Svg.Styled.Attributes.strokeWidth "2px"
                ]
                []
            ]

        eyes =
            [ rect
                [ Svg.Styled.Attributes.fill "#211"
                , Svg.Styled.Attributes.x "170"
                , Svg.Styled.Attributes.y "50"
                , Svg.Styled.Attributes.rx "16"
                , Svg.Styled.Attributes.ry "16"
                , Svg.Styled.Attributes.width "10"
                , Svg.Styled.Attributes.height "20"
                , Svg.Styled.Attributes.stroke "#221"
                , Svg.Styled.Attributes.strokeWidth "2px"
                ]
                []
            , rect
                [ Svg.Styled.Attributes.fill "#211"
                , Svg.Styled.Attributes.x "210"
                , Svg.Styled.Attributes.y "50"
                , Svg.Styled.Attributes.rx "16"
                , Svg.Styled.Attributes.ry "16"
                , Svg.Styled.Attributes.width "10"
                , Svg.Styled.Attributes.height "20"
                , Svg.Styled.Attributes.stroke "#221"
                , Svg.Styled.Attributes.strokeWidth "2px"
                ]
                []
            ]

        mouth =
            [ rect
                [ Svg.Styled.Attributes.fill "#110"
                , Svg.Styled.Attributes.x "180"
                , Svg.Styled.Attributes.y "80"
                , Svg.Styled.Attributes.rx "16"
                , Svg.Styled.Attributes.ry "16"
                , Svg.Styled.Attributes.width "30"
                , Svg.Styled.Attributes.height "10"
                , Svg.Styled.Attributes.stroke "#110"
                , Svg.Styled.Attributes.strokeWidth "2px"
                ]
                []
            ]

        upper_arms =
            [ rect
                [ Svg.Styled.Attributes.fill "#110"
                , Svg.Styled.Attributes.x "250"
                , Svg.Styled.Attributes.y "130"
                , Svg.Styled.Attributes.rx "8"
                , Svg.Styled.Attributes.ry "8"
                , Svg.Styled.Attributes.width "40"
                , Svg.Styled.Attributes.height "80"
                , Svg.Styled.Attributes.stroke "#0002"
                , Svg.Styled.Attributes.strokeWidth "4px"
                , Svg.Styled.Attributes.transform "rotate(-33,250,130)"
                ]
                []
            , rect
                [ Svg.Styled.Attributes.fill "#110"
                , Svg.Styled.Attributes.x "105"
                , Svg.Styled.Attributes.y "110"
                , Svg.Styled.Attributes.rx "8"
                , Svg.Styled.Attributes.ry "8"
                , Svg.Styled.Attributes.width "40"
                , Svg.Styled.Attributes.height "80"
                , Svg.Styled.Attributes.stroke "#0002"
                , Svg.Styled.Attributes.strokeWidth "4px"
                , Svg.Styled.Attributes.transform "rotate(33,105,110)"
                ]
                []
            ]

        elbows =
            [ rect
                [ Svg.Styled.Attributes.fill "#222"
                , Svg.Styled.Attributes.x "280"
                , Svg.Styled.Attributes.y "160"
                , Svg.Styled.Attributes.rx "16"
                , Svg.Styled.Attributes.ry "16"
                , Svg.Styled.Attributes.width "50"
                , Svg.Styled.Attributes.height "50"
                , Svg.Styled.Attributes.stroke "#0002"
                , Svg.Styled.Attributes.strokeWidth "4px"
                ]
                []
            , rect
                [ Svg.Styled.Attributes.fill "#222"
                , Svg.Styled.Attributes.x "60"
                , Svg.Styled.Attributes.y "160"
                , Svg.Styled.Attributes.rx "16"
                , Svg.Styled.Attributes.ry "16"
                , Svg.Styled.Attributes.width "50"
                , Svg.Styled.Attributes.height "50"
                , Svg.Styled.Attributes.stroke "#0002"
                , Svg.Styled.Attributes.strokeWidth "4px"
                ]
                []
            ]

        lower_arms =
            [ rect
                [ Svg.Styled.Attributes.fill "#110"
                , Svg.Styled.Attributes.x "290"
                , Svg.Styled.Attributes.y "190"
                , Svg.Styled.Attributes.rx "8"
                , Svg.Styled.Attributes.ry "8"
                , Svg.Styled.Attributes.width "35"
                , Svg.Styled.Attributes.height "70"
                , Svg.Styled.Attributes.stroke "#0002"
                , Svg.Styled.Attributes.strokeWidth "4px"
                ]
                []
            , rect
                [ Svg.Styled.Attributes.fill "#110"
                , Svg.Styled.Attributes.x "70"
                , Svg.Styled.Attributes.y "190"
                , Svg.Styled.Attributes.rx "8"
                , Svg.Styled.Attributes.ry "8"
                , Svg.Styled.Attributes.width "35"
                , Svg.Styled.Attributes.height "70"
                , Svg.Styled.Attributes.stroke "#0002"
                , Svg.Styled.Attributes.strokeWidth "4px"
                ]
                []
            ]

        hands =
            [ rect
                [ Svg.Styled.Attributes.fill "#222"
                , Svg.Styled.Attributes.x "280"
                , Svg.Styled.Attributes.y "220"
                , Svg.Styled.Attributes.rx "16"
                , Svg.Styled.Attributes.ry "16"
                , Svg.Styled.Attributes.width "50"
                , Svg.Styled.Attributes.height "50"
                , Svg.Styled.Attributes.stroke "#0002"
                , Svg.Styled.Attributes.strokeWidth "4px"
                ]
                []
            , rect
                [ Svg.Styled.Attributes.fill "#222"
                , Svg.Styled.Attributes.x "60"
                , Svg.Styled.Attributes.y "220"
                , Svg.Styled.Attributes.rx "16"
                , Svg.Styled.Attributes.ry "16"
                , Svg.Styled.Attributes.width "50"
                , Svg.Styled.Attributes.height "50"
                , Svg.Styled.Attributes.stroke "#0002"
                , Svg.Styled.Attributes.strokeWidth "4px"
                ]
                []
            ]
    in
    Svg.Styled.foreignObject
        [ Svg.Styled.Attributes.x (String.fromInt (-60 + posx))
        , Svg.Styled.Attributes.y (String.fromInt (2048 - 300 - posy))
        , Svg.Styled.Attributes.width "256"
        , Svg.Styled.Attributes.height "340"
        ]
        [ Svg.Styled.svg
            [ Svg.Styled.Attributes.viewBox "60 30 270 550"
            , Svg.Styled.Attributes.transform "scale(0.5)"
            ]
            (torso
                ++ neck
                ++ elbows
                ++ upper_arms
                ++ lower_arms
                ++ hands
                ++ shoulders
                ++ pecs
                ++ legs
                ++ abs
                ++ feet
                ++ head
                ++ eyes
                ++ mouth
            )
        ]
