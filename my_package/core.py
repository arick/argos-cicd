"""
Core functionality for my_package
"""


def hello_world():
    """
    Print a simple Hello World message.
    
    Returns:
        str: A greeting message
    """
    message = "Hello, World! Welcome to my-package!"
    print(message)
    return message


def greet(name):
    """
    Generate a personalized greeting.
    
    Args:
        name (str): The name of the person to greet
        
    Returns:
        str: A personalized greeting message
    """
    message = f"Howdy, {name}! Thanks for using my-package!"
    return message
