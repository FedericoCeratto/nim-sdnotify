
import os, posix, strutils
import sdnotify

let sd = newSDNotify()
sd.notify_ready()
sd.send_msg("STATUS=Running as expected")

onSignal(SIGABRT):
  echo "<2>Received SIGABRT as expected"

#sd.notify_errno(2)
#sd.notify_buserror("org.freedesktop.DBus.Error.TimedOut")
#sd.notify_main_pid(1234)

for cnt in 0..3:
  sleep 1000
  sd.ping_watchdog()
  echo "<3>ping $#" % [$cnt]

sd.reset_watchdog_timer(2_000_000)
echo "<3>should not time out here"
sleep 1000

sd.reset_watchdog_timer(1_000_000)
echo "<3>letting watchdog expire..."
sleep 20000
