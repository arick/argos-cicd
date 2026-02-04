import yaml

# Read dependencies from environment.yml
# Fails if any dependencies use 
with open("environment.yml", "r", encoding="utf-8") as fh:
    env_data = yaml.safe_load(fh)
    requirements = [f'{dep}' for dep in env_data.get("dependencies", []) if isinstance(dep, str)]
    extras_require={
        "test": [
            "pytest>=7.0",
            "pytest-cov>=4.0",
            "anaconda-ident",
        ],
    },
# Display the resulting list
print("Requirements extracted from environment.yml:")
print(requirements)
print("Requirements extracted from extras_require:")
print(extras_require)