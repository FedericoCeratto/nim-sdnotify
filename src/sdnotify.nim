
from posix import Pid

{.deadCodeElim: on.}

import net,
  os,
  strutils

const env_var_name = "NOTIFY_SOCKET"

type SDNotify* = ref object of RootObj
  sock*: Socket
  sock_path*: string

proc newSDNotify*(clean_environment=true): SDNotify =
  ## Initialize SDNotify
  ## clean_environment: remove the NOTIFY_SOCKET environment variable
  new result
  let sock_path = getEnv(env_var_name)
  if sock_path == "":
    raise newException(Exception,
      "NOTIFY_SOCKET environment variable not found")

  #   socket.SOCK_DGRAM | socket.SOCK_CLOEXEC)
  result.sock = newSocket(AF_UNIX, SOCK_DGRAM, IPPROTO_IP)
  result.sock.connectUnix(sock_path)
  #         if addr[0] == '@':
  #addr = '\0' + addr[1:]

  if clean_environment:
    putEnv(env_var_name, "")

proc send_msg*(sd: SDNotify, msg: string) =
  ## Send raw message
  sd.sock.send(msg)

proc ping_watchdog*(sd: SDNotify) =
  ## Ping watchdog
  sd.send_msg "WATCHDOG=1"

proc notify_ready*(sd: SDNotify) =
  ## Notify application is ready
  sd.send_msg "READY=1"

proc notify_stopping*(sd: SDNotify) =
  ## Notify application is going to stop
  sd.send_msg "STOPPING=1"

proc notify_status*(sd: SDNotify, status: string) =
  ## Notify user-defined status
  sd.send_msg("STATUS=$#" % status)

proc notify_errno*(sd: SDNotify, errno: int) =
  ## Notify of an error using an errno error code
  sd.send_msg("ERRNO=$#" % $errno)

proc notify_buserror*(sd: SDNotify, error_msg: string) =
  ## Notify of a D-Bus error
  ## e.g. "org.freedesktop.DBus.Error.TimedOut"
  sd.send_msg("BUSERROR=$#" % error_msg)

proc reset_watchdog_timer*(sd: SDNotify, usec: int) =
  ## Reset watchdog_usec
  sd.send_msg("WATCHDOG_USEC=$#" % $usec)

proc notify_main_pid*(sd: SDNotify, pid: int) =
  ## Inform systemd about the main process PID
  sd.send_msg("MAINPID=$#" % $pid)
