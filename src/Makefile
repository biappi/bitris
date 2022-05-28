FPC=fpc
FLAGS=-dBITRIS -Fcutf8

FILES= \
	bitris.pas  \
	cpu.pas     \
	date.pas    \
	hiscore.pas \
	muz.pas     \
	noises.pas  \
	title.pas   \
	yeaio.pas   \
	yeastd.pas

bitris: bitris.pas
	$(FPC) $(FLAGS) bitris.pas

clean:
	rm -f bitris *.ppu *.o
