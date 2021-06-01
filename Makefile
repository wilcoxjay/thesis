publish: thesis.pdf
	scp thesis.pdf jamesrwilcox.com:/var/www/jamesrwilcox.com/thesis.pdf

thesis.pdf: *.tex *.cls
	latexmk -pdf -interaction=nonstopmode thesis

clean:
	latexmk -C

.PHONY: clean publish

