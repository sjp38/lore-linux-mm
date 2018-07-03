Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 61F7B6B0003
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 17:30:04 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id k85-v6so3011333ita.0
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 14:30:04 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id 193-v6sor652963itx.112.2018.07.03.14.30.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Jul 2018 14:30:02 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 03 Jul 2018 14:30:02 -0700
In-Reply-To: <000000000000e46d0a056d4c70ce@google.com>
Message-ID: <00000000000056285005701f0414@google.com>
Subject: Re: BUG: unable to handle kernel (3)
From: syzbot <syzbot+adfeaaee641dd4fdac43@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bridge@lists.linux-foundation.org, coreteam@netfilter.org, davem@davemloft.net, fw@strlen.de, gregkh@linuxfoundation.org, hmclauchlan@fb.com, kadlec@blackhole.kfki.hu, kstewart@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, pablo@netfilter.org, pombredanne@nexb.com, stephen@networkplumber.org, syzkaller-bugs@googlegroups.com, tglx@linutronix.de

syzbot has found a reproducer for the following crash on:

HEAD commit:    4ca559bbdeaf kmsan: fix assertions in IRQ entry/exit hooks.
git tree:       https://github.com/google/kmsan.git/master
console output: https://syzkaller.appspot.com/x/log.txt?x=13dafb20400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=848e40757852af3e
dashboard link: https://syzkaller.appspot.com/bug?extid=adfeaaee641dd4fdac43
compiler:       clang version 7.0.0 (trunk 334104)
syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=15497384400000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=123a42a4400000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+adfeaaee641dd4fdac43@syzkaller.appspotmail.com

RDX: 0000000020000140 RSI: 0000000020000100 RDI: 00000000200000c0
RBP: 0000000000000000 R08: 00000000fffffffc R09: 0000000000000039
R10: 0000000000000311 R11: 0000000000000246 R12: 00007f00bc56bd80
R13: 00000000006dbc38 R14: 0000000000000006 R15: 0079656b5f676962
CPU: 1 PID: 4528 Comm: syz-executor237 Not tainted 4.17.0+ #17
BUG: unable to handle kernel
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
NULL pointer dereference at 0000000000000008
Call Trace:
PGD 800000019f3d5067 P4D 800000019f3d5067
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x185/0x1d0 lib/dump_stack.c:113
PUD 19ce9d067
  fail_dump lib/fault-inject.c:51 [inline]
  should_fail+0x87b/0xab0 lib/fault-inject.c:149
PMD 0
  __should_failslab+0x278/0x2a0 mm/failslab.c:32
