package main

import (
	"time"

	"github.com/orvice/utils/env"
)

var (
	cfg = new(Config)
)

type Config struct {
	WebApi   WebApiCfg
	Base     BaseCfg
	SyncTime time.Duration

	V2rayClientAddr string
	V2rayTag        string

	LogPath string
}

type BaseCfg struct {
}

type WebApiCfg struct {
	Url    string
	Sigkey string
	Token  string
	NodeId string
}

func initCfg() {
	cfg.WebApi = WebApiCfg{
		Url:    env.Get("MU_URI"),
		Sigkey: env.Get("MU_SIGKEY", "ASignKey"),
		Token:  env.Get("MU_TOKEN", "AccessToken"),
		NodeId: env.Get("MU_NODE_ID"),
	}
	st := env.GetInt("SYNC_TIME", 60)
	cfg.SyncTime = time.Second * time.Duration(st)
	cfg.V2rayClientAddr = env.Get("V2RAY_ADDR", "127.0.0.1:8301")
	cfg.V2rayTag = env.Get("V2RAY_TAG", "proxy")
	cfg.LogPath = env.Get("LOG_PATH", "log/v2ray-mu.log")
}
