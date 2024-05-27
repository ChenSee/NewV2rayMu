package v2raymanager

type User interface {
	GetPassword() string
	GetEmail() string
	GetUUID() string
	GetAlterID() uint32
	GetLevel() uint32
}

var _ User = user{}

type user struct {
	email    string
	password string
	uuid     string
	alterID  uint32
	level    uint32
}

func (u user) GetEmail() string {
	return u.email
}

func (u user) GetPassword() string {
	return u.password
}

func (u user) GetUUID() string {
	return u.uuid
}

func (u user) GetLevel() uint32 {
	return u.level
}

func (u user) GetAlterID() uint32 {
	return u.alterID
}
