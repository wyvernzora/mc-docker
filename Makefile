.SILENT:
.PHONY: list clean %

list:
	build/list.sh

clean:
	rm -rf .cache

%:
	build/build.sh $@
