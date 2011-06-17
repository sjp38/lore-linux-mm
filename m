Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4E6E26B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 05:24:57 -0400 (EDT)
Date: 17 Jun 2011 05:24:54 -0400
Message-ID: <20110617092454.497.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: 3.0-rc3 stuck process in munmap()
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: linux@horizon.com

As a followup to my report of firefox getting stuck in 3.0-rc1, here's the
problem repeated on -rc3.  top(1) can produce the process status, but
"ps axf" hangs before printing anything.

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND           
 2821 username  20   0 1453m 964m  18m D    0 47.8   1434:51 firefox-bin        

Core 2 duo, 2 GB RAM, NO_HZ=y, MZ=300, PREEMPT_VOLUNTARY=y.
It's been stuck for about half an hour so far.

I wasn't using Firefox when I noticed that it wasn't refreshing its
window when I changed to that screen.

I'm not going to reboot in case someone wants information gathered
this time.

INFO: task firefox-bin:9560 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
firefox-bin     D f4b2df58     0  9560   2793 0x00000000
 f54c2cb0 00000082 00000002 f4b2df58 00000000 00000000 00000000 00000000
 c14f22c0 f54c2e24 c14f22c0 00000000 00000000 b162f6a0 00000000 00000002
 00000001 f59ce208 000007fb f59c7268 acb9e000 acb9e000 00000000 c10735b3
Call Trace:
 [<c10735b3>] ? sys_madvise+0x42b/0x46c
 [<c1304a2d>] ? rwsem_down_failed_common+0xa1/0xc9
 [<c1304ab2>] ? call_rwsem_down_write_failed+0x6/0x8
 [<c1304529>] ? down_write+0x1c/0x1e
 [<c107833a>] ? sys_munmap+0x18/0x35
 [<c1305410>] ? sysenter_do_call+0x12/0x26
 [<c1300000>] ? set_intr_gate+0xe/0x2d
INFO: task firefox-bin:9560 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
firefox-bin     D f4b2df58     0  9560   2793 0x00000000
 f54c2cb0 00000082 00000002 f4b2df58 00000000 00000000 00000000 00000000
 c14f22c0 f54c2e24 c14f22c0 00000000 00000000 b162f6a0 00000000 00000002
 00000001 f59ce208 000007fb f59c7268 acb9e000 acb9e000 00000000 c10735b3
Call Trace:
 [<c10735b3>] ? sys_madvise+0x42b/0x46c
 [<c1304a2d>] ? rwsem_down_failed_common+0xa1/0xc9
 [<c1304ab2>] ? call_rwsem_down_write_failed+0x6/0x8
 [<c1304529>] ? down_write+0x1c/0x1e
 [<c107833a>] ? sys_munmap+0x18/0x35
 [<c1305410>] ? sysenter_do_call+0x12/0x26
 [<c1300000>] ? set_intr_gate+0xe/0x2d
INFO: task firefox-bin:9560 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
firefox-bin     D f4b2df58     0  9560   2793 0x00000000
 f54c2cb0 00000082 00000002 f4b2df58 00000000 00000000 00000000 00000000
 c14f22c0 f54c2e24 c14f22c0 00000000 00000000 b162f6a0 00000000 00000002
 00000001 f59ce208 000007fb f59c7268 acb9e000 acb9e000 00000000 c10735b3
Call Trace:
 [<c10735b3>] ? sys_madvise+0x42b/0x46c
 [<c1304a2d>] ? rwsem_down_failed_common+0xa1/0xc9
 [<c1304ab2>] ? call_rwsem_down_write_failed+0x6/0x8
 [<c1304529>] ? down_write+0x1c/0x1e
 [<c107833a>] ? sys_munmap+0x18/0x35
 [<c1305410>] ? sysenter_do_call+0x12/0x26
 [<c1300000>] ? set_intr_gate+0xe/0x2d
INFO: task firefox-bin:9560 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
firefox-bin     D f4b2df58     0  9560   2793 0x00000000
 f54c2cb0 00000082 00000002 f4b2df58 00000000 00000000 00000000 00000000
 c14f22c0 f54c2e24 c14f22c0 00000000 00000000 b162f6a0 00000000 00000002
 00000001 f59ce208 000007fb f59c7268 acb9e000 acb9e000 00000000 c10735b3
Call Trace:
 [<c10735b3>] ? sys_madvise+0x42b/0x46c
 [<c1304a2d>] ? rwsem_down_failed_common+0xa1/0xc9
 [<c1304ab2>] ? call_rwsem_down_write_failed+0x6/0x8
 [<c1304529>] ? down_write+0x1c/0x1e
 [<c107833a>] ? sys_munmap+0x18/0x35
 [<c1305410>] ? sysenter_do_call+0x12/0x26
 [<c1300000>] ? set_intr_gate+0xe/0x2d
INFO: task firefox-bin:9560 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
firefox-bin     D f4b2df58     0  9560   2793 0x00000000
 f54c2cb0 00000082 00000002 f4b2df58 00000000 00000000 00000000 00000000
 c14f22c0 f54c2e24 c14f22c0 00000000 00000000 b162f6a0 00000000 00000002
 00000001 f59ce208 000007fb f59c7268 acb9e000 acb9e000 00000000 c10735b3
