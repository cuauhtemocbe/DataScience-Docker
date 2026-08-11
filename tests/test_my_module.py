from my_module import add


def test_add() -> None:
    assert add(2, 3) == 5


def test_add_negative() -> None:
    assert add(-1, 1) == 0
