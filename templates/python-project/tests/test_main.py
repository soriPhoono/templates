from python_app.main import main


def test_main(capsys) -> None:
    main()
    assert capsys.readouterr().out == "Hello world\n"
