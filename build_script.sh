#!/bin/bash

# Build script for my-package
# Usage: ./build_package.sh [OPTIONS]
#
# Options:
#   --no-test       Skip tests during build
#   --test-only     Only run tests on existing package
#   --clean         Clean build artifacts before building
#   --help          Show this help message

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default options
RUN_TESTS=true
TEST_ONLY=false
CLEAN_BUILD=false
RECIPE_DIR="recipe"

REQUIRED_ENV="research-anaconda-ident"

# Test if the correct conda environment is active.
: ${CONDA_DEFAULT_ENV:?ERROR: No conda environment active}
[ "$CONDA_DEFAULT_ENV" = "${REQUIRED_ENV}" ] || { echo "ERROR: The ${REQUIRED_ENV} conda environment must be active."; exit 1; }

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show help
show_help() {
    echo "Build script for my-package"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --no-test       Skip tests during build"
    echo "  --test-only     Only run tests on existing package"
    echo "  --clean         Clean build artifacts before building"
    echo "  --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build with tests"
    echo "  $0 --no-test          # Build without tests"
    echo "  $0 --clean            # Clean and build with tests"
    echo "  $0 --test-only        # Run tests on existing package"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-test)
            RUN_TESTS=false
            shift
            ;;
        --test-only)
            TEST_ONLY=true
            shift
            ;;
        --clean)
            CLEAN_BUILD=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check if conda is available
if ! command -v conda &> /dev/null; then
    print_error "conda not found. Please install Anaconda or Miniconda."
    exit 1
fi

# Check if recipe directory exists
if [ ! -d "$RECIPE_DIR" ]; then
    print_error "Recipe directory '$RECIPE_DIR' not found."
    exit 1
fi

# Clean build artifacts if requested
if [ "$CLEAN_BUILD" = true ]; then
    print_info "Cleaning build artifacts..."
    conda build purge
    print_success "Build artifacts cleaned."
fi

# Test only mode
if [ "$TEST_ONLY" = true ]; then
    print_info "Running tests on existing package..."
    
    # Find the most recent built package
    CONDA_BLD_PATH=$(conda info --json | grep -o '"conda_build_root": "[^"]*' | sed 's/"conda_build_root": "//')
    echo "CONDA_BLD_PATH = [${CONDA_BLD_PATH}]"
    if [ -z "$CONDA_BLD_PATH" ]; then
        print_error "No conda build path defined. Please ensure this is set."
        exit 1
    fi
    PACKAGE_PATH=$(find "$CONDA_BLD_PATH" -name "my-package-*.tar.bz2" | sort -r | head -n 1)
    echo "PACKAGE_PATH = [${PACKAGE_PATH}]"
    
    if [ -z "$PACKAGE_PATH" ]; then
        print_error "No built package found. Please build the package first."
        exit 1
    fi
    
    print_info "Testing package: $PACKAGE_PATH"
    conda build --croot /opt/miniconda3/envs/research-anaconda-ident/conda-bld/ --test "$PACKAGE_PATH"
    print_success "Tests completed successfully!"
    exit 0
fi

# Build the package
print_info "Building conda package..."
print_info "Recipe directory: $RECIPE_DIR"
print_info "Run tests: $RUN_TESTS"

if [ "$RUN_TESTS" = true ]; then
    print_info "Building with tests..."
    conda build --croot /opt/miniconda3/envs/research-anaconda-ident/conda-bld/ "$RECIPE_DIR"
else
    print_info "Building without tests..."
    conda build --croot /opt/miniconda3/envs/research-anaconda-ident/conda-bld/ --no-test "$RECIPE_DIR"
fi

# Get the path to the built package
print_info "Looking for built package..."
CONDA_BLD_PATH=$(conda info --json | python -c "import sys, json; print(json.load(sys.stdin)['conda_build_root'])" 2>/dev/null)

if [ -z "$CONDA_BLD_PATH" ]; then
    print_warning "Could not determine conda build path from conda info."
    CONDA_BLD_PATH=$(conda build --output "$RECIPE_DIR" 2>/dev/null | head -n 1)
    if [ -z "$CONDA_BLD_PATH" ]; then
        print_error "Could not determine package location."
        print_info "Try running: conda build --output $RECIPE_DIR"
    fi
    PACKAGE_PATH="$CONDA_BLD_PATH"
else
    print_info "Conda build root: $CONDA_BLD_PATH"
    PACKAGE_PATH=$(find "$CONDA_BLD_PATH" -name "my-package-*.tar.bz2" 2>/dev/null | sort -r | head -n 1)
fi

# Alternative: try to get package path directly from conda build output
if [ -z "$PACKAGE_PATH" ] || [ ! -f "$PACKAGE_PATH" ]; then
    print_info "Trying alternative method to locate package..."
    PACKAGE_PATH=$(conda build --output "$RECIPE_DIR" 2>/dev/null | head -n 1)
fi

if [ -n "$PACKAGE_PATH" ] && [ -f "$PACKAGE_PATH" ]; then
    print_success "Package built successfully!"
    print_info "Package location: $PACKAGE_PATH"
    echo ""
    print_info "To install the package locally, run:"
    echo "  conda install --use-local my-package"
    echo ""
    print_info "To upload to Anaconda Cloud, run:"
    echo "  anaconda upload $PACKAGE_PATH"
    
    if [ "$RUN_TESTS" = false ]; then
        echo ""
        print_warning "Tests were skipped. To run tests, use:"
        echo "  $0 --test-only"
    fi
else
    print_error "Package build failed or package not found."
    print_info "Debug information:"
    echo "  Conda build root: $CONDA_BLD_PATH"
    echo "  Package path: $PACKAGE_PATH"
    echo ""
    print_info "Please check the conda build output above for errors."
    print_info "You can also try:"
    echo "  conda build --output $RECIPE_DIR"
    echo "  conda build $RECIPE_DIR"
    exit 1
fi
