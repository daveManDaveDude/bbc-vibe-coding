\ Minimal BBC Micro Model B entry point for the first build.

INCLUDE "lib/os.asm"
INCLUDE "lib/macros.asm"

player_min_column = 3
player_max_column = 34
player_min_row = 10
player_max_row = 16
player_char_frame_0 = 224
player_char_frame_1 = 225
vdu_define_character = 23

ORG &1900
GUARD &7C00

.start
    JSR init_screen
    JSR define_player_chars
    JSR init_static_state
    JSR init_input_state
    JSR draw_static_scene

.main_loop
    JSR poll_keyboard_state
    JSR update_player_position
    JSR draw_player_state
    JSR draw_input_status
    JSR wait_for_vsync
    JMP main_loop

.init_screen
    \ Mode 1 keeps text readable and gives the next milestone room for simple colour.
    VDU vdu_set_mode
    VDU mode_1
    VDU vdu_cls
    VDU vdu_home
    RTS

.init_static_state
    \ Keep the placeholder entity position in RAM so later milestones can inspect and reuse it.
    LDA #18
    STA player_column
    STA previous_player_column
    LDA #12
    STA player_row
    STA previous_player_row
    LDA #0
    STA player_frame
    LDA #0
    STA player_moved
    RTS

.init_input_state
    LDA #0
    STA key_w_down
    STA key_a_down
    STA key_s_down
    STA key_d_down
    LDA #ascii_dash
    STA active_key_char
    RTS

.draw_static_scene
    LDA #LO(screen_message)
    STA zp_ptr
    LDA #HI(screen_message)
    STA zp_ptr+1
    JSR print_string
    JSR draw_playfield_frame
    JSR draw_player_marker
    JSR draw_input_status
    RTS

.define_player_chars
    \ Keep the experiment small: one moving user character with two simple step frames.
    LDA #LO(player_char_frame_0_rows)
    STA zp_ptr
    LDA #HI(player_char_frame_0_rows)
    STA zp_ptr+1
    LDA #player_char_frame_0
    JSR define_character

    LDA #LO(player_char_frame_1_rows)
    STA zp_ptr
    LDA #HI(player_char_frame_1_rows)
    STA zp_ptr+1
    LDA #player_char_frame_1
    JSR define_character
    RTS

.define_character
    PHA
    VDU vdu_define_character
    PLA
    JSR oswrch
    LDY #0

.define_character_loop
    LDA (zp_ptr),Y
    JSR oswrch
    INY
    CPY #8
    BNE define_character_loop
    RTS

.draw_playfield_frame
    LDA #0
    LDX #9
    JSR set_text_cursor
    LDA #LO(playfield_frame)
    STA zp_ptr
    LDA #HI(playfield_frame)
    STA zp_ptr+1
    JSR print_string
    RTS

.draw_player_marker
    LDA player_column
    LDX player_row
    JSR set_text_cursor
    JSR get_player_render_char
    JSR oswrch
    RTS

.get_player_render_char
    LDA player_frame
    BEQ use_player_frame_0
    LDA #player_char_frame_1
    RTS

.use_player_frame_0
    LDA #player_char_frame_0
    RTS

.set_text_cursor
    \ VDU 31 moves the text cursor to X,Y in the current text window.
    PHA
    VDU vdu_tab
    PLA
    JSR oswrch
    TXA
    JSR oswrch
    RTS

.poll_keyboard_state
    LDX #inkey_w
    LDY #inkey_negative_high
    JSR scan_key_state
    STA key_w_down

    LDX #inkey_a
    LDY #inkey_negative_high
    JSR scan_key_state
    STA key_a_down

    LDX #inkey_s
    LDY #inkey_negative_high
    JSR scan_key_state
    STA key_s_down

    LDX #inkey_d
    LDY #inkey_negative_high
    JSR scan_key_state
    STA key_d_down

    JSR update_active_key
    RTS

