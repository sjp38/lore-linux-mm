Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7B20F6B0007
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 06:20:04 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id o66-v6so8285187ita.3
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 03:20:04 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id v62-v6sor3884233itd.42.2018.04.23.03.20.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Apr 2018 03:20:02 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 23 Apr 2018 03:20:02 -0700
Message-ID: <0000000000007cdcf6056a81617f@google.com>
Subject: WARNING: kernel stack regs at         (ptrval) in syz-executor has
 bad 'bp' value         (ptrval)
From: syzbot <syzbot+795f3a2b6f5ad776cc22@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org, hmclauchlan@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pombredanne@nexb.com, syzkaller-bugs@googlegroups.com, tglx@linutronix.de

Hello,

syzbot hit the following crash on upstream commit
5ec83b22a2dd13180762c89698e4e2c2881a423c (Sun Apr 22 19:13:04 2018 +0000)
Merge tag '4.17-rc1-SMB3-CIFS' of git://git.samba.org/sfrench/cifs-2.6
syzbot dashboard link:  
https://syzkaller.appspot.com/bug?extid=795f3a2b6f5ad776cc22

So far this crash happened 2 times on upstream.
Unfortunately, I don't have any reproducer for this crash yet.
Raw console output:  
https://syzkaller.appspot.com/x/log.txt?id=5291662095941632
Kernel config:  
https://syzkaller.appspot.com/x/.config?id=1808800213120130118
compiler: gcc (GCC) 8.0.1 20180413 (experimental)

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+795f3a2b6f5ad776cc22@syzkaller.appspotmail.com
It will help syzbot understand when the bug is fixed. See footer for  
details.
If you forward the report, please keep this part and the footer.

         (ptrval): 0000000000455389 (0x455389)
         (ptrval): 0000000000000033 (0x33)
         (ptrval): 0000000000000246 (0x246)
         (ptrval): 00007f162d156c68 (0x7f162d156c68)
         (ptrval): 000000000000002b (0x2b)
WARNING: kernel stack regs at         (ptrval) in syz-executor0:7766 has  
bad 'bp' value         (ptrval)
binder: 7815:7817 got transaction to invalid handle
binder: 7815:7817 transaction failed 29201/-22, size 0-0 line 2848
binder: undelivered TRANSACTION_ERROR: 29201
binder: 7941:7942 ioctl c018620b 20000000 returned -14
binder: 7941:7942 ioctl c0306201 20000240 returned -14
binder_alloc: binder_alloc_mmap_handler: 7941 20000000-20002000 already  
mapped failed -16
binder: 7941:7951 ioctl c018620b 20000000 returned -14
binder: 7941:7951 ioctl c0306201 20000240 returned -14
FAULT_INJECTION: forcing a failure.
name failslab, interval 1, probability 0, space 0, times 1
CPU: 1 PID: 8218 Comm: syz-executor2 Not tainted 4.17.0-rc1+ #13
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1b9/0x294 lib/dump_stack.c:113
  fail_dump lib/fault-inject.c:51 [inline]
  should_fail.cold.4+0xa/0x1a lib/fault-inject.c:149
  __should_failslab+0x124/0x180 mm/failslab.c:32
  should_failslab+0x9/0x14 mm/slab_common.c:1522
  slab_pre_alloc_hook mm/slab.h:423 [inline]
  slab_alloc mm/slab.c:3378 [inline]
  kmem_cache_alloc_trace+0x2cb/0x780 mm/slab.c:3618
  kmalloc include/linux/slab.h:512 [inline]
  kzalloc include/linux/slab.h:701 [inline]
  alloc_pipe_info+0x16d/0x580 fs/pipe.c:633
  splice_direct_to_actor+0x6e7/0x8d0 fs/splice.c:920
  do_splice_direct+0x2cc/0x400 fs/splice.c:1061
  do_sendfile+0x60f/0xe00 fs/read_write.c:1440
  __do_sys_sendfile64 fs/read_write.c:1495 [inline]
  __se_sys_sendfile64 fs/read_write.c:1487 [inline]
  __x64_sys_sendfile64+0x155/0x240 fs/read_write.c:1487
  do_syscall_64+0x1b1/0x800 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x455389
