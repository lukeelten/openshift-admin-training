package main

import (
	"fmt"
	"io/ioutil"
	"os/exec"
	"strings"
)

type Terraform struct {
	init *exec.Cmd

	defaultArgs []string
	workdir     string
	states      string

	InitError *strings.Builder
}

func CreateTerraform(workdir string, conf string) *Terraform {
	terraform := new(Terraform)
	terraform.InitError = new(strings.Builder)
	terraform.states = "states"
	terraform.workdir = workdir

	terraform.defaultArgs = make([]string, 3)
	terraform.defaultArgs[0] = "-input=false"
	terraform.defaultArgs[1] = "-auto-approve"
	terraform.defaultArgs[2] = fmt.Sprintf("-var-file=%s", conf)

	terraform.init = exec.Command("terraform", "init", "-input=false")

	terraform.init.Dir = workdir
	terraform.init.Stdout = ioutil.Discard
	terraform.init.Stderr = terraform.InitError

	return terraform
}

func (terraform *Terraform) Init() error {
	terraform.InitError.Reset()

	return terraform.init.Run()
}

func (terraform *Terraform) Apply(index int) (*exec.Cmd, error) {
	stateArg := fmt.Sprintf("-state=%s/state-%d.tfstate", terraform.states, index)
	trainingArg := fmt.Sprintf("Training=%d", index)

	args := []string{"apply", "-var", trainingArg, stateArg}
	args = append(args, terraform.defaultArgs...)

	command := exec.Command("terraform", args...)
	command.Stdout = ioutil.Discard
	command.Stderr = new(strings.Builder)
	command.Dir = terraform.workdir

	return command, command.Start()
}

func (terraform *Terraform) Destroy(index int) (*exec.Cmd, error) {
	stateArg := fmt.Sprintf("-state=%s/state-%d.tfstate", terraform.states, index)
	trainingArg := fmt.Sprintf("Training=%d", index)

	args := []string{"destroy", "-var", trainingArg, stateArg}
	args = append(args, terraform.defaultArgs...)

	command := exec.Command("terraform", args...)
	command.Stdout = ioutil.Discard
	command.Stderr = new(strings.Builder)
	command.Dir = terraform.workdir

	return command, command.Start()
}
