#!/bin/bash

# Script to download Windows binary R packages for R-4.4.0

DEST_DIR="r_packages"
R_VERSION="4.4"
CRAN_WIN_URL="https://cran.r-project.org/bin/windows/contrib/${R_VERSION}"

# Array of required packages
declare -a PACKAGES=(
    "RJDBC"
    "sqldf"
    "AnomalyDetection"
    "ggplot2"
    "lubridate"
    "gridExtra"
    "tsoutliers"
    "changepoint"
)

echo "Downloading Windows binary R packages for R-${R_VERSION}..."
cd "$(dirname "$0")"

# Function to download Windows binary package
download_windows_package() {
    local package=$1
    echo "Downloading $package..."

    # Get the directory listing and find the package
    local listing=$(curl -s "$CRAN_WIN_URL/")
    local pkg_file=$(echo "$listing" | grep -o "${package}_[^\"]*\.zip" | head -1)

    if [ -n "$pkg_file" ]; then
        curl -L -o "$DEST_DIR/$pkg_file" "$CRAN_WIN_URL/$pkg_file"
        if [ $? -eq 0 ]; then
            echo "  ✓ Downloaded: $pkg_file"
            return 0
        else
            echo "  ✗ Failed to download: $pkg_file"
            return 1
        fi
    else
        echo "  ✗ Package not found in R-${R_VERSION}"
        # Try older versions
        for version in "4.3" "4.2" "4.1" "4.0"; do
            echo "  Trying R-${version}..."
            local alt_url="https://cran.r-project.org/bin/windows/contrib/${version}"
            local alt_listing=$(curl -s "$alt_url/")
            local alt_file=$(echo "$alt_listing" | grep -o "${package}_[^\"]*\.zip" | head -1)

            if [ -n "$alt_file" ]; then
                curl -L -o "$DEST_DIR/$alt_file" "$alt_url/$alt_file"
                if [ $? -eq 0 ]; then
                    echo "  ✓ Downloaded from R-${version}: $alt_file"
                    return 0
                fi
            fi
        done
        return 1
    fi
}

# Download each package
for package in "${PACKAGES[@]}"; do
    download_windows_package "$package"
    echo ""
done

echo "Download complete! Packages saved to $DEST_DIR/"
echo ""
echo "Downloaded files:"
ls -lh "$DEST_DIR/"
