;----------------------------------------------------------------------*
; NAME: Emmett Leahy
; STUDENT ID: C00311509
; DESCRIPTION: The Mystery of Blackwood Cabin - A menu based
; detective game where players read clues and interrogate
; suspects before making a final accusation.
;
; INTERMEDIATE FEATURES ADDED:
;   - Turns Remaining (D3): starts at 8, costs 1 per action
;     If turns reach 0 the killer escapes - game over
;   - Evidence Points (D4): gained by examining scenes (+2 each)
;     Talking to Martha gives +1 bonus evidence
;     Need 4+ evidence points to make an accusation
;   - SHOW_STATUS prints both counters before each menu
;----------------------------------------------------------------------*

    ORG     $1000

;-------------------------------------------------------
; REGISTER MAP
; D3 = Turns Remaining  (starts at 8)
; D4 = Evidence Points  (starts at 0, max 10)
; D0 = TRAP task code   (scratch)
; D1 = User input       (scratch)
; A1 = String pointer   (scratch)
;-------------------------------------------------------

;-------------------------------------------------------
; START OF GAME - INITIALISE RESOURCES
;-------------------------------------------------------
START:
    MOVE.B  #8,D3               ; Turns Remaining = 8
    CLR.L   D4                  ; Evidence Points = 0
    BSR     PRINT_INTRO         ; Print the opening story

;-------------------------------------------------------
; MAIN MENU
;-------------------------------------------------------
MAIN_MENU:
    BSR     SHOW_STATUS         ; Show Turns and Evidence before menu
    BSR     ENDL
    LEA     MENU_MSG,A1
    MOVE.B  #14,D0
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
    BEQ     CHECK_EVIDENCE      ; Gate accusation on evidence count
    CMP.B   #0,D1
    BEQ     QUIT_GAME

    ; If invalid input, loop back (no turn cost for bad input)
    BRA     MAIN_MENU

;-------------------------------------------------------
; INVESTIGATION SUBROUTINES
; Each action costs 1 turn. Scenes give +2 evidence.
;-------------------------------------------------------
EXAMINE_SCENE:
    BSR     COST_TURN           ; -1 turn for this action
    BSR     ENDL
    LEA     SCENE_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    ADD.B   #2,D4               ; +2 evidence points
    CMP.B   #10,D4              ; Cap evidence at 10
    BLE     SCENE_DONE
    MOVE.B  #10,D4
SCENE_DONE:
    LEA     GAINED_MSG,A1       ; Print "+2 Evidence Points gained!"
    MOVE.B  #14,D0
    TRAP    #15
    BRA     MAIN_MENU

EXAMINE_LIBRARY:
    BSR     COST_TURN
    BSR     ENDL
    LEA     LIBRARY_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    ADD.B   #2,D4               ; +2 evidence points
    CMP.B   #10,D4
    BLE     LIBRARY_DONE
    MOVE.B  #10,D4
LIBRARY_DONE:
    LEA     GAINED_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA     MAIN_MENU

EXAMINE_KITCHEN:
    BSR     COST_TURN
    BSR     ENDL
    LEA     KITCHEN_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    ADD.B   #2,D4               ; +2 evidence points
    CMP.B   #10,D4
    BLE     KITCHEN_DONE
    MOVE.B  #10,D4
KITCHEN_DONE:
    LEA     GAINED_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA     MAIN_MENU

;-------------------------------------------------------
; INTERROGATION SUBROUTINES
; Each costs 1 turn. Martha gives +1 bonus evidence.
;-------------------------------------------------------
TALK_ELEANOR:
    BSR     COST_TURN
    BSR     ENDL
    LEA     ELEANOR_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA     MAIN_MENU

TALK_JULIAN:
    BSR     COST_TURN
    BSR     ENDL
    LEA     JULIAN_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA     MAIN_MENU

TALK_MARTHA:
    BSR     COST_TURN
    BSR     ENDL
    LEA     MARTHA_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    ADD.B   #1,D4               ; +1 bonus evidence (key witness)
    CMP.B   #10,D4
    BLE     MARTHA_DONE
    MOVE.B  #10,D4
MARTHA_DONE:
    LEA     MARTHA_BONUS_MSG,A1 ; Print "Key detail noted! +1 Evidence"
    MOVE.B  #14,D0
    TRAP    #15
    BRA     MAIN_MENU

