Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id E49F26B0007
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 00:19:03 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id w23-v6so3292283ioa.1
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 21:19:03 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id r2-v6sor1078368jam.71.2018.07.03.21.19.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Jul 2018 21:19:02 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 03 Jul 2018 21:19:01 -0700
Message-ID: <000000000000fe4b15057024bacd@google.com>
Subject: kernel BUG at mm/gup.c:LINE!
From: syzbot <syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, ying.huang@intel.com, zi.yan@cs.rutgers.edu

Hello,

syzbot found the following crash on:

HEAD commit:    d3bc0e67f852 Merge tag 'for-4.18-rc2-tag' of git://git.ker..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=1000077c400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=a63be0c83e84d370
dashboard link: https://syzkaller.appspot.com/bug?extid=5dcb560fe12aa5091c06
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
userspace arch: i386
syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=158577a2400000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com

IPv6: ADDRCONF(NETDEV_UP): veth0: link is not ready
IPv6: ADDRCONF(NETDEV_CHANGE): veth0: link becomes ready
IPv6: ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
8021q: adding VLAN 0 to HW filter on device team0
------------[ cut here ]------------
kernel BUG at mm/gup.c:1242!
invalid opcode: 0000 [#1] SMP KASAN
CPU: 1 PID: 4837 Comm: syz-executor0 Not tainted 4.18.0-rc2+ #29
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:__mm_populate+0x472/0x520 mm/gup.c:1242
Code: ea 03 0f b6 04 02 84 c0 74 08 3c 03 0f 8e aa 00 00 00 44 8b 75 98 45  
31 e4 e9 58 ff ff ff e8 b5 9e d1 ff 0f 0b e8 ae 9e d1 ff <0f> 0b 48 8b bd  
60 ff ff ff e8 d0 72 0f 00 e9 52 fc ff ff 48 8b bd
RSP: 0018:ffff8801aae77ae0 EFLAGS: 00010293
RAX: ffff8801cfb48280 RBX: 0000000000008000 RCX: ffffffff81aa6a68
RDX: 0000000000000000 RSI: ffffffff81aa6dc2 RDI: 0000000000000006
RBP: ffff8801aae77ba0 R08: ffff8801cfb48280 R09: fffffbfff133d66a
R10: 0000000000000003 R11: 0000000000000000 R12: 000000007bf81000
R13: 0000000000007676 R14: dffffc0000000000 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff8801daf00000(0063) knlGS:000000000865b900
CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
CR2: 00000000080e3a94 CR3: 00000001cb021000 CR4: 00000000001406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
  mm_populate include/linux/mm.h:2296 [inline]
  vm_brk_flags+0x1fe/0x240 mm/mmap.c:3038
  vm_brk+0x1f/0x30 mm/mmap.c:3045
  load_elf_library+0x711/0x8e0 fs/binfmt_elf.c:1266
  __do_sys_uselib fs/exec.c:161 [inline]
  __se_sys_uselib fs/exec.c:120 [inline]
  __ia32_sys_uselib+0x37e/0x4c0 fs/exec.c:120
  do_syscall_32_irqs_on arch/x86/entry/common.c:326 [inline]
  do_fast_syscall_32+0x34d/0xfb2 arch/x86/entry/common.c:397
  entry_SYSENTER_compat+0x70/0x7f arch/x86/entry/entry_64_compat.S:139
RIP: 0023:0xf7fcbcb9
Code: 55 08 8b 88 64 cd ff ff 8b 98 68 cd ff ff 89 c8 85 d2 74 02 89 0a 5b  
5d c3 8b 04 24 c3 8b 1c 24 c3 51 52 55 89 e5 0f 34 cd 80 <5d> 5a 59 c3 90  
90 90 90 eb 0d 90 90 90 90 90 90 90 90 90 90 90 90
RSP: 002b:00000000ff8df4ac EFLAGS: 00000282 ORIG_RAX: 0000000000000056
RAX: ffffffffffffffda RBX: 0000000020000040 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000000
RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
Modules linked in:
Dumping ftrace buffer:
    (ftrace buffer empty)
---[ end trace f964ea7008b66351 ]---
RIP: 0010:__mm_populate+0x472/0x520 mm/gup.c:1242
Code: ea 03 0f b6 04 02 84 c0 74 08 3c 03 0f 8e aa 00 00 00 44 8b 75 98 45  
31 e4 e9 58 ff ff ff e8 b5 9e d1 ff 0f 0b e8 ae 9e d1 ff <0f> 0b 48 8b bd  
60 ff ff ff e8 d0 72 0f 00 e9 52 fc ff ff 48 8b bd
RSP: 0018:ffff8801aae77ae0 EFLAGS: 00010293
RAX: ffff8801cfb48280 RBX: 0000000000008000 RCX: ffffffff81aa6a68
RDX: 0000000000000000 RSI: ffffffff81aa6dc2 RDI: 0000000000000006
RBP: ffff8801aae77ba0 R08: ffff8801cfb48280 R09: fffffbfff133d66a
R10: 0000000000000003 R11: 0000000000000000 R12: 000000007bf81000
R13: 0000000000007676 R14: dffffc0000000000 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff8801daf00000(0063) knlGS:000000000865b900
CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
CR2: 00000000080e3a94 CR3: 00000001cb021000 CR4: 00000000001406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches
