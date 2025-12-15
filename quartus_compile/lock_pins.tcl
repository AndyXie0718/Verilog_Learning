# DE2-115常用引脚分配（可在Quartus中Tcl Console执行）
set_location_assignment PIN_Y2   -to CLK
set_location_assignment PIN_M23  -to RESET
set_location_assignment PIN_M21  -to ENTER
set_location_assignment PIN_N21  -to PRESS
set_location_assignment PIN_AB28 -to MODE
set_location_assignment PIN_AB27 -to CODE[3]
set_location_assignment PIN_AD27 -to CODE[2]
set_location_assignment PIN_AC27 -to CODE[1]
set_location_assignment PIN_AC28 -to CODE[0]
set_location_assignment PIN_E21  -to OPEN
set_location_assignment PIN_G19  -to ERROR

# HEX0七段数码管分配（a~g）
set_location_assignment PIN_G18 -to HEX0[0]
set_location_assignment PIN_F22 -to HEX0[1]
set_location_assignment PIN_E17 -to HEX0[2]
set_location_assignment PIN_L26 -to HEX0[3]
set_location_assignment PIN_L25 -to HEX0[4]
set_location_assignment PIN_J22 -to HEX0[5]
set_location_assignment PIN_H22 -to HEX0[6]
# HEX1七段数码管分配（a~g）
set_location_assignment PIN_M24 -to HEX1[0]
set_location_assignment PIN_Y22 -to HEX1[1]
set_location_assignment PIN_W21 -to HEX1[2]
set_location_assignment PIN_W22 -to HEX1[3]
set_location_assignment PIN_W25 -to HEX1[4]
set_location_assignment PIN_U23 -to HEX1[5]
set_location_assignment PIN_U24 -to HEX1[6]
# HEX2七段数码管分配（a~g）
set_location_assignment PIN_AA25 -to HEX2[0]
set_location_assignment PIN_AA26 -to HEX2[1]
set_location_assignment PIN_Y25 -to HEX2[2]
set_location_assignment PIN_W26 -to HEX2[3]
set_location_assignment PIN_Y26 -to HEX2[4]
set_location_assignment PIN_W27 -to HEX2[5]
set_location_assignment PIN_W28 -to HEX2[6]
# HEX3七段数码管分配（a~g）
set_location_assignment PIN_V21 -to HEX3[0]
set_location_assignment PIN_U21 -to HEX3[1]
set_location_assignment PIN_AB20 -to HEX3[2]
set_location_assignment PIN_AA21 -to HEX3[3]
set_location_assignment PIN_AD24 -to HEX3[4]
set_location_assignment PIN_AF23 -to HEX3[5]
set_location_assignment PIN_Y19 -to HEX3[6]
# HEX4七段数码管分配（a~g）
set_location_assignment PIN_AB19 -to HEX4[0]
set_location_assignment PIN_AA19 -to HEX4[1]
set_location_assignment PIN_AG21 -to HEX4[2]
set_location_assignment PIN_AH21 -to HEX4[3]
set_location_assignment PIN_AE19 -to HEX4[4]
set_location_assignment PIN_AF19 -to HEX4[5]
set_location_assignment PIN_AE18 -to HEX4[6]