RSP: 002b:00007fd5ef4adc68 EFLAGS: 00000246 ORIG_RAX: 0000000000000028
RAX: ffffffffffffffda RBX: 00007fd5ef4ae6d4 RCX: 0000000000455389
RDX: 0000000020000140 RSI: 0000000000000013 RDI: 0000000000000014
RBP: 000000000072bea0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000246 R12: 0000000000000015
R13: 00000000000004cf R14: 00000000006fa408 R15: 0000000000000000
FAULT_INJECTION: forcing a failure.
name failslab, interval 1, probability 0, space 0, times 0
CPU: 0 PID: 8252 Comm: syz-executor2 Not tainted 4.17.0-rc1+ #13
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1b9/0x294 lib/dump_stack.c:113
  fail_dump lib/fault-inject.c:51 [inline]
  should_fail.cold.4+0xa/0x1a lib/fault-inject.c:149
  __should_failslab+0x124/0x180 mm/failslab.c:32
  should_failslab+0x9/0x14 mm/slab_common.c:1522
  slab_pre_alloc_hook mm/slab.h:423 [inline]
  slab_alloc mm/slab.c:3378 [inline]
  __do_kmalloc mm/slab.c:3716 [inline]
  __kmalloc+0x2c8/0x760 mm/slab.c:3727
  kmalloc_array include/linux/slab.h:631 [inline]
  kcalloc include/linux/slab.h:642 [inline]
  alloc_pipe_info+0x2a0/0x580 fs/pipe.c:650
  splice_direct_to_actor+0x6e7/0x8d0 fs/splice.c:920
  do_splice_direct+0x2cc/0x400 fs/splice.c:1061
  do_sendfile+0x60f/0xe00 fs/read_write.c:1440
  __do_sys_sendfile64 fs/read_write.c:1495 [inline]
  __se_sys_sendfile64 fs/read_write.c:1487 [inline]
  __x64_sys_sendfile64+0x155/0x240 fs/read_write.c:1487
  do_syscall_64+0x1b1/0x800 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x455389
RSP: 002b:00007fd5ef4adc68 EFLAGS: 00000246 ORIG_RAX: 0000000000000028
RAX: ffffffffffffffda RBX: 00007fd5ef4ae6d4 RCX: 0000000000455389
RDX: 0000000020000140 RSI: 0000000000000013 RDI: 0000000000000014
RBP: 000000000072bea0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000246 R12: 0000000000000015
R13: 00000000000004cf R14: 00000000006fa408 R15: 0000000000000001
FAULT_INJECTION: forcing a failure.
name failslab, interval 1, probability 0, space 0, times 0
CPU: 0 PID: 8283 Comm: syz-executor2 Not tainted 4.17.0-rc1+ #13
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1b9/0x294 lib/dump_stack.c:113
  fail_dump lib/fault-inject.c:51 [inline]
  should_fail.cold.4+0xa/0x1a lib/fault-inject.c:149
  __should_failslab+0x124/0x180 mm/failslab.c:32
  should_failslab+0x9/0x14 mm/slab_common.c:1522
  slab_pre_alloc_hook mm/slab.h:423 [inline]
  slab_alloc_node mm/slab.c:3299 [inline]
  kmem_cache_alloc_node_trace+0x26f/0x770 mm/slab.c:3661
  __do_kmalloc_node mm/slab.c:3681 [inline]
  __kmalloc_node+0x33/0x70 mm/slab.c:3689
  kmalloc_node include/linux/slab.h:554 [inline]
  kvmalloc_node+0x6b/0x100 mm/util.c:421
  kvmalloc include/linux/mm.h:550 [inline]
  kvmalloc_array include/linux/mm.h:566 [inline]
  get_pages_array lib/iov_iter.c:1097 [inline]
  pipe_get_pages_alloc lib/iov_iter.c:1123 [inline]
  iov_iter_get_pages_alloc+0x7be/0x14e0 lib/iov_iter.c:1144
  default_file_splice_read+0x1c7/0xad0 fs/splice.c:390
  do_splice_to+0x12e/0x190 fs/splice.c:880
  splice_direct_to_actor+0x268/0x8d0 fs/splice.c:952
  do_splice_direct+0x2cc/0x400 fs/splice.c:1061
  do_sendfile+0x60f/0xe00 fs/read_write.c:1440
  __do_sys_sendfile64 fs/read_write.c:1495 [inline]
  __se_sys_sendfile64 fs/read_write.c:1487 [inline]
  __x64_sys_sendfile64+0x155/0x240 fs/read_write.c:1487
  do_syscall_64+0x1b1/0x800 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x455389
