.PHONY : all clean

TRACES := $(wildcard executions/*.trace)
TRACES_PDF := $(TRACES:.trace=.pdf)
MKDOT := scripts/mkdot
DOT := dot

all: $(TRACES_PDF)

clean:
	rm -rvf $(TRACES_PDF)

%.pdf: %.trace
	$(MKDOT) egg h11.time h7.time event < $< | $(DOT) -Tpdf -o $@

