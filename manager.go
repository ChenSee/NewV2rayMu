package main

import (
	"context"
	"crypto/md5"
	"errors"
	"strconv"
	"time"

	"fmt"
	"net/http"

	"v2raymanager"

	"github.com/catpie/musdk-go"
	"github.com/orvice/shadowsocks-go/mu/system"
)

func getV2rayManager() (*v2raymanager.Manager, error) {
	vm, err := v2raymanager.NewManager(cfg.V2rayClientAddr, cfg.V2rayTag, logger)
	return vm, err
}

func (u *UserManager) check() error {
	logger.Info("Checking users from mu...")
	users, err := apiClient.GetUsers()
	if err != nil {
		logger.Error("Get users from error: %v", err)
		return err
	}
	logger.Info("Get %d users from mu", len(users))
	for _, user := range users {
		u.checkUser(user)
	}

	return nil
}

func (u *UserManager) checkUser(user musdk.User) error {
	ctx, _ := context.WithCancel(u.ctx)
	var err error
	if user.IsEnable() && !u.Exist(user) {
		logger.Info("Run user id %d uuid %s", user.Id, user.V2rayUser.UUID)
		// run user
		_, err = u.vm.AddUser(ctx, &user.V2rayUser)
		if err != nil {
			logger.Error("Add user %s error %v", user.V2rayUser.UUID, err)
			return err
		}
		logger.Info("Add user success %s", user.V2rayUser.UUID)
		u.AddUser(user)
		return nil
	}

	if !user.IsEnable() && u.Exist(user) {
		logger.Info("Stop user id %d uuid %s", user.Id, user.V2rayUser.UUID)
		// stop user
		err = u.vm.RemoveUser(ctx, &user.V2rayUser)

		if err != nil {
			logger.Error("Remove user error %v", err)
			time.Sleep(time.Second * 10)
			return err
		}
		u.RemoveUser(user)
		return nil
	}

	return nil
}

func (u *UserManager) restartUser() {}

func (u *UserManager) Run() error {
	for {
		u.postNodeInfo()
		time.Sleep(1)
		u.saveTrafficDaemon()
		u.check()
		time.Sleep(cfg.SyncTime)
	}
	return nil
}

func (u *UserManager) Down() {
	u.cancel()
}

func (u *UserManager) saveTrafficDaemon() {
	logger.Info("Runing save traffic daemon...")
	u.usersMu.RLock()
	defer u.usersMu.RUnlock()
	for _, user := range u.users {
		u.saveUserTraffic(user)
	}
}

func (u *UserManager) postNodeInfo() error {
	logger.Info("Posting node info...")
	err := u.PostNodeInfo()
	if err != nil {
		logger.Error("Post node info error %v", err)
	}
	return nil
}

func (u *UserManager) postNodeInfoUri() string {
	return fmt.Sprintf("%s/nodes/%d/info", cfg.WebApi.Url, cfg.WebApi.NodeId)
}

func (u *UserManager) PostNodeInfo() error {
	uptime, err := system.GetUptime()
	if err != nil {
		uptime = "0"
	}

	load, err := system.GetLoad()
	if err != nil {
		load = "- - -"
	} else {
		load = load[0:14]
	}
	timenow := time.Now().Unix()
	orginData := `{"load":"` + load + `","uptime":"` + uptime + `","time":"` + strconv.FormatInt(timenow, 10) + `"}`
	originDataByte := []byte(orginData)
	originDataHas := md5.Sum(originDataByte)
	originDataMd5 := fmt.Sprintf("%x", originDataHas)
	sigstr := originDataMd5 + cfg.WebApi.Sigkey
	sigByte := []byte(sigstr)
	sigHas := md5.Sum(sigByte)
	sig := fmt.Sprintf("%x", sigHas)
	data := `{"load":"` + load + `","uptime":"` + uptime + `","time":"` + strconv.FormatInt(timenow, 10) + `","sig":"` + sig + `"}`

	_, statusCode, err := u.httpPost(u.postNodeInfoUri(), string(data))
	if err != nil {
		return err
	}
	if statusCode != http.StatusOK {
		return errors.New(fmt.Sprintf("status code: %d", statusCode))
	}
	return nil
}
