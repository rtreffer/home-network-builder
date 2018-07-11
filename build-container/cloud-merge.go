package main

import (
	"bufio"
	"bytes"
	"compress/gzip"
	"fmt"
	"io/ioutil"
	"mime/multipart"
	"net/textproto"
	"os"
	"strings"
	"text/template"
)

func main() {
	if len(os.Args) < 3 {
		fmt.Printf("%v\n\nUsage: %v output-file source-file...\n", os.Args, os.Args[0])
		os.Exit(1)
	}
	output := os.Args[1]

	outfile, err := os.Create(output)
	if err != nil {
		panic(err)
	}
	defer outfile.Close()

	outputWriter := bufio.NewWriter(outfile)

	gzipWriter, err := gzip.NewWriterLevel(outputWriter, gzip.BestCompression)
	if err != nil {
		panic(err)
	}
	defer gzipWriter.Close()

	multipartWriter := multipart.NewWriter(gzipWriter)
	defer multipartWriter.Close()

	// write mime multipart header
	fileHeader := fmt.Sprintf("Content-Type: multipart/mixed; boundary=\"%v\"\nMIME-Version: 1.0\n\n", multipartWriter.Boundary())
	if _, err = gzipWriter.Write([]byte(fileHeader)); err != nil {
		panic(fmt.Errorf("Tried to write fileheader for multpart, got: %v", err))
	}

	for _, file := range os.Args[2:] {
		data, err := ioutil.ReadFile(file)
		if err != nil {
			panic(err)
		}

		filetype, filename, data, err := expand(file, data)
		if err != nil {
			panic(err)
		}

		if filetype == "unknown" {
			fmt.Printf("Unknown filetype for %v: %v\n", file, filetype)
			continue
		}

		fmt.Printf("Adding %v as %v to %v\n", file, filename, output)

		headers := make(textproto.MIMEHeader)
		headers.Add("MIME-Version", "1.0")
		headers.Add("Merge-Type", "list(append)+dict(recurse_array)+str()")
		headers.Add("Content-Type", filetype+"; charset=\"utf-8\"")
		headers.Add("Content-Diposition", "attachment; filename=\""+filename+"\"")
		headers.Add("Content-Transfer-Encoding", "7bit")

		partWriter, err := multipartWriter.CreatePart(headers)
		if written, err := partWriter.Write(data); err != nil {
			panic(fmt.Errorf("Wanted to write %v bytes of %v but wrote only %v bytes: %v", len(data), file, written, err))
		}
	}

	multipartWriter.Close()
	gzipWriter.Close()
	outputWriter.Flush()
}

func expand(name string, data []byte) (string, string, []byte, error) {
	pathParts := strings.Split(name, "/")
	basename := pathParts[len(pathParts)-1]
	parts := strings.Split(name, ".")
	extension := parts[len(parts)-1]
	preExtension := ""
	if len(parts) > 1 {
		preExtension = parts[len(parts)-2]
	}
	// file ends in tpl
	if extension == "tpl" {
		if substituted, err := expandTemplate(basename, data); err == nil {
			return expand(strings.Join(parts[0:len(parts)-1], "."), []byte(substituted))
		} else {
			return "tpl", basename, data, err
		}
	}
	if preExtension == "tpl" {
		if substituted, err := expandTemplate(basename, data); err == nil {
			return expand(strings.Join(parts[0:len(parts)-2], ".")+"."+extension, []byte(substituted))
		} else {
			return "tpl", basename, data, err
		}
	}

	// file is a shell script (.sh / .bash)
	if extension == "sh" || extension == "bash" {
		return "text/x-shellscript", basename, data, nil
	}
	// file is a cloud-init part (.yaml / .yml / .json)
	if extension == "yml" || extension == "yaml" || extension == "json" {
		return "text/cloud-config", basename, data, nil
	}
	// unknown data
	return "unknown", basename, data, nil
}

func expandTemplate(name string, data []byte) (string, error) {
	// read the env
	env := make(map[string]string)
	for _, envKeyValue := range os.Environ() {
		parts := strings.SplitN(envKeyValue, "=", 2)
		env[parts[0]] = parts[1]
	}

	// load template
	tmpl, err := template.New(name).Parse(string(data))
	if err != nil {
		return "", err
	}

	// execute template
	buf := new(bytes.Buffer)
	if err := tmpl.Execute(buf, env); err != nil {
		return "", err
	}
	return buf.String(), nil
}
