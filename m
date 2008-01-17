Subject: Crash with 2.6.24-rc6-mm1 in restore_i387_ia32
Message-Id: <20080117082725.11AE810655@localhost>
Date: Thu, 17 Jan 2008 00:27:25 -0800 (PST)
From: mrubin@google.com (Michael Rubin)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mrubin@google.com
List-ID: <linux-mm.kvack.org>

When I boot my system with 2.6.24-rc6 everything is great. When I apply the mm1
patch I crash with the output below. Anyone seen this before?

Starting sendmail: Unable to handle kernel paging request at 0000000100000013 RIP: 
 [<ffffffff80215d2f>] restore_i387_ia32+0x1f/0x150
PGD 47e134067 PUD 0 
Oops: 0000 [1] SMP 
last sysfs file: /sys/devices/system/machinecheck/machinecheck3/tolerant
CPU 3 
Modules linked in:
Pid: 0, comm: make Not tainted 2.6.24-rc6-mm1 #2
RIP: 0010:[<ffffffff80215d2f>]  [<ffffffff80215d2f>] restore_i387_ia32+0x1f/0x150
RSP: 0000:ffff81047e58be38  EFLAGS: 00010282
RAX: ffff81047e58bfd8 RBX: ffff81047e4cc000 RCX: 00000000ffffffff
RDX: 0000000000000000 RSI: 00000000ffdc232c RDI: ffff81047e4cc000
RBP: ffff81047e58bec8 R08: 0000000000000000 R09: 00000000ffdc25d8
R10: ffff81047e58a000 R11: 0000000000000000 R12: 0000000000000000
R13: ffff81047e4cc000 R14: ffff81047e58bf58 R15: ffff81047e58bf24
FS:  00007ff45f9566e0(0003) GS:ffff81047f015d80(0003) knlGS:00000000f7eebe80
CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
CR2: 0000000100000013 CR3: 000000047e117000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process make (pid: 0, threadinfo 00000000ffffffff, task ffff81047e4cc000)
Stack:  ffff81047e58be48 ffffffff80243202 ffff81047e58bf48 ffffffff8020ad7d
 ffff81047e58be98 0000000000000011 0000000000000001 00000000ffffffff
 0000000000000011 ffff810400040001 000000080000087c 0000000000000000
Call Trace:
Code: 8b 51 14 89 d0 83 e0 01 85 c0 74 11 9b 83 e2 fe 89 51 14 0f 
RIP  [<ffffffff80215d2f>] restore_i387_ia32+0x1f/0x150
 RSP <ffff81047e58be38>
CR2: 0000000100000013
divide error: 0000 [2] SMP 
last sysfs file: /sys/devices/system/machinecheck/machinecheck3/tolerant
CPU 1 
Modules linked in:
Pid: 2175, comm: uname Tainted: G      D 2.6.24-rc6-mm1 #2
RIP: 0010:[<ffffffff8022c204>]  [<ffffffff8022c204>] calc_delta_mine+0x64/0x90
RSP: 0000:ffff81027dc9fb78  EFLAGS: 00010046
RAX: 0000000100000000 RBX: ffff81047e4cc038 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000400 RDI: ffffc009aeef285e
RBP: ffff81027dc9fb78 R08: ffff81047e4cc038 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000064 R12: ffff8102800a21c0
R13: ffff8102800a21c0 R14: 0000000a6eeea85e R15: 0000000000000003
FS:  00007f120bb256e0(0000) GS:ffff81027f029000(0000) knlGS:00000000f7ef6e80
CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
CR2: 00000000f7f05aa0 CR3: 000000027dc59000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process uname (pid: 2175, threadinfo ffff81027dc9e000, task ffff81027e542790)
Stack:  ffff81027dc9fba8 ffffffff802313a6 0000000000000001 ffff8102800a21c0
 ffff81047e552038 0000000000000001 ffff81027dc9fbd8 ffffffff80231491
 ffff81027dc9fbd8 ffff81047e552038 ffff8102800a5dc0 ffff8102800a5dc0
