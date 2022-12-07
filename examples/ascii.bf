[-][
    # See MEMORY_LAYOUT below for explanation of SETUP.
]
SETUP
    +++++ +++ [ -
        > +++++ ++      (Colon)
        > ++++          (Space)
        > +             (Newline)

        >>>>>>
        ++++ [ -
            > +++++ +++ (Loop_limit)
            <
        ]

        >>>>> >
        > +++++ ++      (C_limit)
        > +++++ +       (c_ascii)
        >>>>
        > +++++ ++      (X_limit)
        > +++++ +       (x_ascii)
        >>>>
        > +++++ ++      (I_limit)
        > +++++ +       (i_ascii)

        <<<<< <<<<< <<<<< <<<<< <<<<< <<<<
    ]
    > ++                (Colon)
    >> ++ >             (all_done)
    >> + >>>>           (Loop_limit)
    >> + >>>> ++        (C_limit)
    >> + >>>> ++        (X_limit)
    >> + >>>> ++        (I_limit)

    <<<<< <<<<< <<<<< <<<<< <<<<< <<<
END_SETUP

MEMORY_LAYOUT
[-][
    # Using Roman abbreviations i, x, and c for units, tens, and hundreds,
    # respectively.  Braces { } indicate a frame: a repeated consecutive group
    # of cells.  Cells named with Uppercase are constants.  At all times,
    # parentheses indicate the current cell; neighboring cells may be noted
    # as well in the code.

    # The main loop starts working from the last frame.  It compares the last
    # two cells in the frame, and performs a carry if applicable.  It then
    # proceeds to the preceding frame and repeats.  The first "frame" is
    # special, as noted by the first cell being 0.  The comparison routine
    # will not be performed on it.  However, when ascii reaches Loop_limit,
    # all_done will be incremented to 1, since it is located at the offset
    # within the frame where carrying would increment a value.

  { (0)  Colon=":"=58  Space=" "=32  Newline="\n"=10  not_all_done=0 all_done=0 }
  { Compare_frame_0=1  0 0 0  Loop_limit=256       ascii="\0"=0   }
  { Compare_frame_1=1  0 0 0  C_limit=":"=58       c_ascii="0"=48 }
  { Compare_frame_2=1  0 0 0  X_limit=":"          x_ascii="0"    }
  { Compare_frame_3=1  0 0 0  I_limit=":"          i_ascii="0"    }
]
END_MEMORY_LAYOUT

>>>>
+
WHILE (not_all_done) [ -
    # Print one line of output
    >>>>> >>>>> >>> .                   (c_ascii)
    >>>>> > .                           (x_ascii)
    >>>>> > .                           (i_ascii)
    <<<<< <<<<< <<<<< <<<<< <<<<< <<< . (Colon)
    > .                                 (Space)
    >>>>> >>>> .                        (ascii)
    INCR (ascii)
    +
    <<<<< <<< .                         (Newline)

    >>>>> >>>>> >>>>> >>>>> >>>>> >
    INCR (i_ascii)
    +

    <<<<<
    REPEAT (Compare_frame_?) [
        >>>>>
        IFEQ eq_flag=0 ascii_save=0 ?_limit (?_ascii)
            [ -
                < - < + >>
            ] ascii_save=ascii; diff=limit=limit MINUS ascii; ascii=0

            <<< + (eq_flag=1)
            >> [
                << - >> [ - > + < ]
            ]    ifneq { eq_flag=0 ; ascii=diff }; (diff=0)
            # Restore diff
            > [ - < + > ]
            # Restore limit and ascii
            << (ascii_save) [ - > + > + << ]
            < (eq_flag) [
            THEN
                [-][
                    # Perform carrying.  If ascii == Loop_limit, then
                    # "carrying" will set the all_done flag.
                ]
                <<< +
                >>>>> > ----- -----
                <<<
            ]
        END_IFEQ (eq_flag=0) ascii_save=0 ?_limit ?_ascii

        <<<<< <<<
        (Compare_frame_next)
    ]

    >>>>>
    BOOL_NEGATE_AND_CLEAR not_all_done=0 (all_done)
        < +
        > [ - < - > ]
        < (not_all_done)
    END_BOOL_NEGATE_AND_CLEAR
]
