CXX_GNU := g++
CXX_CLANG := clang++

# Why -o0? to make it crash faster and easier to debug. In a real project, you would want to use -O2 or -O3 for release builds.
CXXFLAGS := -std=c++20 -g -O0 -Wall -Wextra -pedantic -Iinclude
LDFLAGS  :=

SRC := src/main.cpp src/buffer.cpp
BIN := hook

.PHONY: all run clean asan run-asan valgrind doctor
# What do we need to change to not have the .o after building the exe?

all: $(BIN)

$(BIN): $(SRC)
	$(CXX_GNU) $(CXXFLAGS) $(SRC) -o $(BIN) $(LDFLAGS)

run: $(BIN)
	./$(BIN)

asan: $(SRC)
	$(CXX_CLANG) $(CXXFLAGS) -fsanitize=address,undefined -fno-omit-frame-pointer \
		$(SRC) -o $(BIN)_asan $(LDFLAGS)

run-asan: asan
	./$(BIN)_asan

valgrind: $(BIN)
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes ./$(BIN)

doctor:
	@echo "== Toolchain doctor =="
	@echo "--- g++"; g++ --version | head -n 1
	@echo "--- clang++"; clang++ --version | head -n 1
	@echo "--- make"; make --version | head -n 1
	@echo "--- valgrind"; valgrind --version | head -n 1
	@echo "--- gdb"; gdb --version | head -n 1
	@echo "--- git"; git --version
	@echo "--- gh (optional)"; (gh --version | head -n 1) || echo "gh not installed"

clean:
	rm -f $(BIN) $(BIN)_asan