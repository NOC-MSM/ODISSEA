#!/bin/bash

# Set the version for NEMO

NEMO_VER=4.2.2

#Clone the ODISSEA repository from GitHub

echo "Cloning the ODISSEA repository..."
git clone https://github.com/NOC-MSM/ODISSEA.git
cd ODISSEA/ 
WD=$PWD

#Clone the NEMO repository with specific settings

echo "Cloning the NEMO repository for version $NEMO_VER..."
git clone --filter=blob:none --no-checkout --depth 1 --sparse --branch $NEMO_VER https://forge.nemo-ocean.eu/nemo/nemo.git nemo
cd nemo
echo "Sparse-checkout: Adding required directories..."
git sparse-checkout add /makenemo /mk /src /cfgs/SHARED /cfgs/ref_cfgs.txt /ext
git checkout


#Copy necessary files from the ODISSEA directory to the NEMO directory

echo "Copying required files from ODISSEA directory to NEMO..."
cp -r $WD/arch $WD/nemo/

#Updating work_cfgs.txt with the new configruation"

echo 'NAARC_NPD OCE ICE' >> $WD/nemo/cfgs/work_cfgs.txt

#Define the configuration directory

CONFIG_DIR=$WD/nemo/cfgs/NAARC_NPD
mkdir -p $CONFIG_DIR
cd $CONFIG_DIR

#Move necessary files to the configuration directory
echo "Moving project files to configuration directory..."
cp -r  $WD/EXPREF .
cp -r $WD/MY_SRC .
cp $WD/cpp_*.fcm .

#Rename the EXPREF directory
cp -r EXPREF EXP_MYRUN

#Create a symbolic link for INPUT
ln -s $WD/INPUT_archer2 EXP_MYRUN/INPUT
ln -s $WD/INPUT_archer2/bfr_coef.nc EXP_MYRUN/bfr_coef.nc

#Copy the slurm run script to the configuration directory
cp $WD/scripts/run_script/run_nemo5504_48X.slurm EXP_MYRUN/

#Compile NEMO using the Archer2 settings
echo "Compiling NEMO in Archer2"
cd $WD/nemo/
cp $WD/scripts/compile_nemo/compile_nemo_Archer2 .
./compile_nemo_Archer2

echo "Model setup completed successfully."

cd $CONFIG_DIR/EXP_MYRUN/

echo "To run the NAARC Configuration:"
echo "sbatch run_nemo5504_48X.slurm"