Call Trace:
 [<ffffffff802313a6>] update_curr+0xa6/0xb0
 [<ffffffff80231491>] enqueue_entity+0x21/0x70
 [<ffffffff80231b72>] enqueue_task_fair+0x32/0x60
 [<ffffffff8022c643>] enqueue_task+0x13/0x30
 [<ffffffff8022c690>] activate_task+0x30/0x50
 [<ffffffff8023392d>] try_to_wake_up+0x10d/0x130
 [<ffffffff8023395d>] default_wake_function+0xd/0x10
 [<ffffffff8024c531>] autoremove_wake_function+0x11/0x40
 [<ffffffff8022cafe>] __wake_up_common+0x4e/0x90
 [<ffffffff8022cc1a>] __wake_up_sync+0x4a/0x70
 [<ffffffff8029bd62>] pipe_write+0x3d2/0x500
 [<ffffffff80273d35>] __do_fault+0x215/0x470
 [<ffffffff80294af1>] do_sync_write+0xf1/0x150
 [<ffffffff8024c520>] autoremove_wake_function+0x0/0x40
 [<ffffffff802241c0>] do_page_fault+0x420/0x7e0
 [<ffffffff8033afd2>] __up_write+0x72/0x150
 [<ffffffff80294fe7>] vfs_write+0xc7/0x170
 [<ffffffff80295820>] sys_write+0x50/0x90
 [<ffffffff80225f32>] ia32_sysret+0x0/0xa
Code: 48 f7 f1 48 8d 48 01 49 89 48 08 eb 9f 48 8d 82 00 80 00 00 
RIP  [<ffffffff8022c204>] calc_delta_mine+0x64/0x90
 RSP <ffff81027dc9fb78>
---[ end trace ca96c3a87188c958 ]---
BUG: sleeping function called from invalid context at kernel/rwsem.c:21
in_atomic():0, irqs_disabled():1
Pid: 2175, comm: uname Tainted: G      D 2.6.24-rc6-mm1 #2
Call Trace:
 [<ffffffff8022d652>] __might_sleep+0xb2/0xd0
 [<ffffffff804f76ed>] down_read+0x1d/0x30
 [<ffffffff802390f0>] exit_mm+0x30/0x100
 [<ffffffff8023aecb>] do_exit+0x1bb/0x850
 [<ffffffff8020c8a5>] oops_end+0x85/0x90
 [<ffffffff8020d38e>] die+0x5e/0x90
 [<ffffffff8020d6e4>] do_trap+0x154/0x160
 [<ffffffff8020d86a>] do_divide_error+0x8a/0xa0
 [<ffffffff8022c204>] calc_delta_mine+0x64/0x90
 [<ffffffff8029e1f0>] do_lookup+0x80/0x1f0
 [<ffffffff802a7b85>] dput+0x65/0x1a0
 [<ffffffff8029f055>] __link_path_walk+0xcf5/0xd50
 [<ffffffff804f8a99>] error_exit+0x0/0x51
 [<ffffffff8022c204>] calc_delta_mine+0x64/0x90
 [<ffffffff802313a6>] update_curr+0xa6/0xb0
 [<ffffffff80231491>] enqueue_entity+0x21/0x70
 [<ffffffff80231b72>] enqueue_task_fair+0x32/0x60
 [<ffffffff8022c643>] enqueue_task+0x13/0x30
 [<ffffffff8022c690>] activate_task+0x30/0x50
 [<ffffffff8023392d>] try_to_wake_up+0x10d/0x130
 [<ffffffff8023395d>] default_wake_function+0xd/0x10
 [<ffffffff8024c531>] autoremove_wake_function+0x11/0x40
 [<ffffffff8022cafe>] __wake_up_common+0x4e/0x90
 [<ffffffff8022cc1a>] __wake_up_sync+0x4a/0x70
 [<ffffffff8029bd62>] pipe_write+0x3d2/0x500
 [<ffffffff80273d35>] __do_fault+0x215/0x470
 [<ffffffff80294af1>] do_sync_write+0xf1/0x150
 [<ffffffff8024c520>] autoremove_wake_function+0x0/0x40
 [<ffffffff802241c0>] do_page_fault+0x420/0x7e0
 [<ffffffff8033afd2>] __up_write+0x72/0x150
 [<ffffffff80294fe7>] vfs_write+0xc7/0x170
 [<ffffffff80295820>] sys_write+0x50/0x90
 [<ffffffff80225f32>] ia32_sysret+0x0/0xa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
