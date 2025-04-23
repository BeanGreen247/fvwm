#!/bin/bash

# Choose hardware type: "intel", "amd", or "nvidia"
HARDWARE_TYPE="nvidia"  # Change this as needed

# Function to install required dependencies
#install_dependencies() {
#    echo "Installing necessary dependencies for $HARDWARE_TYPE..."
#
#    case "$HARDWARE_TYPE" in
#        intel|amd)
#            sudo apt update
#            sudo apt install -y cpufrequtils
#            ;;
#        nvidia)
#            sudo apt update
#            sudo apt install -y nvidia-utils-535 || sudo apt install -y nvidia-utils
#            ;;
#        amd)
#            sudo apt update
#            sudo apt install -y amdgpu-pro || echo "Ensure AMDGPU-Pro drivers are installed."
#            ;;
#        *)
#            echo "Invalid hardware type! Skipping dependency installation."
#            exit 1
#            ;;
#    esac
#}

# setting cpu into performance mode with custom clock speed limits
set_cpu_performance() {
    echo "Setting CPU governor to performance..."

    # Set governor to performance for all CPUs
    for gov_file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo performance | sudo tee "$gov_file" > /dev/null
    done

    # Custom CPU frequency limits in Hz
    MAX_FREQ="5700000"  # 5.7 GHz
    MIN_FREQ="4700000"  # 4.7 GHz

    echo "Setting CPU min frequency to $MIN_FREQ Hz..."
    echo "Setting CPU max frequency to $MAX_FREQ Hz..."

    # Set frequency limits
    for max_file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
        echo "$MAX_FREQ" | sudo tee "$max_file" > /dev/null
    done

    for min_file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq; do
        echo "$MIN_FREQ" | sudo tee "$min_file" > /dev/null
    done

    # If cpufreq-set is available, use it to enforce limits as well
    if command -v cpufreq-set &> /dev/null; then
        echo "Applying cpufreq-set to all CPU cores..."
        for cpu_path in /sys/devices/system/cpu/cpu[0-9]*; do
            core=$(basename "$cpu_path" | sed 's/cpu//')
            sudo cpufreq-set -c "$core" -g performance
            sudo cpufreq-set -c "$core" -u $(($MAX_FREQ / 1000))MHz
            sudo cpufreq-set -c "$core" -d $(($MIN_FREQ / 1000))MHz
        done
    fi

    # Intel P-State tuning if applicable
    if [ -f /sys/devices/system/cpu/intel_pstate/min_perf_pct ]; then
        echo "Enforcing Intel P-State performance mode..."
        echo 100 | sudo tee /sys/devices/system/cpu/intel_pstate/min_perf_pct > /dev/null
    fi
}

# Set NVIDIA GPU to performance mode
set_nvidia_performance() {
    if command -v nvidia-smi &> /dev/null; then
        echo "Setting NVIDIA GPU to performance mode..."
        sudo nvidia-smi -pm 1
        #sudo nvidia-smi -lgc 0,2100  # Adjust this based on your GPU model
    else
        echo "NVIDIA GPU not detected!"
    fi
}

# Set AMD GPU to performance mode
set_amd_performance() {
    if [ -d /sys/class/drm/card0/device/power_dpm_force_performance_level ]; then
        echo "Setting AMD GPU to performance mode..."
        echo "performance" | sudo tee /sys/class/drm/card0/device/power_dpm_force_performance_level > /dev/null
    else
        echo "AMD GPU not detected!"
    fi
}

# Install dependencies first
#install_dependencies

# Apply settings based on hardware type
case "$HARDWARE_TYPE" in
    intel)
        echo "Configuring for Intel CPU..."
        set_cpu_performance
        ;;
    amd)
        echo "Configuring for AMD CPU and GPU..."
        set_cpu_performance
        set_amd_performance
        ;;
    nvidia)
        echo "Configuring for NVIDIA GPU..."
        set_nvidia_performance
        set_cpu_performance
        ;;
    *)
        echo "Invalid hardware type! Use 'intel', 'amd', or 'nvidia'."
        exit 1
        ;;
esac

echo "Performance mode enabled for $HARDWARE_TYPE."
