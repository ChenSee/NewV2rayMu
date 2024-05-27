package main

import (
	"fmt"
	"log/slog"
	"os"
	"os/signal"
	"syscall"
)

var (
	logger *slog.Logger
)

func init() {
}

func main() {
	var err error
	initCfg()

	textHandler := slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{})
	logger = slog.New(textHandler)

	InitWebApi()

	um, err := NewUserManager()
	if err != nil {
		fmt.Println(err)
		os.Exit(0)
	}

	go um.Run()

	osSignals := make(chan os.Signal, 1)
	signal.Notify(osSignals, os.Interrupt, os.Kill, syscall.SIGTERM)

	<-osSignals
}