.scan_key_state
    LDA #osbyte_inkey
    JSR osbyte
    TXA
    BEQ key_not_pressed
    LDA #1
    RTS

.key_not_pressed
    LDA #0
    RTS

.update_active_key
    LDA #ascii_dash
    STA active_key_char

    LDA key_w_down
    BNE active_w
    LDA key_a_down
    BNE active_a
    LDA key_s_down
    BNE active_s
    LDA key_d_down
    BNE active_d
    RTS

.active_w
    LDA #'W'
    STA active_key_char
    RTS

.active_a
    LDA #'A'
    STA active_key_char
    RTS

.active_s
    LDA #'S'
    STA active_key_char
    RTS

.active_d
    LDA #'D'
    STA active_key_char
    RTS

.update_player_position
    LDA player_column
    STA previous_player_column
    LDA player_row
    STA previous_player_row

    LDA #0
    STA player_moved

    LDA key_w_down
    BEQ skip_move_up
    LDA player_row
    CMP #player_min_row
    BEQ skip_move_up
    DEC player_row

.skip_move_up
    LDA key_s_down
    BEQ skip_move_down
    LDA player_row
    CMP #player_max_row
    BEQ skip_move_down
    INC player_row

.skip_move_down
    LDA key_a_down
    BEQ skip_move_left
    LDA player_column
    CMP #player_min_column
    BEQ skip_move_left
    DEC player_column

.skip_move_left
    LDA key_d_down
    BEQ skip_move_right
    LDA player_column
    CMP #player_max_column
    BEQ skip_move_right
    INC player_column

.skip_move_right
    LDA player_column
    CMP previous_player_column
    BNE player_position_changed
    LDA player_row
    CMP previous_player_row
    BNE player_position_changed
    RTS

.player_position_changed
    LDA #1
    STA player_moved
    LDA player_frame
    EOR #1
    STA player_frame
    RTS

.draw_player_state
    LDA player_moved
    BEQ draw_player_state_done
    JSR erase_previous_player
    JSR draw_player_marker

.draw_player_state_done
    RTS

.erase_previous_player
    LDA previous_player_column
    LDX previous_player_row
    JSR set_text_cursor
    LDA #' '
    JSR oswrch
    RTS

.draw_input_status
    LDA #2
    LDX #19
    JSR set_text_cursor
    LDA #LO(input_status_prefix)
    STA zp_ptr
    LDA #HI(input_status_prefix)
    STA zp_ptr+1
    JSR print_string
    LDA key_w_down
    JSR print_state_digit
    LDA #LO(input_status_a)
    STA zp_ptr
    LDA #HI(input_status_a)
    STA zp_ptr+1
    JSR print_string
    LDA key_a_down
    JSR print_state_digit
    LDA #LO(input_status_s)
    STA zp_ptr
    LDA #HI(input_status_s)
    STA zp_ptr+1
    JSR print_string
    LDA key_s_down
    JSR print_state_digit
    LDA #LO(input_status_d)
    STA zp_ptr
    LDA #HI(input_status_d)
    STA zp_ptr+1
    JSR print_string
    LDA key_d_down
    JSR print_state_digit

    LDA #2
    LDX #20
    JSR set_text_cursor
    LDA #LO(active_status_prefix)
    STA zp_ptr
    LDA #HI(active_status_prefix)
    STA zp_ptr+1
    JSR print_string
    LDA active_key_char
    JSR oswrch
    LDA #LO(active_status_suffix)
    STA zp_ptr
    LDA #HI(active_status_suffix)
    STA zp_ptr+1
    JSR print_string

    LDA #2
    LDX #21
    JSR set_text_cursor
    LDA #LO(movement_bounds_status)
    STA zp_ptr
    LDA #HI(movement_bounds_status)
    STA zp_ptr+1
    JSR print_string

    LDA #2
    LDX #22
    JSR set_text_cursor
    LDA #LO(render_status_prefix)
    STA zp_ptr
    LDA #HI(render_status_prefix)
    STA zp_ptr+1
    JSR print_string
    LDA #'['
    JSR oswrch
    LDA #'P'
    JSR oswrch
    LDA #']'
    JSR oswrch
    LDA #LO(render_status_middle)
    STA zp_ptr
    LDA #HI(render_status_middle)
    STA zp_ptr+1
    JSR print_string
    LDA #player_char_frame_0
    JSR oswrch
    LDA #player_char_frame_1
    JSR oswrch
    LDA #LO(render_status_suffix)
    STA zp_ptr
    LDA #HI(render_status_suffix)
    STA zp_ptr+1
    JSR print_string

    LDA #2
    LDX #23
    JSR set_text_cursor
    LDA #LO(frame_status_prefix)
    STA zp_ptr
    LDA #HI(frame_status_prefix)
    STA zp_ptr+1
    JSR print_string
    LDA player_frame
    JSR print_state_digit
    LDA #LO(frame_status_suffix)
    STA zp_ptr
    LDA #HI(frame_status_suffix)
    STA zp_ptr+1
    JSR print_string
    RTS

