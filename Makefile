.PHONY: build run stop shell send test clean export

IMAGE ?= yak-headless
PORT  ?= 8087

build:
	docker build -t $(IMAGE) .

export:
	docker save $(IMAGE) -o $(IMAGE).tar
	@ls -lh $(IMAGE).tar

run:
	docker compose up -d

stop:
	docker compose down

shell:
	docker run --rm -it --entrypoint sh $(IMAGE)

logs:
	docker compose logs -f

send:
	docker run --rm $(IMAGE) -c 'rsp = http.Get("https://httpbin.org/get")~; http.show(rsp)'

test:
	docker run --rm $(IMAGE) version

clean:
	docker compose down -v
	rm -rf yak-data/
