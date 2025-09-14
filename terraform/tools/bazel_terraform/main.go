package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"log/slog"
	"os"
	"path/filepath"
)

type srcs []string

func (srcs *srcs) Set(value string) error {
	*srcs = append(*srcs, value)
	return nil
}

func (srcs *srcs) String() string {
	return fmt.Sprintf("%+v", *srcs)
}

var srcsFlag srcs

var outDirFlag string

func init() {
	flag.StringVar(&outDirFlag, "out_dir", "", "")
	flag.Var(&srcsFlag, "src", "")
}

func main() {
	flag.Parse()
	log.Printf("Hello World!")
	log.Printf("%+v", outDirFlag)
	log.Printf("%+v", srcsFlag)

	for _, src := range srcsFlag {
		CopyFile(src, filepath.Join(outDirFlag, filepath.Base(src)))
	}
}

// BufferSize represents the file copy buffer.
const BufferSize = 32

// CopyFile copies the src file to the destination.
func CopyFile(src string, dest string) error {
	slog.Info("copying", slog.String("from", src), slog.String("to", dest))
	sourceFileStat, err := os.Stat(src)
	if err != nil {
		return err
	}

	if !sourceFileStat.Mode().IsRegular() {
		return fmt.Errorf("%s is not a regular file", src)
	}

	source, err := os.Open(src)
	if err != nil {
		return err
	}
	defer source.Close()

	if err := os.MkdirAll(filepath.Dir(dest), 0750); err != nil {
		return err
	}

	if _, err := os.Stat(dest); err == nil {
		// file exists, ensure removal is possible then remove.
		if err := os.Chmod(dest, 0664); err != nil {
			return fmt.Errorf("could not delete file, could not make file writeable: %w", err)
		}
		if err := os.Remove(dest); err != nil {
			return fmt.Errorf("could not delete file: %w", err)
		}
	}

	destination, err := os.Create(dest)
	if err != nil {
		return fmt.Errorf("could not create '%s': %w", dest, err)
	}
	defer destination.Close()
	if err := destination.Chmod(sourceFileStat.Mode()); err != nil {
		return err
	}

	buf := make([]byte, BufferSize)
	for {
		n, err := source.Read(buf)
		if err != nil && err != io.EOF {
			return err
		}
		if n == 0 {
			break
		}

		if _, err := destination.Write(buf[:n]); err != nil {
			return err
		}
	}

	return nil
}
