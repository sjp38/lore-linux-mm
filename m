Return-Path: <linux-kernel-owner@vger.kernel.org>
MIME-Version: 1.0
Date: Sun, 01 Apr 2018 10:01:02 -0700
Message-ID: <001a113ff9ca1684ab0568cc6bb6@google.com>
Subject: WARNING in account_page_dirtied
From: syzbot <syzbot+b7772c65a1d88bfd8fca@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org, axboe@kernel.dk, hannes@cmpxchg.org, jack@suse.cz, jlayton@redhat.com, keescook@chromium.org, laoar.shao@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, syzkaller-bugs@googlegroups.com, tytso@mit.edu
List-ID: <linux-mm.kvack.org>

Hello,

syzbot hit the following crash on upstream commit
10b84daddbec72c6b440216a69de9a9605127f7a (Sat Mar 31 17:59:00 2018 +0000)
Merge branch 'perf-urgent-for-linus' of  
git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
syzbot dashboard link:  
https://syzkaller.appspot.com/bug?extid=b7772c65a1d88bfd8fca

C reproducer: https://syzkaller.appspot.com/x/repro.c?id=5705587757154304
syzkaller reproducer:  
https://syzkaller.appspot.com/x/repro.syz?id=5644332530925568
Raw console output:  
https://syzkaller.appspot.com/x/log.txt?id=5472755969425408
Kernel config:  
https://syzkaller.appspot.com/x/.config?id=-2760467897697295172
compiler: gcc (GCC) 7.1.1 20170620

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+b7772c65a1d88bfd8fca@syzkaller.appspotmail.com
It will help syzbot understand when the bug is fixed. See footer for  
details.
If you forward the report, please keep this part and the footer.

gfs2: fsid=loop0.0: jid=0, already locked for use
gfs2: fsid=loop0.0: jid=0: Looking at journal...
gfs2: fsid=loop0.0: jid=0: Done
gfs2: fsid=loop0.0: first mount done, others may mount
gfs2: fsid=loop0.0: found 1 quota changes
WARNING: CPU: 0 PID: 4469 at ./include/linux/backing-dev.h:341 inode_to_wb  
include/linux/backing-dev.h:338 [inline]
WARNING: CPU: 0 PID: 4469 at ./include/linux/backing-dev.h:341  
account_page_dirtied+0x8f9/0xcb0 mm/page-writeback.c:2416
Kernel panic - not syncing: panic_on_warn set ...

CPU: 0 PID: 4469 Comm: syzkaller368843 Not tainted 4.16.0-rc7+ #9
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:17 [inline]
  dump_stack+0x194/0x24d lib/dump_stack.c:53
  panic+0x1e4/0x41c kernel/panic.c:183
  __warn+0x1dc/0x200 kernel/panic.c:547
  report_bug+0x1f4/0x2b0 lib/bug.c:186
  fixup_bug.part.10+0x37/0x80 arch/x86/kernel/traps.c:178
  fixup_bug arch/x86/kernel/traps.c:247 [inline]
  do_error_trap+0x2d7/0x3e0 arch/x86/kernel/traps.c:296
  do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:315
  invalid_op+0x1b/0x40 arch/x86/entry/entry_64.S:986
RIP: 0010:inode_to_wb include/linux/backing-dev.h:338 [inline]
RIP: 0010:account_page_dirtied+0x8f9/0xcb0 mm/page-writeback.c:2416
RSP: 0018:ffff8801d966e5c0 EFLAGS: 00010093
RAX: ffff8801acb7e600 RBX: 1ffff1003b2cdcba RCX: ffffffff818f47a9
RDX: 0000000000000000 RSI: ffff8801d3338148 RDI: 0000000000000082
RBP: ffff8801d966e698 R08: 1ffff1003b2cdc13 R09: 000000000000000c
R10: ffff8801d966e558 R11: 0000000000000002 R12: ffff8801c96f0368
R13: ffffea0006b12780 R14: ffff8801c96f01d8 R15: ffff8801c96f01d8
  __set_page_dirty+0x100/0x4b0 fs/buffer.c:605
  mark_buffer_dirty+0x454/0x5d0 fs/buffer.c:1126
  gfs2_unpin+0x143/0x12c0 fs/gfs2/lops.c:108
  buf_lo_after_commit+0x273/0x430 fs/gfs2/lops.c:512
  lops_after_commit fs/gfs2/lops.h:67 [inline]
  gfs2_log_flush+0xe2a/0x2750 fs/gfs2/log.c:809
  do_sync+0x666/0xe40 fs/gfs2/quota.c:958
  gfs2_quota_sync+0x2cc/0x570 fs/gfs2/quota.c:1301
  gfs2_sync_fs+0x46/0xb0 fs/gfs2/super.c:956
  __sync_filesystem fs/sync.c:39 [inline]
  sync_filesystem+0x188/0x2e0 fs/sync.c:64
  generic_shutdown_super+0xd5/0x540 fs/super.c:425
  kill_block_super+0x9b/0xf0 fs/super.c:1146
  gfs2_kill_sb+0x133/0x1b0 fs/gfs2/ops_fstype.c:1392
  deactivate_locked_super+0x88/0xd0 fs/super.c:312
  deactivate_super+0x141/0x1b0 fs/super.c:343
  cleanup_mnt+0xb2/0x150 fs/namespace.c:1173
  __cleanup_mnt+0x16/0x20 fs/namespace.c:1180
  task_work_run+0x199/0x270 kernel/task_work.c:113
  exit_task_work include/linux/task_work.h:22 [inline]
  do_exit+0x9bb/0x1ad0 kernel/exit.c:865
  do_group_exit+0x149/0x400 kernel/exit.c:968
  SYSC_exit_group kernel/exit.c:979 [inline]
  SyS_exit_group+0x1d/0x20 kernel/exit.c:977
  do_syscall_64+0x281/0x940 arch/x86/entry/common.c:287
  entry_SYSCALL_64_after_hwframe+0x42/0xb7
RIP: 0033:0x456c29
RSP: 002b:00007fff74938dc8 EFLAGS: 00000202 ORIG_RAX: 00000000000000e7
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 0000000000456c29
RDX: 00000000004170e0 RSI: 0000000000000000 RDI: 0000000000000001
RBP: 0000000000000003 R08: 000000000000000a R09: 0000000000418100
R10: 00000000200a9300 R11: 0000000000000202 R12: 0000000000000004
R13: 0000000000418100 R14: 0000000000000000 R15: 0000000000000000
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