RSP: 002b:00007fd5ef4adc68 EFLAGS: 00000246 ORIG_RAX: 0000000000000028
RAX: ffffffffffffffda RBX: 00007fd5ef4ae6d4 RCX: 0000000000455389
RDX: 0000000020000140 RSI: 0000000000000013 RDI: 0000000000000014
RBP: 000000000072bea0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000246 R12: 0000000000000015
FAULT_INJECTION: forcing a failure.
name failslab, interval 1, probability 0, space 0, times 0
R13: 00000000000004cf R14: 00000000006fa408 R15: 0000000000000002
CPU: 1 PID: 8308 Comm: syz-executor1 Not tainted 4.17.0-rc1+ #13
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1b9/0x294 lib/dump_stack.c:113
  fail_dump lib/fault-inject.c:51 [inline]
  should_fail.cold.4+0xa/0x1a lib/fault-inject.c:149
  __should_failslab+0x124/0x180 mm/failslab.c:32
  should_failslab+0x9/0x14 mm/slab_common.c:1522
  slab_pre_alloc_hook mm/slab.h:423 [inline]
  slab_alloc_node mm/slab.c:3299 [inline]
  kmem_cache_alloc_node+0x272/0x780 mm/slab.c:3642
  __alloc_skb+0x111/0x780 net/core/skbuff.c:193
FAULT_INJECTION: forcing a failure.
name failslab, interval 1, probability 0, space 0, times 0
  alloc_skb include/linux/skbuff.h:987 [inline]
  netlink_alloc_large_skb net/netlink/af_netlink.c:1182 [inline]
  netlink_sendmsg+0xb01/0xfa0 net/netlink/af_netlink.c:1876
  sock_sendmsg_nosec net/socket.c:629 [inline]
  sock_sendmsg+0xd5/0x120 net/socket.c:639
  ___sys_sendmsg+0x805/0x940 net/socket.c:2117
  __sys_sendmsg+0x115/0x270 net/socket.c:2155
  __do_sys_sendmsg net/socket.c:2164 [inline]
  __se_sys_sendmsg net/socket.c:2162 [inline]
  __x64_sys_sendmsg+0x78/0xb0 net/socket.c:2162
  do_syscall_64+0x1b1/0x800 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x455389
RSP: 002b:00007fd1bb0a4c68 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
RAX: ffffffffffffffda RBX: 00007fd1bb0a56d4 RCX: 0000000000455389
RDX: 0000000000000000 RSI: 0000000020023000 RDI: 0000000000000013
RBP: 000000000072bea0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000014
R13: 00000000000004f8 R14: 00000000006fa7e0 R15: 0000000000000000
CPU: 0 PID: 8314 Comm: syz-executor2 Not tainted 4.17.0-rc1+ #13
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1b9/0x294 lib/dump_stack.c:113
  fail_dump lib/fault-inject.c:51 [inline]
  should_fail.cold.4+0xa/0x1a lib/fault-inject.c:149
  __should_failslab+0x124/0x180 mm/failslab.c:32
  should_failslab+0x9/0x14 mm/slab_common.c:1522
  slab_pre_alloc_hook mm/slab.h:423 [inline]
  slab_alloc_node mm/slab.c:3299 [inline]
  kmem_cache_alloc_node_trace+0x26f/0x770 mm/slab.c:3661
  __do_kmalloc_node mm/slab.c:3681 [inline]
  __kmalloc_node+0x33/0x70 mm/slab.c:3689
  kmalloc_node include/linux/slab.h:554 [inline]
  kvmalloc_node+0x6b/0x100 mm/util.c:421
  kvmalloc include/linux/mm.h:550 [inline]
  seq_buf_alloc fs/seq_file.c:32 [inline]
  seq_read+0xa33/0x1520 fs/seq_file.c:211
  do_loop_readv_writev fs/read_write.c:700 [inline]
  do_iter_read+0x4a3/0x660 fs/read_write.c:924
  vfs_readv+0x14f/0x1a0 fs/read_write.c:986
  kernel_readv fs/splice.c:361 [inline]
  default_file_splice_read+0x514/0xad0 fs/splice.c:416
  do_splice_to+0x12e/0x190 fs/splice.c:880
  splice_direct_to_actor+0x268/0x8d0 fs/splice.c:952
  do_splice_direct+0x2cc/0x400 fs/splice.c:1061
  do_sendfile+0x60f/0xe00 fs/read_write.c:1440
  __do_sys_sendfile64 fs/read_write.c:1495 [inline]
  __se_sys_sendfile64 fs/read_write.c:1487 [inline]
  __x64_sys_sendfile64+0x155/0x240 fs/read_write.c:1487
  do_syscall_64+0x1b1/0x800 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x455389
