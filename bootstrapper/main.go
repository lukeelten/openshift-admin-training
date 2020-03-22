package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"sync"
	"time"
)

const BASE = "/architecture/"

func GetStderr(cmd *exec.Cmd) string {
	if stdErr, ok := cmd.Stderr.(*strings.Builder); ok {
		return stdErr.String()
	}

	return ""
}

func main() {
	arch := flag.String("arch", "", "Architecture to deploy")
	count := flag.Int("count", 0, "Number of training participants")
	minimal := flag.Bool("minimal", false, "Creates only trainer instances")
	del := flag.Bool("delete", false, "Flag to delete architecture")
	flag.Parse()

	if arch == nil {
		log.Fatal("invalid architecture given")
		return
	}

	if del != nil && *del {
		DeleteArchitectures(*arch)
		return
	}

	if minimal != nil && *minimal {
		CreateArchitecture(*arch, 0)
		return
	}

	if count != nil {
		CreateArchitecture(*arch, *count)
		return
	}

	log.Fatal("invalid count given")
}

func CreateArchitecture(arch string, count int) {
	log.Printf("Creating %d of architecture %s", count, arch)
	pwd, err := os.Getwd()
	if err != nil {
		log.Fatalf("error with pwd: %v", err)
	}

	workdir := pwd + BASE + arch
	dir, err := os.Stat(workdir)
	if err != nil || !dir.IsDir() {
		log.Fatal("architecture not found")
	}

	conf := pwd + BASE + arch + ".json"
	confStat, err := os.Stat(conf)
	if err != nil || confStat.IsDir() {
		log.Fatal("cannot find configuration")
	}

	terraform := CreateTerraform(workdir, conf)
	log.Println("Init terraform")
	err = terraform.Init()
	if err != nil {
		fmt.Print(terraform.InitError.String())
		log.Fatalf("error on terraform init: %v", err)
	}

	var wg sync.WaitGroup
	for i := 0; i <= count; i++ {
		wg.Add(1)
		go func(index int) {
			defer wg.Done()

			start := time.Now()
			log.Printf("Start creating #%d\n", index)
			cmd, err := terraform.Apply(index)
			if err == nil {
				err = cmd.Wait()
			}

			if err != nil {
				log.Printf("Error while processing #%d\n%s", index, GetStderr(cmd))
			} else {
				log.Printf("Finished creation of #%d / Duration: %v", index, time.Now().Sub(start))
			}
		}(i)
	}

	wg.Wait()
}

func DeleteArchitectures(arch string) {
	pwd, err := os.Getwd()
	if err != nil {
		log.Fatalf("error with pwd: %v", err)
	}

	workdir := pwd + BASE + arch
	dir, err := os.Stat(workdir)
	if err != nil || !dir.IsDir() {
		log.Fatal("architecture not found")
	}

	conf := pwd + BASE + arch + ".json"
	confStat, err := os.Stat(conf)
	if err != nil || confStat.IsDir() {
		log.Fatal("cannot find configuration")
	}

	terraform := CreateTerraform(workdir, conf)
	log.Println("Init terraform")
	err = terraform.Init()
	if err != nil {
		fmt.Print(terraform.InitError.String())
		log.Fatalf("error on terraform init: %v", err)
	}

	regex := regexp.MustCompile(`state-(\d+)\.tfstate$`)
	var count int = -1
	statePath := pwd + BASE + arch + "/states"
	if states, err := os.Stat(statePath); err != nil || !states.IsDir() {
		log.Fatalf("invalid state path: %s", statePath)
	}

	err = filepath.Walk(statePath, func(path string, info os.FileInfo, err error) error {
		matches := regex.FindStringSubmatch(info.Name())

		if len(matches) > 1 {
			parsed, err := strconv.Atoi(matches[1])
			if err == nil && parsed > count {
				count = parsed
			}
		}

		return nil
	})

	if count < 0 {
		log.Fatal("cannot determine number of valid states")
	}

	var wg sync.WaitGroup
	for i := 0; i <= count; i++ {
		wg.Add(1)
		go func(index int) {
			defer wg.Done()
			start := time.Now()

			log.Printf("Start destroying #%d\n", index)
			cmd, err := terraform.Destroy(index)
			if err == nil {
				err = cmd.Wait()
			}

			if err != nil {
				log.Printf("Error while processing #%d\n%s", index, GetStderr(cmd))
			} else {
				log.Printf("Finished destruction of #%d / Duration: %v", index, time.Now().Sub(start))
			}
		}(i)
	}

	wg.Wait()
}
