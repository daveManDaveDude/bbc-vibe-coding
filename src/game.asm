\ Graphics stress test: frame-paced diagonal bounce with keyboard steering and single-pass packed sprite redraw.

INCLUDE "lib/os.asm"
INCLUDE "lib/macros.asm"

graphics_mode = mode_5
mode_5_screen_base = &5800
screen_scanlines_per_character_row = 8
screen_bytes_per_character_row = 320
screen_row_wrap_increment = screen_bytes_per_character_row-(screen_scanlines_per_character_row-1)

logical_colour_background = 0
logical_colour_sprite_primary = 1
logical_colour_sprite_secondary = 2
logical_colour_sprite_highlight = 3

physical_colour_black = 0
physical_colour_red = 1
physical_colour_yellow = 3
physical_colour_white = 7

cursor_control_block = 1

sprite_variant_row_bytes = 4
sprite_width_pixels = 12
sprite_height_pixels = 14
sprite_min_x_pixels = 0
sprite_max_x_pixels = 147
sprite_min_y_pixels = 0
sprite_max_y_pixels = 242
reference_sprite_x_pixels = 74
reference_sprite_y_pixels = 104
moving_sprite_initial_x_pixels = 74
moving_sprite_initial_y_pixels = 160
sprite_frame_interval_vsyncs = 2

sprite_facing_right = 0
sprite_facing_left = 1

sprite_vertical_down = 0
sprite_vertical_up = 1

ORG &1900
GUARD mode_5_screen_base

.start
    JSR init_graphics_baseline
    JSR init_sprite_state
    JSR init_input_state
    JSR draw_reference_sprite
    JSR draw_current_sprite

.main_loop
    JSR wait_for_vsync
    JSR poll_keyboard_state
    JSR maybe_step_sprite
    JSR draw_reference_sprite
    JMP main_loop

.init_graphics_baseline
    \ Mode 5 keeps a full-height bitmap display while leaving more RAM headroom than Mode 2.
    VDU vdu_set_mode
    VDU graphics_mode

    \ Reset colours before assigning the sprite-friendly palette for later milestones.
    VDU vdu_restore_default_colours
    JSR set_graphics_palette
    JSR disable_text_cursor
    JSR clear_playfield
    RTS

.init_sprite_state
    \ Keep top-left pixel coordinates in RAM and reserve fraction bytes for later fixed-point growth.
    LDA #moving_sprite_initial_x_pixels
    STA sprite_x_pixels
    STA previous_sprite_x_pixels
    LDA #moving_sprite_initial_y_pixels
    STA sprite_y_pixels
    STA previous_sprite_y_pixels

    LDA #0
    STA sprite_x_subpixel
    STA sprite_y_subpixel
    STA sprite_frame_counter
    STA sprite_anim_step_counter
    STA sprite_anim_frame
    STA sprite_blit_mode

    LDA #sprite_facing_right
    STA sprite_facing
    LDA #sprite_vertical_up
    STA sprite_vertical_direction
    RTS

.init_input_state
    LDA #0
    STA key_w_down
    STA key_a_down
    STA key_s_down
    STA key_d_down
    RTS

.set_graphics_palette
    LDA #logical_colour_background
    LDX #physical_colour_red
    JSR set_logical_palette_colour

    LDA #logical_colour_sprite_primary
    LDX #physical_colour_yellow
    JSR set_logical_palette_colour

    LDA #logical_colour_sprite_secondary
    LDX #physical_colour_black
    JSR set_logical_palette_colour

    LDA #logical_colour_sprite_highlight
    LDX #physical_colour_white
    JSR set_logical_palette_colour
    RTS

.set_logical_palette_colour
    PHA
    VDU vdu_palette
    PLA
    JSR oswrch
    TXA
    JSR oswrch
    LDA #0
    JSR oswrch
    JSR oswrch
    JSR oswrch
    RTS

.disable_text_cursor
    \ VDU 23,1,0;0;0;0; keeps the bitmap baseline visually clean.
    VDU vdu_extended_command
    VDU cursor_control_block
    VDU 0
    VDU 0
    VDU 0
    VDU 0
    VDU 0
    VDU 0
    VDU 0
    VDU 0
    RTS

.clear_playfield
    \ Clear both text and graphics areas so earlier runs cannot leak through.
    VDU vdu_cls
    VDU vdu_clg
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

