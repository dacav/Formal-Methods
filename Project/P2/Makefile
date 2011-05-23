.PHONY : all clean

VARIABLES := egg h11.time h7.time event

TRACES := $(wildcard executions/*.trace)
TRACES_PDF := $(TRACES:.trace=.pdf)
MKDOT := scripts/mkdot
DOT := dot

all: $(TRACES_PDF)

clean:
	rm -rvf $(TRACES_PDF)

%.pdf: %.trace
	$(MKDOT) $(VARIABLES) < $< | $(DOT) -Tpdf -o $@
