from waitress.runner import run


def main(): run(["--call", "example_app.web:app"])


if __name__ == '__main__':
    main()
