FROM python:3.7.0-alpine

ADD src/ /code

RUN pip install -U pip && \
    pip install -r /code/requirements.txt

WORKDIR /code

ENTRYPOINT ["flask"]
CMD ["run", "-h", "0.0.0.0"]
