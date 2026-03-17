\ Minimal BBC Micro Model B entry point for the first build.

INCLUDE "lib/os.asm"
INCLUDE "lib/macros.asm"

ORG &1900
GUARD &7C00

.start
    VDU vdu_set_mode
    VDU mode_7

    LDA #LO(message)
    STA zp_ptr
    LDA #HI(message)
    STA zp_ptr+1
    JSR print_string

.hang
    JMP hang

.print_string
    LDY #0
.print_loop
    LDA (zp_ptr),Y
    BEQ print_done
    JSR osasci
    INY
    BNE print_loop
.print_done
    RTS

.message
    EQUS "BBC Micro repo build is live", ascii_cr
    EQUS "Edit src/game.asm, then make run.", ascii_cr, 0
.end

SAVE "GAME", start, end, start