RSP: 002b:00007fd5ef4adc68 EFLAGS: 00000246 ORIG_RAX: 0000000000000028
RAX: ffffffffffffffda RBX: 00007fd5ef4ae6d4 RCX: 0000000000455389
RDX: 0000000020000140 RSI: 0000000000000013 RDI: 0000000000000014
RBP: 000000000072bea0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000246 R12: 0000000000000015
R13: 00000000000004cf R14: 00000000006fa408 R15: 0000000000000003
FAULT_INJECTION: forcing a failure.
name failslab, interval 1, probability 0, space 0, times 0
CPU: 0 PID: 8340 Comm: syz-executor2 Not tainted 4.17.0-rc1+ #13
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1b9/0x294 lib/dump_stack.c:113
  fail_dump lib/fault-inject.c:51 [inline]
  should_fail.cold.4+0xa/0x1a lib/fault-inject.c:149
FAULT_INJECTION: forcing a failure.
name failslab, interval 1, probability 0, space 0, times 0
  __should_failslab+0x124/0x180 mm/failslab.c:32
  should_failslab+0x9/0x14 mm/slab_common.c:1522
  slab_pre_alloc_hook mm/slab.h:423 [inline]
  slab_alloc mm/slab.c:3378 [inline]
  kmem_cache_alloc_trace+0x4b/0x780 mm/slab.c:3618
  kmalloc include/linux/slab.h:512 [inline]
  __memcg_schedule_kmem_cache_create mm/memcontrol.c:2195 [inline]
  memcg_schedule_kmem_cache_create mm/memcontrol.c:2223 [inline]
  memcg_kmem_get_cache+0x474/0x870 mm/memcontrol.c:2285
  slab_pre_alloc_hook mm/slab.h:428 [inline]
  slab_alloc_node mm/slab.c:3299 [inline]
  kmem_cache_alloc_node_trace+0x1a4/0x770 mm/slab.c:3661
  __do_kmalloc_node mm/slab.c:3681 [inline]
  __kmalloc_node+0x33/0x70 mm/slab.c:3689
  kmalloc_node include/linux/slab.h:554 [inline]
  kvmalloc_node+0x6b/0x100 mm/util.c:421
  kvmalloc include/linux/mm.h:550 [inline]
  seq_buf_alloc fs/seq_file.c:32 [inline]
  seq_read+0xa33/0x1520 fs/seq_file.c:211
  do_loop_readv_writev fs/read_write.c:700 [inline]
  do_iter_read+0x4a3/0x660 fs/read_write.c:924
  vfs_readv+0x14f/0x1a0 fs/read_write.c:986
  kernel_readv fs/splice.c:361 [inline]
  default_file_splice_read+0x514/0xad0 fs/splice.c:416
  do_splice_to+0x12e/0x190 fs/splice.c:880


---
This bug is generated by a dumb bot. It may contain errors.
See https://goo.gl/tpsmEJ for details.
Direct all questions to syzkaller@googlegroups.com.

syzbot will keep track of this bug report.
If you forgot to add the Reported-by tag, once the fix for this bug is  
merged
into any tree, please reply to this email with:
#syz fix: exact-commit-title
To mark this as a duplicate of another syzbot report, please reply with:
#syz dup: exact-subject-of-another-report
If it's a one-off invalid bug report, please reply with:
#syz invalid
Note: if the crash happens again, it will cause creation of a new bug  
report.
Note: all commands must start from beginning of the line in the email body.
