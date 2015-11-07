###############################################################################
# Makefile to generate the documentacion.
# Angel Terrones <angelterrones@gmail.com>
#
# 2015/05/05: File created
###############################################################################
SHELL = bash

.SOURCES      = src
.TEXI         = antares.texi
.TEXI2PDF_ARG = --tidy

default:
	@texi2pdf $(.SOURCES)/$(.TEXI) $(.TEXI2PDF_ARG)

clean:
	rm -rf *.t2d

distclean:
	rm -rf *.t2d *.pdf