.maybe_step_sprite
    INC sprite_frame_counter
    LDA sprite_frame_counter
    CMP #sprite_frame_interval_vsyncs
    BCC maybe_step_sprite_done

    LDA #0
    STA sprite_frame_counter

    LDA sprite_x_pixels
    STA previous_sprite_x_pixels
    LDA sprite_y_pixels
    STA previous_sprite_y_pixels

    JSR advance_bouncing_sprite
    JSR apply_input_nudges
    LDA sprite_x_pixels
    CMP previous_sprite_x_pixels
    BNE sprite_position_changed
    LDA sprite_y_pixels
    CMP previous_sprite_y_pixels
    BEQ maybe_step_sprite_done

.sprite_position_changed
    JSR advance_sprite_animation
    JSR composite_sprite_transition

.maybe_step_sprite_done
    RTS

.advance_bouncing_sprite
    LDA sprite_facing
    BEQ step_sprite_right

    LDA sprite_x_pixels
    CMP #sprite_min_x_pixels
    BEQ bounce_sprite_right
    DEC sprite_x_pixels
    JMP advance_vertical_motion

.bounce_sprite_right
    LDA #sprite_facing_right
    STA sprite_facing
    INC sprite_x_pixels
    JMP advance_vertical_motion

.step_sprite_right
    LDA sprite_x_pixels
    CMP #sprite_max_x_pixels
    BEQ bounce_sprite_left
    INC sprite_x_pixels
    JMP advance_vertical_motion

.bounce_sprite_left
    LDA #sprite_facing_left
    STA sprite_facing
    DEC sprite_x_pixels

.advance_vertical_motion
    LDA sprite_vertical_direction
    BEQ step_sprite_down

    LDA sprite_y_pixels
    CMP #sprite_min_y_pixels
    BEQ bounce_sprite_down
    DEC sprite_y_pixels
    RTS

.bounce_sprite_down
    LDA #sprite_vertical_down
    STA sprite_vertical_direction
    INC sprite_y_pixels
    RTS

.step_sprite_down
    LDA sprite_y_pixels
    CMP #sprite_max_y_pixels
    BEQ bounce_sprite_up
    INC sprite_y_pixels
    RTS

.bounce_sprite_up
    LDA #sprite_vertical_up
    STA sprite_vertical_direction
    DEC sprite_y_pixels
    RTS

.apply_input_nudges
    LDA key_w_down
    BEQ skip_nudge_up
    JSR nudge_sprite_up

.skip_nudge_up
    LDA key_s_down
    BEQ skip_nudge_down
    JSR nudge_sprite_down

.skip_nudge_down
    LDA key_a_down
    BEQ skip_nudge_left
    JSR nudge_sprite_left

.skip_nudge_left
    LDA key_d_down
    BEQ apply_input_nudges_done
    JSR nudge_sprite_right

.apply_input_nudges_done
    RTS

.nudge_sprite_up
    LDA sprite_y_pixels
    CMP #sprite_min_y_pixels
    BEQ nudge_top_edge
    DEC sprite_y_pixels
    RTS

.nudge_top_edge
    LDA #sprite_vertical_down
    STA sprite_vertical_direction
    RTS

.nudge_sprite_down
    LDA sprite_y_pixels
    CMP #sprite_max_y_pixels
    BEQ nudge_bottom_edge
    INC sprite_y_pixels
    RTS

.nudge_bottom_edge
    LDA #sprite_vertical_up
    STA sprite_vertical_direction
    RTS

.nudge_sprite_left
    LDA sprite_x_pixels
    CMP #sprite_min_x_pixels
    BEQ nudge_left_edge
    DEC sprite_x_pixels
    RTS

.nudge_left_edge
    LDA #sprite_facing_right
    STA sprite_facing
    RTS

.nudge_sprite_right
    LDA sprite_x_pixels
    CMP #sprite_max_x_pixels
    BEQ nudge_right_edge
    INC sprite_x_pixels
    RTS

.nudge_right_edge
    LDA #sprite_facing_left
    STA sprite_facing
    RTS

.advance_sprite_animation
    LDA sprite_x_pixels
    CMP previous_sprite_x_pixels
    BEQ use_neutral_sprite_frame

    INC sprite_anim_step_counter
    LDA sprite_anim_step_counter
    AND #1
    BNE keep_current_sprite_frame

    LDA sprite_anim_frame
    EOR #1
    STA sprite_anim_frame

