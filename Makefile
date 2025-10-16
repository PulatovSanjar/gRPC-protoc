# ----------------------------
# Makefile for protobuf / gRPC
# ----------------------------

# Директории
PROTO_DIR      ?= proto
GO_OUT_DIR     ?= gen/go

# Автопоиск всех .proto
PROTOS := $(shell find $(PROTO_DIR) -type f -name '*.proto')

# Флаги генерации (оставлены как в твоём taskfile)
GO_FLAGS       := --go_out=$(GO_OUT_DIR) --go_opt=paths=source_relative
GRPC_FLAGS     := --go-grpc_out=$(GO_OUT_DIR) --go-grpc_opt=paths=source_relative

# -------- Targets --------
.PHONY: help check-tools generate clean tidy

help:
	@echo "Использование:"
	@echo "  make generate   # сгенерировать Go-код из всех .proto"
	@echo "  make check-tools# проверить наличие protoc и плагинов"
	@echo "  make tidy       # go mod tidy"
	@echo "  make clean      # удалить сгенерированные файлы"
	@echo ""
	@echo "Параметры (можно переопределить):"
	@echo "  PROTO_DIR=$(PROTO_DIR)"
	@echo "  GO_OUT_DIR=$(GO_OUT_DIR)"

check-tools:
	@command -v protoc >/dev/null 2>&1 || (echo "❌ protoc не найден. Установи: brew install protobuf"; exit 1)
	@command -v protoc-gen-go >/dev/null 2>&1 || (echo "❌ protoc-gen-go не найден. Установи: go install google.golang.org/protobuf/cmd/protoc-gen-go@latest"; exit 1)
	@command -v protoc-gen-go-grpc >/dev/null 2>&1 || (echo "❌ protoc-gen-go-grpc не найден. Установи: go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest"; exit 1)
	@echo "✅ Все инструменты найдены."

generate: check-tools
	@mkdir -p $(GO_OUT_DIR)
	@echo "▶️  Генерация из протосов:"
	@echo "    $(PROTOS)"
	@protoc -I $(PROTO_DIR) $(PROTOS) $(GO_FLAGS) $(GRPC_FLAGS)
	@echo "✅ Готово: $(GO_OUT_DIR)"

tidy:
	@go mod tidy
	@echo "✅ go.mod/go.sum приведены в порядок."

clean:
	@rm -rf $(GO_OUT_DIR)
	@echo "🧹 Очистка: удалён $(GO_OUT_DIR)"
