MATLAB="/opt/matlab"
Arch=glnxa64
ENTRYPOINT=mexFunction
MAPFILE=$ENTRYPOINT'.map'
PREFDIR="/home/vipinsoni/.matlab/R2014b"
OPTSFILE_NAME="./setEnv.sh"
. $OPTSFILE_NAME
COMPILER=$CC
. $OPTSFILE_NAME
echo "# Make settings for hdl_matmul_cosim" > hdl_matmul_cosim_mex.mki
echo "CC=$CC" >> hdl_matmul_cosim_mex.mki
echo "CFLAGS=$CFLAGS" >> hdl_matmul_cosim_mex.mki
echo "CLIBS=$CLIBS" >> hdl_matmul_cosim_mex.mki
echo "COPTIMFLAGS=$COPTIMFLAGS" >> hdl_matmul_cosim_mex.mki
echo "CDEBUGFLAGS=$CDEBUGFLAGS" >> hdl_matmul_cosim_mex.mki
echo "CXX=$CXX" >> hdl_matmul_cosim_mex.mki
echo "CXXFLAGS=$CXXFLAGS" >> hdl_matmul_cosim_mex.mki
echo "CXXLIBS=$CXXLIBS" >> hdl_matmul_cosim_mex.mki
echo "CXXOPTIMFLAGS=$CXXOPTIMFLAGS" >> hdl_matmul_cosim_mex.mki
echo "CXXDEBUGFLAGS=$CXXDEBUGFLAGS" >> hdl_matmul_cosim_mex.mki
echo "LD=$LD" >> hdl_matmul_cosim_mex.mki
echo "LDFLAGS=$LDFLAGS" >> hdl_matmul_cosim_mex.mki
echo "LDOPTIMFLAGS=$LDOPTIMFLAGS" >> hdl_matmul_cosim_mex.mki
echo "LDDEBUGFLAGS=$LDDEBUGFLAGS" >> hdl_matmul_cosim_mex.mki
echo "Arch=$Arch" >> hdl_matmul_cosim_mex.mki
echo OMPFLAGS= >> hdl_matmul_cosim_mex.mki
echo OMPLINKFLAGS= >> hdl_matmul_cosim_mex.mki
echo "EMC_COMPILER=gcc" >> hdl_matmul_cosim_mex.mki
echo "EMC_CONFIG=optim" >> hdl_matmul_cosim_mex.mki
"/opt/matlab/bin/glnxa64/gmake" -B -f hdl_matmul_cosim_mex.mk