.keep_current_sprite_frame
    RTS

.use_neutral_sprite_frame
    LDA #0
    STA sprite_anim_frame
    RTS

.composite_sprite_transition
    JSR init_composite_geometry
    JSR init_composite_destination_pointer
    JSR init_composite_source_pointer
    LDA #sprite_height_pixels
    STA composite_current_rows_remaining

.composite_sprite_transition_row
    JSR clear_composite_row_buffer
    LDA composite_rows_before_current
    BEQ composite_sprite_row_check
    DEC composite_rows_before_current
    JMP composite_write_transition_row

.composite_sprite_row_check
    LDA composite_current_rows_remaining
    BEQ composite_write_transition_row
    JSR copy_composite_sprite_row_to_buffer
    DEC composite_current_rows_remaining

.composite_write_transition_row
    JSR write_composite_row_buffer
    DEC composite_rows_remaining
    BEQ composite_sprite_transition_done
    JSR advance_sprite_destination_pointer
    JMP composite_sprite_transition_row

.composite_sprite_transition_done
    RTS

.init_composite_geometry
    LDA sprite_x_pixels
    AND #&FC
    STA composite_current_aligned_x

    LDA previous_sprite_x_pixels
    AND #&FC
    CMP composite_current_aligned_x
    BCC composite_previous_x_before_current
    BEQ composite_same_x_band

    LDA composite_current_aligned_x
    STA composite_x_pixels
    LDA #0
    STA composite_current_byte_offset
    LDA #5
    STA composite_byte_count
    JMP init_composite_y_geometry

.composite_previous_x_before_current
    STA composite_x_pixels
    LDA #1
    STA composite_current_byte_offset
    LDA #5
    STA composite_byte_count
    JMP init_composite_y_geometry

.composite_same_x_band
    LDA composite_current_aligned_x
    STA composite_x_pixels
    LDA #0
    STA composite_current_byte_offset
    LDA #4
    STA composite_byte_count

.init_composite_y_geometry
    LDA previous_sprite_y_pixels
    CMP sprite_y_pixels
    BCC composite_previous_y_above_current
    BEQ composite_same_y_band

    LDA sprite_y_pixels
    STA composite_y_pixels
    LDA #0
    STA composite_rows_before_current
    SEC
    LDA previous_sprite_y_pixels
    SBC sprite_y_pixels
    CLC
    ADC #sprite_height_pixels
    STA composite_rows_remaining
    RTS

.composite_previous_y_above_current
    LDA previous_sprite_y_pixels
    STA composite_y_pixels
    SEC
    LDA sprite_y_pixels
    SBC previous_sprite_y_pixels
    STA composite_rows_before_current
    CLC
    ADC #sprite_height_pixels
    STA composite_rows_remaining
    RTS

.composite_same_y_band
    LDA sprite_y_pixels
    STA composite_y_pixels
    LDA #0
    STA composite_rows_before_current
    LDA #sprite_height_pixels
    STA composite_rows_remaining
    RTS

.init_composite_destination_pointer
    LDA composite_x_pixels
    STA blit_x_pixels
    LDA composite_y_pixels
    STA blit_y_pixels
    JSR init_sprite_destination_pointer
    LDA blit_y_pixels
    AND #screen_scanlines_per_character_row-1
    STA current_scanline_in_band
    RTS

.init_composite_source_pointer
    LDA sprite_x_pixels
    AND #3
    STA sprite_pixel_shift
    JSR init_sprite_source_pointer
    RTS

.clear_composite_row_buffer
    LDA #0
    STA composite_row_buffer_0
    STA composite_row_buffer_1
    STA composite_row_buffer_2
    STA composite_row_buffer_3
    STA composite_row_buffer_4
    RTS

.copy_composite_sprite_row_to_buffer
    LDX #0
    LDY composite_current_byte_offset

.copy_composite_sprite_row_source
    LDA &FFFF,X
    STA composite_row_buffer_0,Y
    INX
    INY
    CPX #sprite_variant_row_bytes
    BNE copy_composite_sprite_row_source
    JSR advance_sprite_source_pointer
    RTS

