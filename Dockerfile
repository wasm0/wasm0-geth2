# Support setting various labels on the final image
ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""

# Build Geth in a stock Go builder container
FROM golang:1.18 as builder

RUN apt update && apt install -y build-essential

WORKDIR /go-ethereum

# Get dependencies - will also be cached if we won't change go.mod/go.sum
COPY go.mod /go-ethereum/
COPY go.sum /go-ethereum/
RUN cd /go-ethereum && go mod download

ADD . /go-ethereum

# Copy link library to the bin folder
RUN mkdir -p /go-ethereum/build/bin/
RUN cp $(find $(go env GOPATH) -name libwasmi_c_api.so | grep -m1 "") /go-ethereum/build/bin/
RUN cp $(find $(go env GOPATH) -name libgas_injector.so | grep -m1 "") /go-ethereum/build/bin/

RUN cd /go-ethereum && go run build/ci.go install ./cmd/geth
RUN cp /go-ethereum/build/bin/geth /usr/local/bin/

EXPOSE 8545 8546 30303 30303/udp
ENTRYPOINT ["geth"]

# Add some metadata labels to help programatic image consumption
ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""

LABEL commit="$COMMIT" version="$VERSION" buildnum="$BUILDNUM"
