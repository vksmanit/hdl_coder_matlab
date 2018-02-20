onbreak resume
onerror resume
vsim -novopt work.hdl_matmul_tb
add wave sim:/hdl_matmul_tb/u_hdl_matmul/clk
add wave sim:/hdl_matmul_tb/u_hdl_matmul/reset
add wave sim:/hdl_matmul_tb/u_hdl_matmul/clk_enable
add wave sim:/hdl_matmul_tb/u_hdl_matmul/a_in
add wave sim:/hdl_matmul_tb/u_hdl_matmul/b_in
add wave sim:/hdl_matmul_tb/u_hdl_matmul/ce_out
add wave sim:/hdl_matmul_tb/u_hdl_matmul/c_out
add wave sim:/hdl_matmul_tb/c_out_ref
add wave sim:/hdl_matmul_tb/u_hdl_matmul/state_store
add wave sim:/hdl_matmul_tb/state_store_ref
#run -all