.write_composite_row_buffer
    LDY #0
    LDA composite_row_buffer_0
    STA (zp_ptr),Y
    LDY #8
    LDA composite_row_buffer_1
    STA (zp_ptr),Y
    LDY #16
    LDA composite_row_buffer_2
    STA (zp_ptr),Y
    LDY #24
    LDA composite_row_buffer_3
    STA (zp_ptr),Y
    LDA composite_byte_count
    CMP #5
    BNE write_composite_row_buffer_done
    LDY #32
    LDA composite_row_buffer_4
    STA (zp_ptr),Y

.write_composite_row_buffer_done
    RTS

.draw_current_sprite
    LDA sprite_x_pixels
    STA blit_x_pixels
    LDA sprite_y_pixels
    STA blit_y_pixels
    LDA #0
    STA sprite_blit_mode
    JSR blit_sprite_rectangle
    RTS

.draw_reference_sprite
    \ Keep a fixed sprite on screen so captures can compare a known-good static render with the moving one.
    LDA sprite_x_pixels
    PHA
    LDA sprite_y_pixels
    PHA
    LDA sprite_anim_frame
    PHA
    LDA sprite_facing
    PHA

    LDA #reference_sprite_x_pixels
    STA sprite_x_pixels
    LDA #reference_sprite_y_pixels
    STA sprite_y_pixels
    LDA #0
    STA sprite_anim_frame
    LDA #sprite_facing_right
    STA sprite_facing
    JSR draw_current_sprite

    PLA
    STA sprite_facing
    PLA
    STA sprite_anim_frame
    PLA
    STA sprite_y_pixels
    PLA
    STA sprite_x_pixels
    RTS

.erase_previous_sprite
    \ The current scene is a black playfield, so erase can clear the sprite's covered row bytes to zero.
    LDA previous_sprite_x_pixels
    STA blit_x_pixels
    LDA previous_sprite_y_pixels
    STA blit_y_pixels
    LDA #1
    STA sprite_blit_mode
    JSR blit_sprite_rectangle
    RTS

.blit_sprite_rectangle
    JSR init_sprite_destination_pointer
    LDA #0
    STA current_sprite_row
    LDA blit_y_pixels
    AND #screen_scanlines_per_character_row-1
    STA current_scanline_in_band

    LDA sprite_blit_mode
    BNE blit_rows_ready
    JSR init_sprite_source_pointer

.blit_rows_ready
.blit_sprite_rectangle_row
    LDA sprite_blit_mode
    BNE clear_sprite_row_bytes
    JSR draw_packed_sprite_row
    JMP advance_after_sprite_row

.clear_sprite_row_bytes
    JSR erase_sprite_row_bytes

.advance_after_sprite_row
    INC current_sprite_row
    LDA current_sprite_row
    CMP #sprite_height_pixels
    BEQ blit_sprite_rectangle_done

    JSR advance_sprite_destination_pointer
    LDA sprite_blit_mode
    BNE blit_sprite_rectangle_row
    JSR advance_sprite_source_pointer
    JMP blit_sprite_rectangle_row

.blit_sprite_rectangle_done
    RTS

.init_sprite_destination_pointer
    \ A Mode 5 byte spans four logical pixels, so arbitrary X uses a byte offset plus a 0-3 pixel shift.
    LDA blit_x_pixels
    AND #3
    STA sprite_pixel_shift

    LDA blit_x_pixels
    AND #&FC
    ASL A
    STA sprite_row_x_offset_low
    LDA #0
    ROL A
    STA sprite_row_x_offset_high

    LDA blit_y_pixels
    LSR A
    LSR A
    LSR A
    TAX

    LDA mode_5_band_base_low,X
    CLC
    ADC sprite_row_x_offset_low
    STA zp_ptr
    LDA mode_5_band_base_high,X
    ADC sprite_row_x_offset_high
    STA zp_ptr+1

    LDA blit_y_pixels
    AND #screen_scanlines_per_character_row-1
    CLC
    ADC zp_ptr
    STA zp_ptr
    BCC init_sprite_destination_pointer_done
    INC zp_ptr+1

.init_sprite_destination_pointer_done
    RTS

.init_sprite_source_pointer
    LDA sprite_anim_frame
    ASL A
    ASL A
    CLC
    ADC sprite_pixel_shift
    LDX sprite_facing
    BEQ sprite_source_variant_ready
    CLC
    ADC #8

