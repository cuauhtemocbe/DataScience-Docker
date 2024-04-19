import pytest

@pytest.mark.asyncio
def test_print_hello():

    hello = "Hello, world!" 

    assert hello == "Hello, world!"