Call Trace:
 [<c10735b3>] ? sys_madvise+0x42b/0x46c
 [<c1304a2d>] ? rwsem_down_failed_common+0xa1/0xc9
 [<c1304ab2>] ? call_rwsem_down_write_failed+0x6/0x8
 [<c1304529>] ? down_write+0x1c/0x1e
 [<c107833a>] ? sys_munmap+0x18/0x35
 [<c1305410>] ? sysenter_do_call+0x12/0x26
 [<c1300000>] ? set_intr_gate+0xe/0x2d
INFO: task firefox-bin:9560 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
firefox-bin     D f4b2df58     0  9560   2793 0x00000000
 f54c2cb0 00000082 00000002 f4b2df58 00000000 00000000 00000000 00000000
 c14f22c0 f54c2e24 c14f22c0 00000000 00000000 b162f6a0 00000000 00000002
 00000001 f59ce208 000007fb f59c7268 acb9e000 acb9e000 00000000 c10735b3
Call Trace:
 [<c10735b3>] ? sys_madvise+0x42b/0x46c
 [<c1304a2d>] ? rwsem_down_failed_common+0xa1/0xc9
 [<c1304ab2>] ? call_rwsem_down_write_failed+0x6/0x8
 [<c1304529>] ? down_write+0x1c/0x1e
 [<c107833a>] ? sys_munmap+0x18/0x35
 [<c1305410>] ? sysenter_do_call+0x12/0x26
 [<c1300000>] ? set_intr_gate+0xe/0x2d
INFO: task firefox-bin:9560 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
firefox-bin     D f4b2df58     0  9560   2793 0x00000000
 f54c2cb0 00000082 00000002 f4b2df58 00000000 00000000 00000000 00000000
 c14f22c0 f54c2e24 c14f22c0 00000000 00000000 b162f6a0 00000000 00000002
 00000001 f59ce208 000007fb f59c7268 acb9e000 acb9e000 00000000 c10735b3
Call Trace:
 [<c10735b3>] ? sys_madvise+0x42b/0x46c
 [<c1304a2d>] ? rwsem_down_failed_common+0xa1/0xc9
 [<c1304ab2>] ? call_rwsem_down_write_failed+0x6/0x8
 [<c1304529>] ? down_write+0x1c/0x1e
 [<c107833a>] ? sys_munmap+0x18/0x35
 [<c1305410>] ? sysenter_do_call+0x12/0x26
 [<c1300000>] ? set_intr_gate+0xe/0x2d
INFO: task firefox-bin:9560 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
firefox-bin     D f4b2df58     0  9560   2793 0x00000000
 f54c2cb0 00000082 00000002 f4b2df58 00000000 00000000 00000000 00000000
 c14f22c0 f54c2e24 c14f22c0 00000000 00000000 b162f6a0 00000000 00000002
 00000001 f59ce208 000007fb f59c7268 acb9e000 acb9e000 00000000 c10735b3
Call Trace:
 [<c10735b3>] ? sys_madvise+0x42b/0x46c
 [<c1304a2d>] ? rwsem_down_failed_common+0xa1/0xc9
 [<c1304ab2>] ? call_rwsem_down_write_failed+0x6/0x8
 [<c1304529>] ? down_write+0x1c/0x1e
 [<c107833a>] ? sys_munmap+0x18/0x35
 [<c1305410>] ? sysenter_do_call+0x12/0x26
 [<c1300000>] ? set_intr_gate+0xe/0x2d
INFO: task firefox-bin:9560 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
firefox-bin     D f4b2df58     0  9560   2793 0x00000000
 f54c2cb0 00000082 00000002 f4b2df58 00000000 00000000 00000000 00000000
 c14f22c0 f54c2e24 c14f22c0 00000000 00000000 b162f6a0 00000000 00000002
 00000001 f59ce208 000007fb f59c7268 acb9e000 acb9e000 00000000 c10735b3
Call Trace:
 [<c10735b3>] ? sys_madvise+0x42b/0x46c
 [<c1304a2d>] ? rwsem_down_failed_common+0xa1/0xc9
 [<c1304ab2>] ? call_rwsem_down_write_failed+0x6/0x8
 [<c1304529>] ? down_write+0x1c/0x1e
 [<c107833a>] ? sys_munmap+0x18/0x35
 [<c1305410>] ? sysenter_do_call+0x12/0x26
 [<c1300000>] ? set_intr_gate+0xe/0x2d
INFO: task firefox-bin:9560 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
firefox-bin     D f4b2df58     0  9560   2793 0x00000000
 f54c2cb0 00000082 00000002 f4b2df58 00000000 00000000 00000000 00000000
 c14f22c0 f54c2e24 c14f22c0 00000000 00000000 b162f6a0 00000000 00000002
 00000001 f59ce208 000007fb f59c7268 acb9e000 acb9e000 00000000 c10735b3
Call Trace:
 [<c10735b3>] ? sys_madvise+0x42b/0x46c
 [<c1304a2d>] ? rwsem_down_failed_common+0xa1/0xc9
 [<c1304ab2>] ? call_rwsem_down_write_failed+0x6/0x8
 [<c1304529>] ? down_write+0x1c/0x1e
 [<c107833a>] ? sys_munmap+0x18/0x35
 [<c1305410>] ? sysenter_do_call+0x12/0x26
 [<c1300000>] ? set_intr_gate+0xe/0x2d

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