.sprite_source_variant_ready
    TAX
    LDA sprite_variant_base_low,X
    STA sprite_source_address_low
    LDA sprite_variant_base_high,X
    STA sprite_source_address_high
    JSR sync_sprite_source_operand
    RTS

.advance_sprite_source_pointer
    CLC
    LDA sprite_source_address_low
    ADC #sprite_variant_row_bytes
    STA sprite_source_address_low
    LDA sprite_source_address_high
    ADC #0
    STA sprite_source_address_high
    JSR sync_sprite_source_operand

.advance_sprite_source_pointer_done
    RTS

.sync_sprite_source_operand
    LDA sprite_source_address_low
    STA draw_packed_sprite_row_source+1
    STA copy_composite_sprite_row_source+1
    LDA sprite_source_address_high
    STA draw_packed_sprite_row_source+2
    STA copy_composite_sprite_row_source+2
    RTS

.draw_packed_sprite_row
    LDX #0
    LDY #0

.draw_packed_sprite_row_source
    LDA &FFFF,X
    STA (zp_ptr),Y
    INX
    TYA
    CLC
    ADC #8
    TAY
    CPX #sprite_variant_row_bytes
    BNE draw_packed_sprite_row_source
    RTS

.erase_sprite_row_bytes
    LDA #0
    LDY #0
    STA (zp_ptr),Y
    LDY #8
    STA (zp_ptr),Y
    LDY #16
    STA (zp_ptr),Y
    LDY #24
    STA (zp_ptr),Y
    RTS

.advance_sprite_destination_pointer
    INC current_scanline_in_band
    LDA current_scanline_in_band
    CMP #screen_scanlines_per_character_row
    BNE advance_sprite_row_within_band

    LDA #0
    STA current_scanline_in_band
    CLC
    LDA zp_ptr
    ADC #LO(screen_row_wrap_increment)
    STA zp_ptr
    LDA zp_ptr+1
    ADC #HI(screen_row_wrap_increment)
    STA zp_ptr+1
    RTS

.advance_sprite_row_within_band
    INC zp_ptr
    BNE advance_sprite_destination_pointer_done
    INC zp_ptr+1

.advance_sprite_destination_pointer_done
    RTS

.wait_for_vsync
    LDA #osbyte_wait_vsync
    JSR osbyte
    RTS

.sprite_frame0_right_shift_0
    EQUB &00, &F0, &00, &00
    EQUB &30, &0F, &C0, &00
    EQUB &61, &0F, &68, &00
    EQUB &C3, &00, &3C, &00
    EQUB &86, &66, &16, &00
    EQUB &86, &FF, &16, &00
    EQUB &86, &FF, &16, &00
    EQUB &86, &FF, &16, &00
    EQUB &86, &FF, &16, &00
    EQUB &86, &66, &16, &00
    EQUB &C3, &00, &3C, &00
    EQUB &61, &0F, &68, &00
    EQUB &30, &0F, &C0, &00
    EQUB &00, &F0, &00, &00

.sprite_frame0_right_shift_1
    EQUB &00, &70, &80, &00
    EQUB &10, &87, &68, &00
    EQUB &30, &0F, &3C, &00
    EQUB &61, &08, &16, &80
    EQUB &43, &33, &03, &80
    EQUB &43, &77, &8B, &80
    EQUB &43, &77, &8B, &80
    EQUB &43, &77, &8B, &80
    EQUB &43, &77, &8B, &80
    EQUB &43, &33, &03, &80
    EQUB &61, &08, &16, &80
    EQUB &30, &0F, &3C, &00
    EQUB &10, &87, &68, &00
    EQUB &00, &70, &80, &00

.sprite_frame0_right_shift_2
    EQUB &00, &30, &C0, &00
    EQUB &00, &C3, &3C, &00
    EQUB &10, &87, &1E, &80
    EQUB &30, &0C, &03, &C0
    EQUB &21, &19, &89, &48
    EQUB &21, &3B, &CD, &48
    EQUB &21, &3B, &CD, &48
    EQUB &21, &3B, &CD, &48
    EQUB &21, &3B, &CD, &48
    EQUB &21, &19, &89, &48
    EQUB &30, &0C, &03, &C0
    EQUB &10, &87, &1E, &80
    EQUB &00, &C3, &3C, &00
    EQUB &00, &30, &C0, &00

