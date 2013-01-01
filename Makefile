build:
	dmd drawler -L-lphobos2 -L-lcurl

run: build
	./drawler
