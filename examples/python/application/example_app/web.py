from flask import Flask

from example_lib import ultimate_answer


app = Flask(__name__)


@app.route("/")
def hello():
    return "Answer to the Ultimate Question of Life" \
            + ", the Universe, and Everything: %d" \
            % ultimate_answer()
