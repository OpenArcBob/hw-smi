#!/usr/bin/env bash

mkdir -p bin # create directory for executable
rm -f bin/hw-smi # prevent execution of old version if compiling fails
echo_and_execute() { echo "$@"; "$@"; }

NVIDIA_LIB="/usr/lib/x86_64-linux-gnu/libnvidia-ml.so"
AMD_LIB="/opt/rocm/lib/libamd_smi.so"
INTEL_LIB="/usr/lib/x86_64-linux-gnu/libze_intel_gpu.so.1"

if [[ -f $NVIDIA_LIB ]]; then
	NVIDIA=1
	echo -e "\033[92mInfo\033[0m: \033[32mNvidia\033[0m GPU driver found! --> \033[32m$NVIDIA_LIB\033[0m"
else
	echo -e "\033[33mWarning\033[0m: No \033[32mNvidia\033[0m GPU driver found! ??? \033[32m$NVIDIA_LIB\033[0m ???"
fi

if [[ -f $AMD_LIB ]]; then
	AMD=1
	echo -e "\033[92mInfo\033[0m: \033[31mAMD\033[0m GPU driver found! --> \033[31m$AMD_LIB\033[0m"
else
	echo -e "\033[33mWarning\033[0m: No \033[31mAMD\033[0m GPU driver found! ??? \033[31m$AMD_LIB\033[0m ???"
fi

if [[ -f $INTEL_LIB ]]; then
	INTEL=1
	echo -e "\033[92mInfo\033[0m: \033[94mIntel\033[0m GPU driver found! --> \033[94m$INTEL_LIB\033[0m"
else
	echo -e "\033[33mWarning\033[0m: No \033[94mIntel\033[0m GPU driver found! ??? \033[94m$INTEL_LIB\033[0m ???"
fi

if [[ $NVIDIA && $AMD && $INTEL ]]; then # Nvidia+AMD+Intel GPUs
	echo -e "\033[92mInfo\033[0m: Compiling for \033[32mNvidia\033[0m+\033[31mAMD\033[0m+\033[94mIntel\033[0m GPUs:"
	echo_and_execute g++ src/main.cpp -o bin/hw-smi -std=c++17 -O3 -D NVIDIA_GPU -D AMD_GPU -D INTEL_GPU -L./src/NVML/lib -L./src/AMDSMI/lib -L./src/SYSMAN/lib -lnvidia-ml -lamd_smi -lze_intel_gpu
elif [[ $NVIDIA && $AMD ]]; then # Nvidia+AMD GPUs
	echo -e "\033[92mInfo\033[0m: Compiling for \033[32mNvidia\033[0m+\033[31mAMD\033[0m GPUs:"
	echo_and_execute g++ src/main.cpp -o bin/hw-smi -std=c++17 -O3 -D NVIDIA_GPU -D AMD_GPU -L./src/NVML/lib -L./src/AMDSMI/lib -lnvidia-ml -lamd_smi
elif [[ $NVIDIA && $INTEL ]]; then # Nvidia+Intel GPUs
	echo -e "\033[92mInfo\033[0m: Compiling for \033[32mNvidia\033[0m+\033[94mIntel\033[0m GPUs:"
	echo_and_execute g++ src/main.cpp -o bin/hw-smi -std=c++17 -O3 -D NVIDIA_GPU -D INTEL_GPU -L./src/NVML/lib -L./src/SYSMAN/lib -lnvidia-ml -lze_intel_gpu
elif [[ $AMD && $INTEL ]]; then # AMD+Intel GPUs
	echo -e "\033[92mInfo\033[0m: Compiling for \033[31mAMD\033[0m+\033[94mIntel\033[0m GPUs:"
	echo_and_execute g++ src/main.cpp -o bin/hw-smi -std=c++17 -O3 -D AMD_GPU -D INTEL_GPU -L./src/AMDSMI/lib -L./src/SYSMAN/lib -lamd_smi -lze_intel_gpu
elif [[ $NVIDIA ]]; then # Nvidia GPUs
	echo -e "\033[92mInfo\033[0m: Compiling for \033[32mNvidia\033[0m GPUs:"
	echo_and_execute g++ src/main.cpp -o bin/hw-smi -std=c++17 -O3 -D NVIDIA_GPU -L./src/NVML/lib -lnvidia-ml
elif [[ $AMD ]]; then # AMD GPUs
	echo -e "\033[92mInfo\033[0m: Compiling for \033[31mAMD\033[0m GPUs:"
	echo_and_execute g++ src/main.cpp -o bin/hw-smi -std=c++17 -O3 -D AMD_GPU -L./src/AMDSMI/lib -lamd_smi
elif [[ $INTEL ]]; then # Intel GPUs
	echo -e "\033[92mInfo\033[0m: Compiling for \033[94mIntel\033[0m GPUs:"
	echo_and_execute g++ src/main.cpp -o bin/hw-smi -std=c++17 -O3 -D INTEL_GPU -L./src/SYSMAN/lib -lze_intel_gpu
else # no GPUs
	echo -e "\033[92mInfo\033[0m: Compiling without GPUs:"
	echo_and_execute g++ src/main.cpp -o bin/hw-smi -std=c++17 -O3
fi

if [[ $? == 0 ]]; then
	if [[ $INTEL ]]; then # Intel SYSMAN API requires sudo permissions for some GPU counters
		echo -e "\033[92mInfo\033[0m: Compiling was successful! Run hw-smi with:\nsudo bin/hw-smi\nsudo bin/hw-smi --graphs\nsudo bin/hw-smi --bars\nsudo bin/hw-smi --help"
	else
		echo -e "\033[92mInfo\033[0m: Compiling was successful! Run hw-smi with:\nbin/hw-smi\nbin/hw-smi --graphs\nbin/hw-smi --bars\nbin/hw-smi --help"
	fi
else
	echo -e "\033[91mError\033[0m: Compiling failed."
fi