.print_state_digit
    ORA #ascii_zero
    JSR oswrch
    RTS

.wait_for_vsync
    LDA #osbyte_wait_vsync
    JSR osbyte
    RTS

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

.screen_message
    EQUS "================================", ascii_cr
    EQUS "BBC MICRO CHAR RENDER CHECK", ascii_cr
    EQUS "MODE 1 READY", ascii_cr
    EQUS "W A S D MOVE A USER-DEFINED CHAR", ascii_cr
    EQUS "STEP FRAME FLIPS ON EACH MOVE", ascii_cr
    EQUS "================================", ascii_cr
    EQUS ascii_cr
    EQUS "COMPARE THE HUD WITH THE LIVE CELL", ascii_cr, 0

.playfield_frame
    EQUS "  +----------------------------------+", ascii_cr
    EQUS "  |                                  |", ascii_cr
    EQUS "  |                                  |", ascii_cr
    EQUS "  |                                  |", ascii_cr
    EQUS "  |                                  |", ascii_cr
    EQUS "  |                                  |", ascii_cr
    EQUS "  |                                  |", ascii_cr
    EQUS "  |                                  |", ascii_cr
    EQUS "  +----------------------------------+", 0

.input_status_prefix
    EQUS "INPUT W:", 0

.input_status_a
    EQUS " A:", 0

.input_status_s
    EQUS " S:", 0

.input_status_d
    EQUS " D:", 0

.active_status_prefix
    EQUS "ACTIVE:", 0

.active_status_suffix
    EQUS "  CHAR RENDER LOOP ACTIVE ", 0

.movement_bounds_status
    EQUS "AREA: COL 3-34 ROW 10-16       ", 0

.render_status_prefix
    EQUS "BASE:", 0

.render_status_middle
    EQUS " LIVE:", 0

.render_status_suffix
    EQUS " USER CHARS     ", 0

.frame_status_prefix
    EQUS "FRAME:", 0

.frame_status_suffix
    EQUS " STEP FLIPS ON MOVE      ", 0

.player_char_frame_0_rows
    EQUB &18, &3C, &7E, &DB, &FF, &24, &24, &42

.player_char_frame_1_rows
    EQUB &18, &3C, &7E, &DB, &FF, &24, &5A, &81

.player_column
    EQUB 0

.player_row
    EQUB 0

.previous_player_column
    EQUB 0

.previous_player_row
    EQUB 0

.key_w_down
    EQUB 0

.key_a_down
    EQUB 0

.key_s_down
    EQUB 0

.key_d_down
    EQUB 0

.active_key_char
    EQUB 0

.player_frame
    EQUB 0

.player_moved
    EQUB 0
.end

SAVE "GAME", start, end, start