.sprite_frame0_right_shift_3
    EQUB &00, &10, &E0, &00
    EQUB &00, &61, &1E, &80
    EQUB &00, &C3, &0F, &C0
    EQUB &10, &86, &01, &68
    EQUB &10, &0C, &CC, &2C
    EQUB &10, &1D, &EE, &2C
    EQUB &10, &1D, &EE, &2C
    EQUB &10, &1D, &EE, &2C
    EQUB &10, &1D, &EE, &2C
    EQUB &10, &0C, &CC, &2C
    EQUB &10, &86, &01, &68
    EQUB &00, &C3, &0F, &C0
    EQUB &00, &61, &1E, &80
    EQUB &00, &10, &E0, &00

.sprite_frame1_right_shift_0
    EQUB &00, &F0, &00, &00
    EQUB &30, &0F, &C0, &00
    EQUB &61, &0F, &68, &00
    EQUB &C3, &00, &3C, &00
    EQUB &86, &66, &16, &00
    EQUB &86, &FF, &16, &00
    EQUB &86, &FF, &16, &00
    EQUB &86, &FF, &16, &00
    EQUB &86, &FF, &16, &00
    EQUB &86, &66, &16, &00
    EQUB &C3, &00, &3C, &00
    EQUB &61, &0F, &68, &00
    EQUB &30, &0F, &C0, &00
    EQUB &00, &F0, &00, &00

.sprite_frame1_right_shift_1
    EQUB &00, &70, &80, &00
    EQUB &10, &87, &68, &00
    EQUB &30, &0F, &3C, &00
    EQUB &61, &08, &16, &80
    EQUB &43, &33, &03, &80
    EQUB &43, &77, &8B, &80
    EQUB &43, &77, &8B, &80
    EQUB &43, &77, &8B, &80
    EQUB &43, &77, &8B, &80
    EQUB &43, &33, &03, &80
    EQUB &61, &08, &16, &80
    EQUB &30, &0F, &3C, &00
    EQUB &10, &87, &68, &00
    EQUB &00, &70, &80, &00

.sprite_frame1_right_shift_2
    EQUB &00, &30, &C0, &00
    EQUB &00, &C3, &3C, &00
    EQUB &10, &87, &1E, &80
    EQUB &30, &0C, &03, &C0
    EQUB &21, &19, &89, &48
    EQUB &21, &3B, &CD, &48
    EQUB &21, &3B, &CD, &48
    EQUB &21, &3B, &CD, &48
    EQUB &21, &3B, &CD, &48
    EQUB &21, &19, &89, &48
    EQUB &30, &0C, &03, &C0
    EQUB &10, &87, &1E, &80
    EQUB &00, &C3, &3C, &00
    EQUB &00, &30, &C0, &00

.sprite_frame1_right_shift_3
    EQUB &00, &10, &E0, &00
    EQUB &00, &61, &1E, &80
    EQUB &00, &C3, &0F, &C0
    EQUB &10, &86, &01, &68
    EQUB &10, &0C, &CC, &2C
    EQUB &10, &1D, &EE, &2C
    EQUB &10, &1D, &EE, &2C
    EQUB &10, &1D, &EE, &2C
    EQUB &10, &1D, &EE, &2C
    EQUB &10, &0C, &CC, &2C
    EQUB &10, &86, &01, &68
    EQUB &00, &C3, &0F, &C0
    EQUB &00, &61, &1E, &80
    EQUB &00, &10, &E0, &00

.sprite_frame0_left_shift_0
    EQUB &00, &F0, &00, &00
    EQUB &30, &0F, &C0, &00
    EQUB &61, &0F, &68, &00
    EQUB &C3, &00, &3C, &00
    EQUB &86, &66, &16, &00
    EQUB &86, &FF, &16, &00
    EQUB &86, &FF, &16, &00
    EQUB &86, &FF, &16, &00
    EQUB &86, &FF, &16, &00
    EQUB &86, &66, &16, &00
    EQUB &C3, &00, &3C, &00
    EQUB &61, &0F, &68, &00
    EQUB &30, &0F, &C0, &00
    EQUB &00, &F0, &00, &00

