;----------------------------------------------------------------------*
; NAME: Emmett Leahy
; STUDENT ID: C00311509
; DESCRIPTION: The Mystery of Blackwood Cabin is A menu based
; detective game where players read clues and interrogate 
; suspects before making a final accusation.
;----------------------------------------------------------------------*

    ORG     $1000

;-------------------------------------------------------
; START OF GAME & MAIN MENU
;-------------------------------------------------------
START:
    BSR     PRINT_INTRO         ; Print the opening story

MAIN_MENU:
    BSR     ENDL
    LEA     MENU_MSG,A1         ; Load menu options [cite: 5]
    MOVE.B  #14,D0              ; Print string [cite: 6]
    TRAP    #15
    
    MOVE.B  #4,D0               ; Read integer into D1 [cite: 7]
    TRAP    #15
    
    ; --- Error Handling: Range Check (0 to 5) ---
    CMP.B   #0,D1               ; Check if input is less than 0
    BLT     INVALID_INPUT
    CMP.B   #5,D1               ; Check if input is greater than 5
    BGT     INVALID_INPUT

    ; --- Branching based on valid player input ---
    CMP.B   #1,D1
    BEQ     EXAMINE_SCENE
    CMP.B   #2,D1
    BEQ     TALK_ELEANOR
    CMP.B   #3,D1
    BEQ     TALK_JULIAN
    CMP.B   #4,D1
    BEQ     TALK_MARTHA
    CMP.B   #5,D1
    BEQ     ACCUSE_SUSPECT
    CMP.B   #0,D1
    BEQ     QUIT_GAME [cite: 9]
      
    ; If invalid input, loop back
    BRA     MAIN_MENU
;-------------------------------------------------------
; INVESTIGATION SUBROUTINES
;-------------------------------------------------------
EXAMINE_SCENE:
    BSR     ENDL
    LEA     SCENE_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA     MAIN_MENU

TALK_ELEANOR:
    BSR     ENDL
    LEA     ELEANOR_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA     MAIN_MENU

TALK_JULIAN:
    BSR     ENDL
    LEA     JULIAN_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA     MAIN_MENU

TALK_MARTHA:
    BSR     ENDL
    LEA     MARTHA_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA     MAIN_MENU

;-------------------------------------------------------
; THE ACCUSATION (END OF GAME LOGIC)
;-------------------------------------------------------
ACCUSE_SUSPECT:
    BSR     ENDL
    LEA     ACCUSE_MSG,A1 [cite: 12]
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #4,D0               ; Read integer [cite: 13]
    TRAP    #15

    ; --- Error Handling: Valid suspect range (1 to 3) ---
    CMP.B   #1,D1
    BLT     INVALID_ACCUSE
    CMP.B   #3,D1
    BGT     INVALID_ACCUSE
    
    ; The killer is Martha [cite: 14]
    CMP.B   #3,D1
    BEQ     WIN_GAME
    BRA     LOSE_GAME

WIN_GAME:
    BSR     ENDL
    LEA     WIN_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    SIMHALT                     ; End program

LOSE_GAME:
    BSR     ENDL
    LEA     LOSE_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    SIMHALT                     ; End program

QUIT_GAME:
    SIMHALT

;-------------------------------------------------------
; UTILITIES
;-------------------------------------------------------
PRINT_INTRO:
    LEA     INTRO_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS

ENDL:
    LEA     CRLF,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS

;-------------------------------------------------------
; DATA SECTION (STRINGS)
;-------------------------------------------------------
CRLF:           DC.B    13,10,0

INTRO_MSG:      DC.B    '*** THE MYSTERY OF BLACKWOOD CABIN ***',13,10
                DC.B    'Arthur Pendelton is dead. You are the detective.',13,10,0

MENU_MSG:       DC.B    '--- WHAT WILL YOU DO? ---',13,10
                DC.B    '1. Examine the Crime Scene (Study)',13,10
                DC.B    '2. Interrogate Eleanor (Wife)',13,10
                DC.B    '3. Interrogate Julian (Nephew)',13,10
                DC.B    '4. Interrogate Martha (Housekeeper)',13,10
                DC.B    '5. Make an Accusation!',13,10
                DC.B    '0. Quit',13,10
                DC.B    'Action: ',0

SCENE_MSG:      DC.B    '[STUDY] Arthur is slumped over his desk.',13,10
                DC.B    'A shattered teacup lies on the floor.',13,10
                DC.B    'There is a faint smell of bitter almonds (Cyanide).',13,10,0

ELEANOR_MSG:    DC.B    '[ELEANOR] "I was reading in the library. Arthur was furious',13,10
                DC.B    'about his new book. I stayed far away from him."',13,10,0

JULIAN_MSG:     DC.B    '[JULIAN] "I was chopping firewood out in the blizzard!',13,10
                DC.B    'I only came inside when Eleanor screamed."',13,10,0

MARTHA_MSG:     DC.B    '[MARTHA] "I was in the kitchen roasting the beef. The master',13,10
                DC.B    'always takes his tea alone at 4:00 PM. I left it at his door."',13,10,0

ACCUSE_MSG:     DC.B    'Who is the killer? (1=Eleanor, 2=Julian, 3=Martha): ',0

WIN_MSG:        DC.B    'CORRECT! Martha prepared the tea and poisoned it with cyanide.',13,10
                DC.B    'CASE CLOSED.',13,10,0

LOSE_MSG:       DC.B    'WRONG! You arrested an innocent person. The real killer escaped.',13,10
                DC.B    'CASE FAILED.',13,10,0

    END START


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
