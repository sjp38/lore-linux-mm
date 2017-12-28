Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 043B76B0033
	for <linux-mm@kvack.org>; Thu, 28 Dec 2017 04:31:09 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id m9so28588345pff.0
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 01:31:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v7sor1848548pgs.80.2017.12.28.01.31.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Dec 2017 01:31:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <001a113f542a43cb1f05616305fb@google.com>
References: <001a113f542a43cb1f05616305fb@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 28 Dec 2017 10:30:46 +0100
Message-ID: <CACT4Y+bGVNgKd2PDkDgD8T8sWCRh_E5_jEjSr-Fy-vYNbt89nA@mail.gmail.com>
Subject: Re: WARNING in __wake_up_common
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+aa0386edb3e128ffa315@syzkaller.appspotmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, syzkaller-bugs@googlegroups.com, Linux-MM <linux-mm@kvack.org>

On Thu, Dec 28, 2017 at 10:20 AM, syzbot
<syzbot+aa0386edb3e128ffa315@syzkaller.appspotmail.com> wrote:
> Hello,
>
> syzkaller hit the following crash on
> 82bcf1def3b5f1251177ad47c44f7e17af039b4b
> git://git.cmpxchg.org/linux-mmots.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers
>
>
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+aa0386edb3e128ffa315@syzkaller.appspotmail.com
> It will help syzbot understand when the bug is fixed. See footer for
> details.
> If you forward the report, please keep this part and the footer.
>
> audit: type=1400 audit(1513711793.237:7): avc:  denied  { map } for
> pid=3151 comm="syzkaller173649" path="/root/syzkaller173649879" dev="sda1"
> ino=16481 scontext=unconfined_u:system_r:insmod_t:s0-s0:c0.c1023
> tcontext=unconfined_u:object_r:user_home_t:s0 tclass=file permissive=1
> WARNING: CPU: 1 PID: 3151 at kernel/sched/wait.c:79
> __wake_up_common+0x433/0x770 kernel/sched/wait.c:79
> Kernel panic - not syncing: panic_on_warn set ...
>
> CPU: 1 PID: 3151 Comm: syzkaller173649 Not tainted 4.15.0-rc2-mm1+ #39
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:17 [inline]
>  dump_stack+0x194/0x257 lib/dump_stack.c:53
>  panic+0x1e4/0x41c kernel/panic.c:183
>  __warn+0x1dc/0x200 kernel/panic.c:547
>  report_bug+0x211/0x2d0 lib/bug.c:184
>  fixup_bug.part.11+0x37/0x80 arch/x86/kernel/traps.c:177
>  fixup_bug arch/x86/kernel/traps.c:246 [inline]
>  do_error_trap+0x2d7/0x3e0 arch/x86/kernel/traps.c:295
>  do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:314
>  invalid_op+0x22/0x40 arch/x86/entry/entry_64.S:1079
> RIP: 0010:__wake_up_common+0x433/0x770 kernel/sched/wait.c:79
> RSP: 0018:ffff8801c4897648 EFLAGS: 00010246
> RAX: 0000000000000000 RBX: ffff8801d8cbfe50 RCX: 0000000000000004
> RDX: 1ffffffff0c59731 RSI: ffff8801d8cbfe68 RDI: 0000000000000282
> RBP: ffff8801c4897748 R08: ffff8801c4897858 R09: 0000000000000000
> R10: 000000000000000b R11: ffffed0038912e48 R12: 0000000000000000
> R13: ffff8801d8cbfe00 R14: 0000000000000001 R15: ffff8801c4897858
>  __wake_up_locked_key+0x16/0x20 kernel/sched/wait.c:166
>  userfaultfd_release+0x4da/0x750 fs/userfaultfd.c:885
>  __fput+0x333/0x7f0 fs/file_table.c:210
>  ____fput+0x15/0x20 fs/file_table.c:244
>  task_work_run+0x199/0x270 kernel/task_work.c:113
>  exit_task_work include/linux/task_work.h:22 [inline]
>  do_exit+0x9bb/0x1ae0 kernel/exit.c:869
>  do_group_exit+0x149/0x400 kernel/exit.c:972
>  SYSC_exit_group kernel/exit.c:983 [inline]
>  SyS_exit_group+0x1d/0x20 kernel/exit.c:981
>  entry_SYSCALL_64_fastpath+0x1f/0x96
> RIP: 0033:0x43e848
> RSP: 002b:00007ffe33766e08 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
> RAX: ffffffffffffffda RBX: 00000000006ca800 RCX: 000000000043e848
> RDX: 0000000000000000 RSI: 000000000000003c RDI: 0000000000000000
> RBP: 00000000000014b1 R08: 00000000000000e7 R09: ffffffffffffffd0
> R10: 0000000000000006 R11: 0000000000000246 R12: 00000000006ca858
> R13: 00000000006ca858 R14: 0000000000000000 R15: 0000000000002710
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Kernel Offset: disabled
> Rebooting in 86400 seconds..


This was triggered by just creating a userfaultfd, and happened only
in mmots but stopped happening few days ago. I don't see any recent
commits touching useffaultfd.c in mm tree (other than
"mm/userfaultfd.c: remove duplicate include"). Was a bogus commit
dropped from mm tree? Let's close this bug for now and see if it
happens again:

#syz invalid


> ---
> This bug is generated by a dumb bot. It may contain errors.
> See https://goo.gl/tpsmEJ for details.
> Direct all questions to syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report.
> If you forgot to add the Reported-by tag, once the fix for this bug is
> merged
> into any tree, please reply to this email with:
> #syz fix: exact-commit-title
> If you want to test a patch for this bug, please reply with:
> #syz test: git://repo/address.git branch
> and provide the patch inline or as an attachment.
> To mark this as a duplicate of another syzbot report, please reply with:
> #syz dup: exact-subject-of-another-report
> If it's a one-off invalid bug report, please reply with:
> #syz invalid
> Note: if the crash happens again, it will cause creation of a new bug
> report.
> Note: all commands must start from beginning of the line in the email body.
>
> --
> You received this message because you are subscribed to the Google Groups
> "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an
> email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit
> https://groups.google.com/d/msgid/syzkaller-bugs/001a113f542a43cb1f05616305fb%40google.com.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