.sprite_frame0_left_shift_1
    EQUB &00, &70, &80, &00
    EQUB &10, &87, &68, &00
    EQUB &30, &0F, &3C, &00
    EQUB &61, &08, &16, &80
    EQUB &43, &33, &03, &80
    EQUB &43, &77, &8B, &80
    EQUB &43, &77, &8B, &80
    EQUB &43, &77, &8B, &80
    EQUB &43, &77, &8B, &80
    EQUB &43, &33, &03, &80
    EQUB &61, &08, &16, &80
    EQUB &30, &0F, &3C, &00
    EQUB &10, &87, &68, &00
    EQUB &00, &70, &80, &00

.sprite_frame0_left_shift_2
    EQUB &00, &30, &C0, &00
    EQUB &00, &C3, &3C, &00
    EQUB &10, &87, &1E, &80
    EQUB &30, &0C, &03, &C0
    EQUB &21, &19, &89, &48
    EQUB &21, &3B, &CD, &48
    EQUB &21, &3B, &CD, &48
    EQUB &21, &3B, &CD, &48
    EQUB &21, &3B, &CD, &48
    EQUB &21, &19, &89, &48
    EQUB &30, &0C, &03, &C0
    EQUB &10, &87, &1E, &80
    EQUB &00, &C3, &3C, &00
    EQUB &00, &30, &C0, &00

.sprite_frame0_left_shift_3
    EQUB &00, &10, &E0, &00
    EQUB &00, &61, &1E, &80
    EQUB &00, &C3, &0F, &C0
    EQUB &10, &86, &01, &68
    EQUB &10, &0C, &CC, &2C
    EQUB &10, &1D, &EE, &2C
    EQUB &10, &1D, &EE, &2C
    EQUB &10, &1D, &EE, &2C
    EQUB &10, &1D, &EE, &2C
    EQUB &10, &0C, &CC, &2C
    EQUB &10, &86, &01, &68
    EQUB &00, &C3, &0F, &C0
    EQUB &00, &61, &1E, &80
    EQUB &00, &10, &E0, &00

.sprite_frame1_left_shift_0
    EQUB &00, &F0, &00, &00
    EQUB &30, &0F, &C0, &00
    EQUB &61, &0F, &68, &00
    EQUB &C3, &00, &3C, &00
    EQUB &86, &66, &16, &00
    EQUB &86, &FF, &16, &00
    EQUB &86, &FF, &16, &00
    EQUB &86, &FF, &16, &00
    EQUB &86, &FF, &16, &00
    EQUB &86, &66, &16, &00
    EQUB &C3, &00, &3C, &00
    EQUB &61, &0F, &68, &00
    EQUB &30, &0F, &C0, &00
    EQUB &00, &F0, &00, &00

.sprite_frame1_left_shift_1
    EQUB &00, &70, &80, &00
    EQUB &10, &87, &68, &00
    EQUB &30, &0F, &3C, &00
    EQUB &61, &08, &16, &80
    EQUB &43, &33, &03, &80
    EQUB &43, &77, &8B, &80
    EQUB &43, &77, &8B, &80
    EQUB &43, &77, &8B, &80
    EQUB &43, &77, &8B, &80
    EQUB &43, &33, &03, &80
    EQUB &61, &08, &16, &80
    EQUB &30, &0F, &3C, &00
    EQUB &10, &87, &68, &00
    EQUB &00, &70, &80, &00

.sprite_frame1_left_shift_2
    EQUB &00, &30, &C0, &00
    EQUB &00, &C3, &3C, &00
    EQUB &10, &87, &1E, &80
    EQUB &30, &0C, &03, &C0
    EQUB &21, &19, &89, &48
    EQUB &21, &3B, &CD, &48
    EQUB &21, &3B, &CD, &48
    EQUB &21, &3B, &CD, &48
    EQUB &21, &3B, &CD, &48
    EQUB &21, &19, &89, &48
    EQUB &30, &0C, &03, &C0
    EQUB &10, &87, &1E, &80
    EQUB &00, &C3, &3C, &00
    EQUB &00, &30, &C0, &00

.sprite_frame1_left_shift_3
    EQUB &00, &10, &E0, &00
    EQUB &00, &61, &1E, &80
    EQUB &00, &C3, &0F, &C0
    EQUB &10, &86, &01, &68
    EQUB &10, &0C, &CC, &2C
    EQUB &10, &1D, &EE, &2C
    EQUB &10, &1D, &EE, &2C
    EQUB &10, &1D, &EE, &2C
    EQUB &10, &1D, &EE, &2C
    EQUB &10, &0C, &CC, &2C
    EQUB &10, &86, &01, &68
    EQUB &00, &C3, &0F, &C0
    EQUB &00, &61, &1E, &80
    EQUB &00, &10, &E0, &00

