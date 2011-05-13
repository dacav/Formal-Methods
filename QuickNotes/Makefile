.PHONY : all clean index dir

SUBTEXS := $(shell find . -mindepth 2 -name '*.tex')
PDF := quick.pdf toughts.pdf
OUTDIR := ./out
OPTS := -halt-on-error -interaction nonstopmode -output-directory $(OUTDIR)
PDFLATEX := pdflatex

all: $(PDF) dir

%.pdf : %.tex $(SUBTEXS)
	$(PDFLATEX) $(OPTS) $<

clean:
	rm -r $(OUTDIR)

dir:
	mkdir -p $(OUTDIR)
