ARG BASE=python:3.12.15-alpine3.23@sha256:3d0ca66b723a0ff2a7a6e424cc2d01443e1b7c75ffcc110145f75d0f4daf6d63
FROM ${BASE} AS base

RUN apk upgrade --no-cache && apk add --no-cache bash ca-certificates curl libsodium-dev binutils \
    && update-ca-certificates
RUN python -m pip install --no-cache-dir \
    'pip @ https://files.pythonhosted.org/packages/3f/06/3e4420302363fbb71be3c7f35ce042f54bfca330e3e66b3a2e3c4cca579f/pip-26.2.2-py3-none-any.whl#sha256=fd7f4dfa8190e014013b9f08f3e973f4e4c26ffd179a204895533a7254813a70'

FROM base AS builder
RUN apk add --no-cache build-base libffi-dev cargo

COPY --from=ghcr.io/astral-sh/uv:0.9.5 /uv /uvx /bin/

WORKDIR /keria

COPY pyproject.toml uv.lock README.md ./
RUN uv sync --locked --no-dev --no-editable

COPY src/ src/
RUN uv sync --locked --no-dev

FROM base
WORKDIR /keria

COPY --from=builder /keria /keria
# Runtime installation is complete; omit installers and ensurepip's old bundle.
RUN python -m pip uninstall -y pip \
    && rm -rf /usr/local/lib/python3.12/ensurepip

ENV PATH="/keria/.venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

EXPOSE 3901
EXPOSE 3902
EXPOSE 3903
ENTRYPOINT ["keria"]
CMD ["start"]