.sprite_variant_base_low
    EQUB LO(sprite_frame0_right_shift_0), LO(sprite_frame0_right_shift_1), LO(sprite_frame0_right_shift_2), LO(sprite_frame0_right_shift_3)
    EQUB LO(sprite_frame1_right_shift_0), LO(sprite_frame1_right_shift_1), LO(sprite_frame1_right_shift_2), LO(sprite_frame1_right_shift_3)
    EQUB LO(sprite_frame0_left_shift_0), LO(sprite_frame0_left_shift_1), LO(sprite_frame0_left_shift_2), LO(sprite_frame0_left_shift_3)
    EQUB LO(sprite_frame1_left_shift_0), LO(sprite_frame1_left_shift_1), LO(sprite_frame1_left_shift_2), LO(sprite_frame1_left_shift_3)

.sprite_variant_base_high
    EQUB HI(sprite_frame0_right_shift_0), HI(sprite_frame0_right_shift_1), HI(sprite_frame0_right_shift_2), HI(sprite_frame0_right_shift_3)
    EQUB HI(sprite_frame1_right_shift_0), HI(sprite_frame1_right_shift_1), HI(sprite_frame1_right_shift_2), HI(sprite_frame1_right_shift_3)
    EQUB HI(sprite_frame0_left_shift_0), HI(sprite_frame0_left_shift_1), HI(sprite_frame0_left_shift_2), HI(sprite_frame0_left_shift_3)
    EQUB HI(sprite_frame1_left_shift_0), HI(sprite_frame1_left_shift_1), HI(sprite_frame1_left_shift_2), HI(sprite_frame1_left_shift_3)

.mode_5_band_base_low
    EQUB &00, &40, &80, &C0, &00, &40, &80, &C0
    EQUB &00, &40, &80, &C0, &00, &40, &80, &C0
    EQUB &00, &40, &80, &C0, &00, &40, &80, &C0
    EQUB &00, &40, &80, &C0, &00, &40, &80, &C0

.mode_5_band_base_high
    EQUB &58, &59, &5A, &5B, &5D, &5E, &5F, &60
    EQUB &62, &63, &64, &65, &67, &68, &69, &6A
    EQUB &6C, &6D, &6E, &6F, &71, &72, &73, &74
    EQUB &76, &77, &78, &79, &7B, &7C, &7D, &7E

.sprite_x_pixels
    EQUB 0

.sprite_y_pixels
    EQUB 0

.sprite_x_subpixel
    EQUB 0

.sprite_y_subpixel
    EQUB 0

.previous_sprite_x_pixels
    EQUB 0

.previous_sprite_y_pixels
    EQUB 0

.blit_x_pixels
    EQUB 0

.blit_y_pixels
    EQUB 0

.sprite_row_x_offset_low
    EQUB 0

.sprite_row_x_offset_high
    EQUB 0

.sprite_pixel_shift
    EQUB 0

.sprite_source_address_low
    EQUB 0

.sprite_source_address_high
    EQUB 0

.composite_current_aligned_x
    EQUB 0

.composite_x_pixels
    EQUB 0

.composite_y_pixels
    EQUB 0

.composite_byte_count
    EQUB 0

.composite_current_byte_offset
    EQUB 0

.composite_rows_before_current
    EQUB 0

.composite_rows_remaining
    EQUB 0

.composite_current_rows_remaining
    EQUB 0

.composite_row_buffer_0
    EQUB 0

.composite_row_buffer_1
    EQUB 0

.composite_row_buffer_2
    EQUB 0

.composite_row_buffer_3
    EQUB 0

.composite_row_buffer_4
    EQUB 0

.current_sprite_row
    EQUB 0

.current_scanline_in_band
    EQUB 0

.sprite_frame_counter
    EQUB 0

.sprite_anim_frame
    EQUB 0

.sprite_anim_step_counter
    EQUB 0

.sprite_facing
    EQUB 0

.sprite_vertical_direction
    EQUB 0

.sprite_blit_mode
    EQUB 0

.key_w_down
    EQUB 0

.key_a_down
    EQUB 0

.key_s_down
    EQUB 0

.key_d_down
    EQUB 0

.end

SAVE "GAME", start, end, start