Oops: 0000 [#1] SMP PTI
  should_failslab+0x29/0x70 mm/slab_common.c:1522
Dumping ftrace buffer:
  slab_pre_alloc_hook mm/slab.h:423 [inline]
  slab_alloc_node mm/slub.c:2679 [inline]
  __kmalloc_node+0x22f/0x1200 mm/slub.c:3859
    (ftrace buffer empty)
Modules linked in:
CPU: 0 PID: 4533 Comm: syz-executor237 Not tainted 4.17.0+ #17
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:map_vm_area+0x69/0x1f0 mm/vmalloc.c:1353
RSP: 0018:ffff8801c07df8b8 EFLAGS: 00010046
  kmalloc_node include/linux/slab.h:554 [inline]
  alloc_vmap_area+0x1e6/0x15a0 mm/vmalloc.c:420
RAX: ffffffff81b1e4bc RBX: 0000000000000000 RCX: ffff8801a8e58000
RDX: 0000000000000000 RSI: 8000000000000063 RDI: 0000000000000000
  __get_vm_area_node+0x3a6/0x810 mm/vmalloc.c:1410
RBP: ffff8801c07df930 R08: 0000000000000000 R09: 0000000000000000
R10: ffffc900019fffff R11: 0000000000000000 R12: ffffffff8b58d000
  get_vm_area_caller+0xdb/0xf0 mm/vmalloc.c:1456
R13: 0000000000000000 R14: 0000000000000008 R15: 0000000000000000
FS:  00007f00bc56c700(0000) GS:ffff88021fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000008 CR3: 000000019e7d2000 CR4: 00000000001406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
  kmsan_vmap+0x79/0x1e0 mm/kmsan/kmsan.c:875
Call Trace:
  vmap+0x3b2/0x4b0 mm/vmalloc.c:1661
  kmsan_vmap+0x137/0x1e0 mm/kmsan/kmsan.c:888
  vmap+0x3b2/0x4b0 mm/vmalloc.c:1661
  big_key_alloc_buffer+0x638/0xa30 security/keys/big_key.c:188
  big_key_preparse+0x20a/0xed0 security/keys/big_key.c:228
  big_key_alloc_buffer+0x638/0xa30 security/keys/big_key.c:188
  big_key_preparse+0x20a/0xed0 security/keys/big_key.c:228
  key_create_or_update+0x7a6/0x1a80 security/keys/key.c:849
  __do_sys_add_key security/keys/keyctl.c:122 [inline]
  __se_sys_add_key+0x741/0x980 security/keys/keyctl.c:62
  key_create_or_update+0x7a6/0x1a80 security/keys/key.c:849
  __do_sys_add_key security/keys/keyctl.c:122 [inline]
  __se_sys_add_key+0x741/0x980 security/keys/keyctl.c:62
  __x64_sys_add_key+0x15d/0x1b0 security/keys/keyctl.c:62
  __x64_sys_add_key+0x15d/0x1b0 security/keys/keyctl.c:62
  do_syscall_64+0x15b/0x230 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x63/0xe7
  do_syscall_64+0x15b/0x230 arch/x86/entry/common.c:287
RIP: 0033:0x445dc9
  entry_SYSCALL_64_after_hwframe+0x63/0xe7
RSP: 002b:00007f00bc58cd78 EFLAGS: 00000246
RIP: 0033:0x445dc9
RSP: 002b:00007f00bc56bd78 EFLAGS: 00000246
  ORIG_RAX: 00000000000000f8
  ORIG_RAX: 00000000000000f8
RAX: ffffffffffffffda RBX: 00000000006dbc24 RCX: 0000000000445dc9
RAX: ffffffffffffffda RBX: 00000000006dbc3c RCX: 0000000000445dc9
RDX: 0000000020000140 RSI: 0000000020000100 RDI: 00000000200000c0
RDX: 0000000020000140 RSI: 0000000020000100 RDI: 00000000200000c0
RBP: 0000000000000000 R08: 00000000fffffffc R09: 0000000000000039
RBP: 0000000000000000 R08: 00000000fffffffc R09: 0000000000000039
R10: 0000000000000311 R11: 0000000000000246 R12: 00007f00bc56bd80
R13: 00000000006dbc38 R14: 0000000000000006 R15: 0079656b5f676962
R10: 0000000000000311 R11: 0000000000000246 R12: 00007f00bc58cd80
Code:
R13: 00000000006dbc20 R14: 0000000000000005 R15: 0079656b5f676962
24
FAULT_INJECTION: forcing a failure.
name failslab, interval 1, probability 0, space 0, times 0
08 48 89 45 a0 41 8b 84 24 90 0c 00 00 89 45 cc 45 8b bc 24 88 0c 00 00 e8  
54 fa b3 ff 4d 8d 75 08 48 85 db 0f 85 5b 01 00 00 <49> 8b 45 08 48 89 45
CPU: 1 PID: 4530 Comm: syz-executor237 Not tainted 4.17.0+ #17
a8 4c
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
89
Call Trace:
f7 e8
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x185/0x1d0 lib/dump_stack.c:113
57
  fail_dump lib/fault-inject.c:51 [inline]
  should_fail+0x87b/0xab0 lib/fault-inject.c:149
bd
  __should_failslab+0x278/0x2a0 mm/failslab.c:32
0e 00
  should_failslab+0x29/0x70 mm/slab_common.c:1522
4d
  slab_pre_alloc_hook mm/slab.h:423 [inline]
  slab_alloc_node mm/slub.c:2679 [inline]
  __kmalloc_node+0x22f/0x1200 mm/slub.c:3859
8d
75 18
48
RIP: map_vm_area+0x69/0x1f0 mm/vmalloc.c:1353 RSP: ffff8801c07df8b8
  kmalloc_node include/linux/slab.h:554 [inline]
  alloc_vmap_area+0x1e6/0x15a0 mm/vmalloc.c:420
CR2: 0000000000000008
---[ end trace 6c00f5bb0b95940c ]---
  __get_vm_area_node+0x3a6/0x810 mm/vmalloc.c:1410