;-------------------------------------------------------
; EVIDENCE GATE - CHECK BEFORE ALLOWING ACCUSATION
;-------------------------------------------------------
CHECK_EVIDENCE:
    CMP.B   #4,D4               ; Need at least 4 evidence points
    BGE     ACCUSE_SUSPECT      ; Enough evidence -> proceed
    BSR     ENDL
    LEA     LOW_EVIDENCE_MSG,A1 ; Not enough evidence yet
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

    ; The killer is Martha (option 3)
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

TIME_UP:
    BSR     ENDL
    LEA     TIMEUP_MSG,A1       ; Print time expired message
    MOVE.B  #14,D0
    TRAP    #15
    SIMHALT                     ; Killer escapes - game over

QUIT_GAME:
    SIMHALT

;-------------------------------------------------------
; COST_TURN SUBROUTINE
; Deducts 1 from D3 (turns remaining).
; If D3 reaches 0, jumps to TIME_UP (game over).
; Called at the start of every investigation/interrogation.
;-------------------------------------------------------
COST_TURN:
    SUB.B   #1,D3               ; -1 turn
    CMP.B   #0,D3               ; Have all turns been used?
    BEQ     TIME_UP             ; Yes -> game over
    RTS

;-------------------------------------------------------
; SHOW_STATUS SUBROUTINE
; Prints Turns Remaining and Evidence Points before each menu.
; Uses TRAP #15 task 3 to print the integer values in D3/D4.
;-------------------------------------------------------
SHOW_STATUS:
    LEA     STATUS_HDR,A1       ; "--- DETECTIVE STATUS ---"
    MOVE.B  #14,D0
    TRAP    #15
    LEA     TURN_LBL,A1         ; "Turns Remaining : "
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  D3,D1               ; Load turns into D1 for printing
    MOVE.B  #3,D0               ; TRAP task 3 = print integer in D1
    TRAP    #15
    BSR     ENDL
    LEA     EVID_LBL,A1         ; "Evidence Points  : "
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  D4,D1               ; Load evidence into D1 for printing
    MOVE.B  #3,D0               ; Print integer
    TRAP    #15
    LEA     STATUS_FTR,A1       ; Closing separator line
    MOVE.B  #14,D0
    TRAP    #15
    RTS

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
; Prints error message and loops back to re-prompt (no turn cost)
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
                DC.B    '*                                      *',13,10
                DC.B    '* THE MYSTERY OF BLACKWOOD CABIN       *',13,10
                DC.B    '*                                      *',13,10
                DC.B    '****************************************',13,10
                DC.B    ' Arthur Pendelton is dead. The blizzard',13,10
                DC.B    ' howls outside. You are the detective. ',13,10
                DC.B    ' You have 8 turns before the killer    ',13,10
                DC.B    ' slips away into the storm!            ',13,10,0

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
                DC.B    '  7. MAKE AN ACCUSATION! (needs 4 evidence)',13,10
                DC.B    '  0. Quit Case',13,10
                DC.B    '========================================',13,10
                DC.B    ' Enter Choice (0-7): ',0

; --- Status display strings ---
STATUS_HDR:     DC.B    13,10,'--- DETECTIVE STATUS ---',13,10,0
TURN_LBL:       DC.B    ' Turns Remaining : ',0
EVID_LBL:       DC.B    ' Evidence Points : ',0
STATUS_FTR:     DC.B    13,10,'------------------------',13,10,0

; --- Feedback strings ---
GAINED_MSG:     DC.B    '>> +2 Evidence Points gained!',13,10,0
MARTHA_BONUS_MSG: DC.B  '>> Key detail noted! +1 Evidence Point.',13,10,0
LOW_EVIDENCE_MSG: DC.B  '!! Not enough evidence to accuse yet.',13,10
                DC.B    '!! Keep investigating (need 4 points).',13,10,0
TIMEUP_MSG:     DC.B    '!! Time has run out. The killer escapes',13,10
                DC.B    '   into the blizzard. CASE FAILED.',13,10,0

; --- Scene strings ---
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

ACCUSE_MSG:     DC.B    13,10,'Who is the killer? (1=Eleanor, 2=Julian, 3=Martha): ',0

WIN_MSG:        DC.B    'CORRECT! Martha prepared the tea and poisoned it with cyanide.',13,10
                DC.B    'CASE CLOSED.',13,10,0

LOSE_MSG:       DC.B    'WRONG! You arrested an innocent person. The real killer escaped.',13,10
                DC.B    'CASE FAILED.',13,10,0

ERR_MSG:        DC.B    '!!! INVALID SELECTION: Please enter a valid number !!!',13,10,0

    END START
