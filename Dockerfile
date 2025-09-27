# Build stage
FROM python:3.12 as builder

RUN pip install --upgrade pip
RUN pip install uv

WORKDIR /app

COPY pyproject.toml .
COPY cc_simple_server/ ./cc_simple_server/

RUN python -m venv /opt/venv
RUN /opt/venv/bin/pip install --upgrade pip
RUN /opt/venv/bin/pip install fastapi uvicorn pydantic httpx pytest pytest-cov


# Final stage

FROM python:3.12-slim

COPY --from=builder /opt/venv /opt/venv
COPY . /app

RUN useradd -m -u 1000 appuser

RUN chown -R appuser:appuser /app

WORKDIR /app
USER appuser

ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONPATH=/app

EXPOSE 8000

CMD ["uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]
