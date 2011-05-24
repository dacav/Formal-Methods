.PHONY : all build_trails clean

SPIN := spin601_linux64
PMLS := $(filter-out safe.pml sound.pml, $(wildcard *.pml))

export CFLAGS := -DBFS

all: build_trails

build_trails: safe.pml sound.pml
	for c in safe sound; do \
		for p in $(PMLS); do \
			$(SPIN) -a -N $${c}.pml $${p}; \
			CHECK=$$(basename $${p} .pml)_$${c}; \
			mkdir $${CHECK}; \
			mv pan.* $${CHECK}; \
			$(MAKE) -C $${CHECK} pan; \
			$${CHECK}/pan -x; \
		done; \
	done

safe.pml:
	$(SPIN) -f '<> !safe' > safe.pml

sound.pml:
	$(SPIN) -f '[] !sound' > sound.pml

clean:
	rm -rvf safe.pml sound.pml
	rm -rvf $(PMLS:.pml=_safe)
	rm -rvf $(PMLS:.pml=_sound)

