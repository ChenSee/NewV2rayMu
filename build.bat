SET GOOS=linux
go build -ldflags="-s -w"
upx v2mctl