PROC=SGML_CATALOG_FILES="catalog.xml" xsltproc
STYLEDIR=./xsl
TABSTYLE=$(STYLEDIR)/bibletime.xsl
STYLESHEET=$(TABSTYLE)
# Change the path in output-root to put your HTML output elsewhere
STYLEOPT= --stringparam output-root .

.PHONY : clean

all:
	make website

include ../en/depends.tabular

autolayout.xml: layout.xml
	$(PROC) --output $@ $(STYLEDIR)/autolayout.xsl $<
	make depends

%.html: autolayout.xml
	$(PROC) --output $@  $(STYLEOPT)  $(STYLESHEET)  $(filter-out autolayout.xml,$^)
	../fixhtml.pl $@

%.shtml: autolayout.xml
	$(PROC) --output $@  $(STYLEOPT)  $(STYLESHEET)  $(filter-out autolayout.xml,$^)
	../fixhtml.pl $@

depends: autolayout.xml
	$(PROC) --output depends.tabular $(STYLEOPT) $(STYLEDIR)/makefile-dep.xsl $<

