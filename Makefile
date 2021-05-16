# Detect system OS.
ifeq ($(OS),Windows_NT)
	detected_OS := Windows
else
	detected_OS := $(shell sh -c 'uname -s 2>/dev/null || echo not')
endif

C_SRCS=$(shell find src -name *.c)
CXX_SRCS=$(shell find src -type f -name *.cc -o -name *.cpp -o -name *.cxx)

CXX_OBJS=$(CXX_SRCS:.cc=.o)
CXX_OBJS_1=$(CXX_OBJS:.cpp=.o)
CXX_OBJS_2=$(CXX_OBJS_1:.cxx=.o)

OBJS=$(C_SRCS:.c=.o)
OBJS+=$(CXX_OBJS_2)

# Use libstdc++ in CC
ifneq (,$(CXX_SRCS))
	LIBCXX=-lstdc++
endif

ifneq (,$(OBJCXX_SRCS))
	LIBCXX=-lstdc++
endif

# Modify the executable name by yourself.
ifeq (,$(LIBRARY))
	LIBRARY=libalgebra
endif

ifeq ($(detected_OS),Windows)
	DYNAMIC_LIB=$(LIBRARY).dll
else
ifeq ($(detected_OS),Darwin)
	DYNAMIC_LIB=$(LIBRARY).dylib
else
	DYNAMIC_LIB=$(LIBRARY).so
endif  # Darwin
endif  # Windows
STATIC_LIB=$(LIBRARY).a

# Set the C standard.
ifeq (,$(C_STD))
	C_STD=c11
endif

# Set the C++ standard.
ifeq (,$(CXX_STD))
	CXX_STD=c++17
endif

.PHONY: all dynamic static clean

all: dynamic

dynamic: dist/$(DYNAMIC_LIB)

dist/$(DYNAMIC_LIB): $(OBJS)
	$(CC) -shared -o dist/$(DYNAMIC_LIB) $(OBJS) $(LIBCXX)

static: dist/$(STATIC_LIB)

dist/$(STATIC_LIB): $(OBJS)
ifeq ($(detected_OS),Darwin)
	libtool -o dist/$(STATIC_LIB) $(OBJS)
else
	$(AR) rcs -o dist/$(STATIC_LIB) $(OBJS)
endif

%.o:%.c
ifeq (dynamic,$(MAKECMDGOALS))
	$(CC) -fPIC -std=$(C_STD) -c $< -o $@ $(CFLAGS) -I include
else
	$(CC) -std=$(C_STD) -c $< -o $@ $(CFLAGS) -I include
endif

%.o:%.cc
ifeq (dynamic,$(MAKECMDGOALS))
	$(CXX) -fPIC -std=$(CXX_STD) -c $< -o $@ $(CXXFLAGS) -I include
else
	$(CXX) -std=$(CXX_STD) -c $< -o $@ $(CXXFLAGS) -I include
endif

%.o:%.cpp
ifeq (dynamic,$(MAKECMDGOALS))
	$(CXX) -fPIC -std=$(CXX_STD) -c $< -o $@ $(CXXFLAGS) -I include
else
	$(CXX) -std=$(CXX_STD) -c $< -o $@ $(CXXFLAGS) -I include
endif

%.o:%.cxx
ifeq (dynamic,$(MAKECMDGOALS))
	$(CXX) -fPIC -std=$(CXX_STD) -c $< -o $@ $(CXXFLAGS) -I include
else
	$(CXX) -std=$(CXX_STD) -c $< -o $@ $(CXXFLAGS) -I include
endif

clean:
	$(RM) dist/$(DYNAMIC_LIB) dist/$(STATIC_LIB) $(OBJS)
