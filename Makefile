publish: thesis.pdf
	scp thesis.pdf jamesrwilcox.com:/var/www/jamesrwilcox.com/thesis.pdf

thesis.pdf: *.tex *.cls intro-figure.pdf
	latexmk -pdflua -interaction=nonstopmode thesis

intro-figure.pdf: intro-figure.tex
	latexmk -pdflua -interaction=nonstopmode intro-figure

clean:
	latexmk -C

.PHONY: clean publish

