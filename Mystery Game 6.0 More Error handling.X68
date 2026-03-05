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
    LEA     MENU_MSG,A1         ; Load menu options
    MOVE.B  #14,D0              ; Print string
    TRAP    #15
    
    MOVE.B  #4,D0               ; Read integer into D1
    TRAP    #15
    
    ; --- Error Handling: Range Check (0 to 7) ---
    CMP.B   #0,D1               ; Check if input is less than 0
    BLT     INVALID_INPUT
    CMP.B   #7,D1               ; Check if input is greater than 7
    BGT     INVALID_INPUT

    ; --- Branching based on valid player input ---
    CMP.B   #1,D1
    BEQ     EXAMINE_SCENE
    CMP.B   #2,D1
    BEQ     EXAMINE_LIBRARY
    CMP.B   #3,D1
    BEQ     EXAMINE_KITCHEN
    CMP.B   #4,D1
    BEQ     TALK_ELEANOR
    CMP.B   #5,D1
    BEQ     TALK_JULIAN
    CMP.B   #6,D1
    BEQ     TALK_MARTHA
    CMP.B   #7,D1
    BEQ     ACCUSE_SUSPECT
    CMP.B   #0,D1
    BEQ     QUIT_GAME
    
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

EXAMINE_LIBRARY:
    BSR     ENDL
    LEA     LIBRARY_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA     MAIN_MENU

EXAMINE_KITCHEN:
    BSR     ENDL
    LEA     KITCHEN_MSG,A1
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
    LEA     ACCUSE_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #4,D0               ; Read integer
    TRAP    #15

    ; --- Error Handling: Valid suspect range (1 to 3) ---
    CMP.B   #1,D1
    BLT     INVALID_ACCUSE
    CMP.B   #3,D1
    BGT     INVALID_ACCUSE
    
    ; The killer is Martha
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
; UTILITIES & ERROR HANDLING
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

; --- Error handler for MAIN_MENU ---
; Triggered when D1 is outside range 0-7
; Prints error message and loops back to re-prompt
INVALID_INPUT:
    BSR     ENDL
    LEA     ERR_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA     MAIN_MENU

; --- Error handler for ACCUSE_SUSPECT ---
; Triggered when D1 is outside range 1-3
; Prints error message and loops back to re-prompt
INVALID_ACCUSE:
    BSR     ENDL
    LEA     ERR_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA     ACCUSE_SUSPECT

;-------------------------------------------------------
; DATA SECTION (STRINGS)
;-------------------------------------------------------
CRLF:           DC.B    13,10,0

INTRO_MSG:      DC.B    '****************************************',13,10
                DC.B    '* *',13,10
                DC.B    '* THE MYSTERY OF BLACKWOOD CABIN      *',13,10
                DC.B    '* *',13,10
                DC.B    '****************************************',13,10
                DC.B    ' Arthur Pendelton is dead. The blizzard ',13,10
                DC.B    ' howls outside. You are the detective.  ',13,10,0

MENU_MSG:       DC.B    13,10,'========================================',13,10
                DC.B    '|          WHAT WILL YOU DO?           |',13,10
                DC.B    '========================================',13,10
                DC.B    ' --- INVESTIGATE ---',13,10
                DC.B    '  1. Examine Crime Scene (Study)',13,10
                DC.B    '  2. Examine the Library',13,10
                DC.B    '  3. Examine the Kitchen',13,10
                DC.B    ' --- INTERROGATE ---',13,10
                DC.B    '  4. Talk to Eleanor (The Wife)',13,10
                DC.B    '  5. Talk to Julian  (The Nephew)',13,10
                DC.B    '  6. Talk to Martha  (The Housekeeper)',13,10
                DC.B    ' --- ACTIONS ---',13,10
                DC.B    '  7. MAKE AN ACCUSATION!',13,10
                DC.B    '  0. Quit Case',13,10
                DC.B    '========================================',13,10
                DC.B    ' Enter Choice (0-7): ',0

SCENE_MSG:      DC.B    '[STUDY] Arthur is slumped over his desk.',13,10
                DC.B    'A shattered teacup lies on the floor.',13,10
                DC.B    'There is a faint smell of bitter almonds (Cyanide).',13,10,0

LIBRARY_MSG:    DC.B    '[LIBRARY] A fire roars in the hearth. On a side table,',13,10
                DC.B    'you find a freshly torn document. It looks like a will',13,10
                DC.B    'cutting Eleanor out of the inheritance.',13,10,0

KITCHEN_MSG:    DC.B    '[KITCHEN] The smell of roast beef fills the room.',13,10
                DC.B    'Near the tea kettle, an empty vial labeled "Rat Poison"',13,10
                DC.B    'sits on the counter. The active ingredient is Cyanide.',13,10,0

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

ERR_MSG:        DC.B    '!!! INVALID SELECTION: Please enter a valid number !!!',13,10,0

    END START
