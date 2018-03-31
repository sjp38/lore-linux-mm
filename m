Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 28C7C6B0005
	for <linux-mm@kvack.org>; Sat, 31 Mar 2018 16:47:07 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id e68so3690696iod.6
        for <linux-mm@kvack.org>; Sat, 31 Mar 2018 13:47:07 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id u19sor5186791iou.133.2018.03.31.13.47.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 31 Mar 2018 13:47:06 -0700 (PDT)
MIME-Version: 1.0
Date: Sat, 31 Mar 2018 13:47:05 -0700
Message-ID: <001a11447acaab591f0568bb75e2@google.com>
Subject: general protection fault in __mem_cgroup_free
From: syzbot <syzbot+8a5de3cce7cdc70e9ebe@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com

Hello,

syzbot hit the following crash on upstream commit
9dd2326890d89a5179967c947dab2bab34d7ddee (Fri Mar 30 17:29:47 2018 +0000)
Merge tag 'ceph-for-4.16-rc8' of git://github.com/ceph/ceph-client
syzbot dashboard link:  
https://syzkaller.appspot.com/bug?extid=8a5de3cce7cdc70e9ebe

So far this crash happened 14 times on upstream.
C reproducer: https://syzkaller.appspot.com/x/repro.c?id=5578311367393280
syzkaller reproducer:  
https://syzkaller.appspot.com/x/repro.syz?id=5708657048158208
Raw console output:  
https://syzkaller.appspot.com/x/log.txt?id=6693821748346880
Kernel config:  
https://syzkaller.appspot.com/x/.config?id=-2760467897697295172
compiler: gcc (GCC) 7.1.1 20170620

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+8a5de3cce7cdc70e9ebe@syzkaller.appspotmail.com
It will help syzbot understand when the bug is fixed. See footer for  
details.
If you forward the report, please keep this part and the footer.

RBP: 00000000006dcc20 R08: 0000000000000002 R09: 0000000000003335
R10: 0000000000000000 R11: 0000000000000246 R12: 0030656c69662f2e
R13: 00007f1747954d80 R14: ffffffffffffffff R15: 0000000000000006
kasan: CONFIG_KASAN_INLINE enabled
kasan: GPF could be caused by NULL-ptr deref or user memory access
general protection fault: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
    (ftrace buffer empty)
Modules linked in:
CPU: 0 PID: 4422 Comm: syzkaller101598 Not tainted 4.16.0-rc7+ #372
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:free_mem_cgroup_per_node_info mm/memcontrol.c:4111 [inline]
RIP: 0010:__mem_cgroup_free+0x71/0x110 mm/memcontrol.c:4120
RSP: 0018:ffff8801accf75a8 EFLAGS: 00010206
RAX: 0000000000000011 RBX: 0000000000000000 RCX: ffffffff8310cdfd
RDX: 0000000000000000 RSI: 0000000000000040 RDI: 0000000000000088
RBP: ffff8801accf75c8 R08: 0000000000000000 R09: ffff8801accf73a0
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: ffff8801ad210d40 R14: dffffc0000000000 R15: ffff8801ad210d40
FS:  00007f1747955700(0000) GS:ffff8801db000000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000460000 CR3: 00000001cb367004 CR4: 00000000001606f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
  mem_cgroup_free mm/memcontrol.c:4128 [inline]
  mem_cgroup_css_alloc+0x403/0x19c0 mm/memcontrol.c:4239
  css_create kernel/cgroup/cgroup.c:4729 [inline]
  cgroup_apply_control_enable+0x44d/0xbc0 kernel/cgroup/cgroup.c:2916
  cgroup_mkdir+0x56f/0xfc0 kernel/cgroup/cgroup.c:4938
  kernfs_iop_mkdir+0x153/0x1e0 fs/kernfs/dir.c:1099
  vfs_mkdir+0x390/0x600 fs/namei.c:3800
  SYSC_mkdirat fs/namei.c:3823 [inline]
  SyS_mkdirat+0x22b/0x2b0 fs/namei.c:3807
  do_syscall_64+0x281/0x940 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x42/0xb7
RIP: 0033:0x44a0c9
RSP: 002b:00007f1747954d78 EFLAGS: 00000246 ORIG_RAX: 0000000000000102
RAX: ffffffffffffffda RBX: 00000000006dcc24 RCX: 000000000044a0c9
RDX: 0000000000000020 RSI: 0000000020000280 RDI: 0000000000000005
RBP: 00000000006dcc20 R08: 0000000000000002 R09: 0000000000003335
R10: 0000000000000000 R11: 0000000000000246 R12: 0030656c69662f2e
R13: 00007f1747954d80 R14: ffffffffffffffff R15: 0000000000000006
Code: 00 00 48 89 f8 48 c1 e8 03 42 80 3c 30 00 0f 85 99 00 00 00 4f 8b a4  
e5 f0 09 00 00 49 8d bc 24 88 00 00 00 48 89 f8 48 c1 e8 03 <42> 80 3c 30  
00 0f 85 88 00 00 00 49 8b bc 24 88 00 00 00 e8 77
RIP: free_mem_cgroup_per_node_info mm/memcontrol.c:4111 [inline] RSP:  
ffff8801accf75a8
RIP: __mem_cgroup_free+0x71/0x110 mm/memcontrol.c:4120 RSP: ffff8801accf75a8
---[ end trace 57ac07c30502ef78 ]---
Kernel panic - not syncing: Fatal exception
Dumping ftrace buffer:
    (ftrace buffer empty)
Kernel Offset: disabled
Rebooting in 86400 seconds..


---
This bug is generated by a dumb bot. It may contain errors.
See https://goo.gl/tpsmEJ for details.
Direct all questions to syzkaller@googlegroups.com.

syzbot will keep track of this bug report.
If you forgot to add the Reported-by tag, once the fix for this bug is  
merged
into any tree, please reply to this email with:
#syz fix: exact-commit-title
If you want to test a patch for this bug, please reply with:
#syz test: git://repo/address.git branch
and provide the patch inline or as an attachment.
To mark this as a duplicate of another syzbot report, please reply with:
#syz dup: exact-subject-of-another-report
If it's a one-off invalid bug report, please reply with:
#syz invalid
Note: if the crash happens again, it will cause creation of a new bug  
report.
Note: all commands must start from beginning of the line in the email body.
