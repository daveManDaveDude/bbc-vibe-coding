\ Shared BBC MOS entry points and constants.

osbyte = &FFF4
oswrch = &FFEE
osasci = &FFE3

zp_ptr = &70

osbyte_wait_vsync = 19
osbyte_inkey = 129

vdu_cls = 12
vdu_clg = 16
vdu_gcol = 18
vdu_palette = 19
vdu_restore_default_colours = 20
vdu_extended_command = 23
vdu_plot = 25
vdu_home = 30
vdu_tab = 31
vdu_set_mode = 22
mode_1 = 1
mode_4 = 4
mode_5 = 5
mode_7 = 7

ascii_cr = 13
ascii_dash = 45
ascii_zero = 48

\ Negative INKEY scan values from the BBC Micro User Guide table.
inkey_negative_high = &FF
inkey_w = &DE
inkey_a = &BE
inkey_s = &AE
inkey_d = &CD
