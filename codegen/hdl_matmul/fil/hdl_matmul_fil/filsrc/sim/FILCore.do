set SRCDIR /home/vipinsoni/MTP/hdl_coder_matlab/codegen/hdl_matmul/fil/home/vipinsoni/MTP/hdl_coder_matlab/codegen/hdl_matmul/fil/hdl_matmul_fil/filsrc
set SIMDIR /home/vipinsoni/MTP/hdl_coder_matlab/codegen/hdl_matmul/fil/home/vipinsoni/MTP/hdl_coder_matlab/codegen/hdl_matmul/fil/hdl_matmul_fil/filsrc/sim
set COMPILE vcom

set SIM vsim

vlib $SIMDIR/work
vmap work $SIMDIR/work

$COMPILE $SRCDIR/MWAJTAG.vhd
$COMPILE $SRCDIR/FILPKTBuilder.vhd
$COMPILE $SRCDIR/MWDPRAM.vhd
$COMPILE $SRCDIR/MWRXBuffer.vhd
$COMPILE $SRCDIR/MWDPRAM.vhd
$COMPILE $SRCDIR/MWTXBuffer.vhd
$COMPILE $SRCDIR/MWDPRAM.vhd
$COMPILE $SRCDIR/MWTXBuffer.vhd
$COMPILE $SRCDIR/MWArbiter.vhd
$COMPILE $SRCDIR/FILSYNCBuffer.vhd
$COMPILE $SRCDIR/MWChIfRXDecoder.vhd
$COMPILE $SRCDIR/MWRotateRight.vhd
$COMPILE $SRCDIR/MWMuxReg.vhd
$COMPILE $SRCDIR/MWChIfRXUnpack.vhd
$COMPILE $SRCDIR/MWChIfRX.vhd
$COMPILE $SRCDIR/MWChIfTX.vhd
$COMPILE $SRCDIR/MWChIfRXCtrl.vhd
$COMPILE $SRCDIR/MWChIfTXCtrl.vhd
$COMPILE $SRCDIR/MWChIfCtrl.vhd
$COMPILE $SRCDIR/MWChIf.vhd
$COMPILE $SRCDIR/FILCommLayer.vhd
$COMPILE $SRCDIR/FILCmdProc.vhd
$COMPILE $SRCDIR/hdl_matmul_wrapper.vhd
$COMPILE $SRCDIR/FILCore.vhd
