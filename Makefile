ifeq ($(DEBUG),1)
	CXXFLAGS += -std=c++14 -Wunused -Wall -Wextra -Wpedantic -I src/ -g
else
	CXXFLAGS += -std=c++14 -Wunused -Wall -Wextra -Wpedantic -I src/ -O3 -march=native -msse4 -mfpmath=sse -ffast-math -g
endif
ifeq ($(OS),Windows_NT)
	LDFLAGS += -lopengl32 -lglew32mx.dll -lglfw3 -lgdi32
	TMPPATH += .
else
	LDFLAGS  = -lglfw -lGLEW -lGL
	TMPPATH += /tmp
endif

infiniterrain: src/main.o src/Shader/Shader.o src/Program/Program.o
	$(CXX) $^ $(CXXFLAGS) $(LDFLAGS) -o $@

all: infiniterrain

apitrace: infiniterrain
	apitrace trace -o $(TMPPATH)/infiniterrain.trace ./infiniterrain
	qapitrace $(TMPPATH)/infiniterrain.trace

clean:
	find . -name '*.o' -type f -delete
	find . -name '*.trace' -type f -delete
	find . -name infiniterrain -type f -delete
	rm -f $(TMPPATH)/infiniterrain*.trace
