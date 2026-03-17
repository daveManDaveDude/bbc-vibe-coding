\ Small helper macros shared by the project.

MACRO VDU byte_value
    LDA #byte_value
    JSR oswrch
ENDMACRO
