package v2raymanager

import (
	"context"
	"fmt"
	"io"
	"log/slog"
	"strings"

	"github.com/catpie/musdk-go"
	"github.com/orvice/utils/env"
	"github.com/xtls/xray-core/app/proxyman/command"
	statscmd "github.com/xtls/xray-core/app/stats/command"
	"github.com/xtls/xray-core/common/protocol"
	"github.com/xtls/xray-core/common/serial"

	// "github.com/xtls/xray-core/proxy/shadowsocks"
	// "github.com/xtls/xray-core/proxy/trojan"
	"github.com/xtls/xray-core/proxy/vless"
	"google.golang.org/grpc"
)

type Manager struct {
	client      command.HandlerServiceClient
	statsClient statscmd.StatsServiceClient

	inBoundTag string
	logger     *slog.Logger
}

const (
	UplinkFormat   = "user>>>%s>>>traffic>>>uplink"
	DownlinkFormat = "user>>>%s>>>traffic>>>downlink"
)

type TrafficInfo struct {
	Up, Down int64
}

func NewManager(addr, tag string, l *slog.Logger) (*Manager, error) {
	cc, err := grpc.Dial(addr, grpc.WithInsecure())
	if err != nil {
		return nil, err
	}
	client := command.NewHandlerServiceClient(cc)
	statsClient := statscmd.NewStatsServiceClient(cc)
	m := &Manager{
		client:      client,
		statsClient: statsClient,
		inBoundTag:  tag,
		logger:      l,
	}
	if m.logger == nil {
		m.logger = slog.New(slog.NewJSONHandler(io.Discard, &slog.HandlerOptions{}))
	}
	return m, nil
}

func (m *Manager) SetLogger(l *slog.Logger) {
	m.logger = l
}

// return is exist,and error
func (m *Manager) AddUser(ctx context.Context, u musdk.User) (bool, error) {
	resp, err := m.client.AlterInbound(ctx, &command.AlterInboundRequest{
		Tag: m.inBoundTag,
		Operation: serial.ToTypedMessage(&command.AddUserOperation{
			User: &protocol.User{
				Level: u.V2rayUser.Level,
				Email: u.V2rayUser.Email,
				Account: serial.ToTypedMessage(&vless.Account{
					Id:   u.V2rayUser.UUID,
					Flow: env.Get("V2RAY_FLOW", "xtls-rprx-vision"),
				}),
			},
		}),
	})
	if err != nil && !IsAlreadyExistsError(err) {
		m.logger.Error("failed to call add user",
			"resp", resp,
			"error", err,
		)
		return false, err
	}
	return IsAlreadyExistsError(err), nil
}

func (m *Manager) RemoveUser(ctx context.Context, u musdk.User) error {
	resp, err := m.client.AlterInbound(ctx, &command.AlterInboundRequest{
		Tag: m.inBoundTag,
		Operation: serial.ToTypedMessage(&command.RemoveUserOperation{
			Email: u.V2rayUser.Email,
		}),
	})
	if err != nil {
		m.logger.Error("failed to call remove user : ", "error", err)
		return TODOErr
	}
	m.logger.Debug("call remove user resp: ", "resp", resp)

	return nil
}

// @todo error handle
func (m *Manager) GetTrafficAndReset(ctx context.Context, u musdk.User) (TrafficInfo, error) {
	ti := TrafficInfo{}
	up, err := m.statsClient.GetStats(ctx, &statscmd.GetStatsRequest{
		Name:   fmt.Sprintf(UplinkFormat, u.V2rayUser.Email),
		Reset_: true,
	})
	if err != nil && !IsNotFoundError(err) {
		m.logger.Error("get traffic user ", "u", u, "error", err)
		return ti, err
	}

	down, err := m.statsClient.GetStats(ctx, &statscmd.GetStatsRequest{
		Name:   fmt.Sprintf(DownlinkFormat, u.V2rayUser.Email),
		Reset_: true,
	})
	if err != nil && !IsNotFoundError(err) {
		m.logger.Error("get traffic user fail",
			"user", u,
			"error", err)
		return ti, nil
	}

	if up != nil {
		ti.Up = up.Stat.Value
	}
	if down != nil {
		ti.Down = down.Stat.Value
	}
	return ti, nil
}

func getEmailFromStatName(s string) string {
	arr := strings.Split(s, ">>>")
	if len(arr) > 1 {
		return arr[1]
	}
	return s
}

func getUUDIFromEmail(s string) string {
	arr := strings.Split(s, "@")
	if len(arr) > 0 {
		return arr[0]
	}
	return s
}
