from setuptools import setup, find_packages

# Read long description from README
with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

requirements = ["numpy>=1.20", "pandas>=1.3"] # default
# if using pip ...
# Read requirements from requirements.txt
# with open("requirements.txt", "r", encoding="utf-8") as fh:
#     requirements = [line.strip() for line in fh if line.strip() and not line.startswith("#")]
# 
# if using conda ...
import yaml
with open("environment.yml", "r", encoding="utf-8") as fh:
    env_data = yaml.safe_load(fh)
    dependencies = [dep for dep in env_data.get("dependencies", []) if isinstance(dep, str)]
    
    # exclude_packages = {"python", "pip", "setuptools", "anaconda-client", "anaconda-ident", "conda-build", "yaml", "pyyaml"}
    exclude_packages = {}

    # Filter and convert conda dependencies to pip format
    for dep in dependencies:
        # Handle both "python=3.11" and "python 3.11" formats
        dep = dep.strip()
        
        # Extract package name (before any version specifier or space)
        pkg_name = dep.split("=")[0].split(">")[0].split("<")[0].split()[0].strip()
        
        # Skip excluded packages
        if pkg_name.lower() in exclude_packages:
            continue
        
        # Convert "package version" format to "package==version"
        if " " in dep and "=" not in dep and ">" not in dep and "<" not in dep:
            parts = dep.split(None, 1)  # Split on first whitespace
            if len(parts) == 2:
                dep = f"{parts[0]}=={parts[1]}"
        
        # Convert conda format (=) to pip format (==)
        if "=" in dep and not any(op in dep for op in [">=", "<=", "==", "!="]):
            dep = dep.replace("=", "==")
        
        requirements.append(dep)

setup(
    name="my-package",
    version="0.1.0",
    author="A. Rick Anderson",
    author_email="arick@pobox.com",
    description="Testing compatibility between anaconda-ident and conda-build",
    long_description="Researching ways to work-around the known compatibility issues when doing a Conda build where the Conda environment includes the anaconda-ident",
    long_description_content_type="text/markdown",
    url="https://github.com/username/my-package",
    project_urls={
        "Bug Tracker": "https://github.com/username/my-package/issues",
        "Documentation": "https://my-package.readthedocs.io",
        "Source Code": "https://github.com/username/my-package",
    },
    packages=find_packages(exclude=["tests", "tests.*"]),
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.11",
    install_requires=requirements,
    # extras_require={
    #     "test": [
    #         "pytest>=7.0",
    #         "pytest-cov>=4.0",
    #         "anaconda-ident",
    #     ],
    # },
    entry_points={
        "console_scripts": [
            "my-command=my_package.main:main",
        ],
    },
    include_package_data=True,
    zip_safe=False,
)
