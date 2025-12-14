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
set_location_assignment PIN_G19  -to OPEN
set_location_assignment PIN_F19  -to ERROR

# HEX0七段数码管分配（a~g）
set_location_assignment PIN_G18 -to HEX0[0]
set_location_assignment PIN_F22 -to HEX0[1]
set_location_assignment PIN_E17 -to HEX0[2]
set_location_assignment PIN_L26 -to HEX0[3]
set_location_assignment PIN_L25 -to HEX0[4]
set_location_assignment PIN_J22 -to HEX0[5]
set_location_assignment PIN_H22 -to HEX0[6]
