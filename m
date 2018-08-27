Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A8ED06B427E
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 17:05:11 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id n17-v6so199564pff.17
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 14:05:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s20-v6sor110296plp.3.2018.08.27.14.05.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Aug 2018 14:05:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <000000000000e5050205746dcbb0@google.com>
References: <000000000000e5050205746dcbb0@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 27 Aug 2018 14:04:49 -0700
Message-ID: <CACT4Y+bzwSJ1mtFe5qTmKF18CvZF3E4Z8rETGjbKe7UN6VO_5A@mail.gmail.com>
Subject: Re: INFO: rcu detected stall in snd_seq_write
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+97aae04ce27e39cbfca9@syzkaller.appspotmail.com>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>, alsa-devel@alsa-project.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>, jrdr.linux@gmail.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, ldufour@linux.vnet.ibm.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, riel@surriel.com, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, ying.huang@intel.com, zwisler@kernel.org

On Mon, Aug 27, 2018 at 10:10 AM, syzbot
<syzbot+97aae04ce27e39cbfca9@syzkaller.appspotmail.com> wrote:
> Hello,
>
> syzbot found the following crash on:
>
> HEAD commit:    e27bc174c9c6 Add linux-next specific files for 20180824
> git tree:       linux-next
> console output: https://syzkaller.appspot.com/x/log.txt?x=16e0823e400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=28446088176757ea
> dashboard link: https://syzkaller.appspot.com/bug?extid=97aae04ce27e39cbfca9
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=1756c50e400000


This seems to have been attributed to some x86 file, I will take a
look as to why.
+ALSA maintainers


> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+97aae04ce27e39cbfca9@syzkaller.appspotmail.com
>
> 8021q: adding VLAN 0 to HW filter on device team0
> 8021q: adding VLAN 0 to HW filter on device team0
> 8021q: adding VLAN 0 to HW filter on device team0
> 8021q: adding VLAN 0 to HW filter on device team0
> 8021q: adding VLAN 0 to HW filter on device team0
> rcu: INFO: rcu_sched self-detected stall on CPU
> rcu:    0-....: (105000 ticks this GP) idle=2f6/1/0x4000000000000002
> softirq=23001/23001 fqs=26239
> rcu:     (t=105008 jiffies g=49145 q=2382)
> NMI backtrace for cpu 0
> CPU: 0 PID: 8551 Comm: syz-executor7 Not tainted 4.18.0-next-20180824+ #47
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>  <IRQ>
>  __dump_stack lib/dump_stack.c:77 [inline]
>  dump_stack+0x1c9/0x2b4 lib/dump_stack.c:113
>  nmi_cpu_backtrace.cold.3+0x48/0x88 lib/nmi_backtrace.c:101
>  nmi_trigger_cpumask_backtrace+0x151/0x192 lib/nmi_backtrace.c:62
>  arch_trigger_cpumask_backtrace+0x14/0x20 arch/x86/kernel/apic/hw_nmi.c:38
>  trigger_single_cpu_backtrace include/linux/nmi.h:162 [inline]
>  rcu_dump_cpu_stacks+0x175/0x1c2 kernel/rcu/tree.c:1340
>  print_cpu_stall.cold.78+0x2fb/0x59c kernel/rcu/tree.c:1478
>  check_cpu_stall kernel/rcu/tree.c:1550 [inline]
>  __rcu_pending kernel/rcu/tree.c:3276 [inline]
>  rcu_pending kernel/rcu/tree.c:3319 [inline]
>  rcu_check_callbacks+0xd4a/0x15a0 kernel/rcu/tree.c:2665
>  update_process_times+0x2d/0x70 kernel/time/timer.c:1636
>  tick_sched_handle+0x9f/0x180 kernel/time/tick-sched.c:164
>  tick_sched_timer+0x45/0x130 kernel/time/tick-sched.c:1274
>  __run_hrtimer kernel/time/hrtimer.c:1398 [inline]
>  __hrtimer_run_queues+0x3eb/0xff0 kernel/time/hrtimer.c:1460
>  hrtimer_interrupt+0x2f3/0x750 kernel/time/hrtimer.c:1518
>  local_apic_timer_interrupt arch/x86/kernel/apic/apic.c:1029 [inline]
>  smp_apic_timer_interrupt+0x16d/0x6a0 arch/x86/kernel/apic/apic.c:1054
>  apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:867
>  </IRQ>
> RIP: 0010:lock_release+0xa2/0x9f0 kernel/locking/lockdep.c:3910
> Code: f2 c7 40 08 f2 f2 f2 f2 c7 40 0c 00 f2 f2 f2 c7 40 10 f2 f2 f2 f2 c7
> 40 14 00 f2 f2 f2 65 48 8b 04 25 28 00 00 00 48 89 45 d0 <31> c0 48 89 f8 48
> c1 e8 03 0f b6 14 10 48 89 f8 83 e0 07 83 c0 03
> RSP: 0018:ffff8801aa0078c8 EFLAGS: 00000292 ORIG_RAX: ffffffffffffff13
> RAX: 2ec5cd2493d34200 RBX: 1ffff10035400f1e RCX: 0000000000000000
> RDX: dffffc0000000000 RSI: 0000000000000000 RDI: ffff8801a9b56bbc
> RBP: ffff8801aa0079f8 R08: 00000000000010df R09: 0000000000000001
> R10: ffff8801a9b56be8 R11: 737c3e5c87308161 R12: ffff8801aa0079d0
> R13: ffff8801c778d4c8 R14: ffff8801aa007ae0 R15: ffff8801a9b56380
>  __might_fault+0x19e/0x1e0 mm/memory.c:4585
>  _copy_from_user+0x30/0x150 lib/usercopy.c:10
>  copy_from_user include/linux/uaccess.h:147 [inline]
>  snd_seq_write+0x472/0x8d0 sound/core/seq/seq_clientmgr.c:1033
>  __vfs_write+0x117/0x9d0 fs/read_write.c:485
>  vfs_write+0x1fc/0x560 fs/read_write.c:549
>  ksys_write+0x101/0x260 fs/read_write.c:598
>  __do_sys_write fs/read_write.c:610 [inline]
>  __se_sys_write fs/read_write.c:607 [inline]
>  __x64_sys_write+0x73/0xb0 fs/read_write.c:607
>  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x457089
> Code: fd b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7
> 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff
> 0f 83 cb b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00
> RSP: 002b:00007f09af65dc78 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
> RAX: ffffffffffffffda RBX: 00007f09af65e6d4 RCX: 0000000000457089
> RDX: 00000000ffffff76 RSI: 0000000020000000 RDI: 0000000000000003
> RBP: 00000000009300a0 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000246 R12: 00000000ffffffff
> R13: 00000000004d78a8 R14: 00000000004ca886 R15: 0000000000000000
>
>
> ---
> This bug is generated by a bot. It may contain errors.
> See https://goo.gl/tpsmEJ for more information about syzbot.
> syzbot engineers can be reached at syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report. See:
> https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with
> syzbot.
> syzbot can test patches for this bug, for details see:
> https://goo.gl/tpsmEJ#testing-patches
>
> --
> You received this message because you are subscribed to the Google Groups
> "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an
> email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit
> https://groups.google.com/d/msgid/syzkaller-bugs/000000000000e5050205746dcbb0%40google.com.
> For more options, visit https://groups.google.com/d/optout.
