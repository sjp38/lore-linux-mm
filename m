Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1594D6B0033
	for <linux-mm@kvack.org>; Sun,  3 Dec 2017 09:36:56 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id h1so6801468plh.23
        for <linux-mm@kvack.org>; Sun, 03 Dec 2017 06:36:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n10sor825120pgc.108.2017.12.03.06.36.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Dec 2017 06:36:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <94eb2c03c9bc75aff2055f70734c@google.com>
References: <94eb2c03c9bc75aff2055f70734c@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 3 Dec 2017 15:36:33 +0100
Message-ID: <CACT4Y+bGNU1WkyHW3nNBg49rhg8uN1j0sA0DxRj5cmZOSmsWSQ@mail.gmail.com>
Subject: Re: BUG: workqueue lockup (2)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+e38be687a2450270a3b593bacb6b5795a7a74edb@syzkaller.appspotmail.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Philippe Ombredanne <pombredanne@nexb.com>, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>

On Sun, Dec 3, 2017 at 3:31 PM, syzbot
<bot+e38be687a2450270a3b593bacb6b5795a7a74edb@syzkaller.appspotmail.com>
wrote:
> Hello,
>
> syzkaller hit the following crash on
> 2db767d9889cef087149a5eaa35c1497671fa40f
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
>
> Unfortunately, I don't have any reproducer for this bug yet.
>
>
> BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 48s!
> BUG: workqueue lockup - pool cpus=0-1 flags=0x4 nice=0 stuck for 47s!
> Showing busy workqueues and worker pools:
> workqueue events: flags=0x0
>   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=4/256
>     pending: perf_sched_delayed, vmstat_shepherd, jump_label_update_timeout,
> cache_reap
> workqueue events_power_efficient: flags=0x80
>   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=4/256
>     pending: neigh_periodic_work, neigh_periodic_work, do_cache_clean,
> reg_check_chans_work
> workqueue mm_percpu_wq: flags=0x8
>   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
>     pending: vmstat_update
> workqueue writeback: flags=0x4e
>   pwq 4: cpus=0-1 flags=0x4 nice=0 active=1/256
>     in-flight: 3401:wb_workfn
> workqueue kblockd: flags=0x18
>   pwq 1: cpus=0 node=0 flags=0x0 nice=-20 active=1/256
>     pending: blk_mq_timeout_work
> pool 4: cpus=0-1 flags=0x4 nice=0 hung=0s workers=11 idle: 3423 4249 92 21


This error report does not look actionable. Perhaps if code that
detect it would dump cpu/task stacks, it would be actionable.


> 3549 34 4803 5 4243 3414
> audit: type=1326 audit(1512291140.021:615): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=7002 comm="syz-executor7"
> exe="/root/syz-executor7" sig=0 arch=c000003e syscall=202 compat=0
> ip=0x4529d9 code=0x7ffc0000
> audit: type=1326 audit(1512291140.044:616): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=7002 comm="syz-executor7"
> exe="/root/syz-executor7" sig=0 arch=c000003e syscall=202 compat=0
> ip=0x4529d9 code=0x7ffc0000
> audit: type=1326 audit(1512291140.045:617): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=7002 comm="syz-executor7"
> exe="/root/syz-executor7" sig=0 arch=c000003e syscall=55 compat=0
> ip=0x4529d9 code=0x7ffc0000
> audit: type=1326 audit(1512291140.045:618): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=7002 comm="syz-executor7"
> exe="/root/syz-executor7" sig=0 arch=c000003e syscall=202 compat=0
> ip=0x4529d9 code=0x7ffc0000
> audit: type=1326 audit(1512291140.045:619): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=7002 comm="syz-executor7"
> exe="/root/syz-executor7" sig=0 arch=c000003e syscall=202 compat=0
> ip=0x4529d9 code=0x7ffc0000
> audit: type=1326 audit(1512291140.047:620): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=7002 comm="syz-executor7"
> exe="/root/syz-executor7" sig=0 arch=c000003e syscall=257 compat=0
> ip=0x4529d9 code=0x7ffc0000
> audit: type=1326 audit(1512291140.047:621): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=7002 comm="syz-executor7"
> exe="/root/syz-executor7" sig=0 arch=c000003e syscall=202 compat=0
> ip=0x4529d9 code=0x7ffc0000
> audit: type=1326 audit(1512291140.047:622): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=7002 comm="syz-executor7"
> exe="/root/syz-executor7" sig=0 arch=c000003e syscall=202 compat=0
> ip=0x4529d9 code=0x7ffc0000
> audit: type=1326 audit(1512291140.048:623): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=7002 comm="syz-executor7"
> exe="/root/syz-executor7" sig=0 arch=c000003e syscall=16 compat=0
> ip=0x4529d9 code=0x7ffc0000
> audit: type=1326 audit(1512291140.049:624): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=7002 comm="syz-executor7"
> exe="/root/syz-executor7" sig=0 arch=c000003e syscall=202 compat=0
> ip=0x4529d9 code=0x7ffc0000
> netlink: 2 bytes leftover after parsing attributes in process
> `syz-executor2'.
> netlink: 2 bytes leftover after parsing attributes in process
> `syz-executor2'.
> netlink: 17 bytes leftover after parsing attributes in process
> `syz-executor7'.
> device gre0 entered promiscuous mode
> device gre0 entered promiscuous mode
> could not allocate digest TFM handle [vmnet1%
> could not allocate digest TFM handle [vmnet1%
> SELinux: unrecognized netlink message: protocol=0 nlmsg_type=7
> sclass=netlink_route_socket pig=7627 comm=syz-executor3
> sock: sock_set_timeout: `syz-executor6' (pid 7625) tries to set negative
> timeout
> Can not set IPV6_FL_F_REFLECT if flowlabel_consistency sysctl is enable
> SELinux: unrecognized netlink message: protocol=0 nlmsg_type=0
> sclass=netlink_route_socket pig=7648 comm=syz-executor3
> sock: sock_set_timeout: `syz-executor6' (pid 7625) tries to set negative
> timeout
> Can not set IPV6_FL_F_REFLECT if flowlabel_consistency sysctl is enable
> SELinux: unrecognized netlink message: protocol=0 nlmsg_type=7
> sclass=netlink_route_socket pig=7648 comm=syz-executor3
> SELinux: unrecognized netlink message: protocol=0 nlmsg_type=0
> sclass=netlink_route_socket pig=7627 comm=syz-executor3
> Can not set IPV6_FL_F_REFLECT if flowlabel_consistency sysctl is enable
> Can not set IPV6_FL_F_REFLECT if flowlabel_consistency sysctl is enable
> netlink: 4 bytes leftover after parsing attributes in process
> `syz-executor3'.
> netlink: 4 bytes leftover after parsing attributes in process
> `syz-executor3'.
> netlink: 1 bytes leftover after parsing attributes in process
> `syz-executor3'.
> QAT: Invalid ioctl
> netlink: 1 bytes leftover after parsing attributes in process
> `syz-executor3'.
> QAT: Invalid ioctl
> FAULT_INJECTION: forcing a failure.
> name failslab, interval 1, probability 0, space 0, times 1
> CPU: 1 PID: 7838 Comm: syz-executor4 Not tainted 4.15.0-rc1+ #205
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:17 [inline]
>  dump_stack+0x194/0x257 lib/dump_stack.c:53
>  fail_dump lib/fault-inject.c:51 [inline]
>  should_fail+0x8c0/0xa40 lib/fault-inject.c:149
>  should_failslab+0xec/0x120 mm/failslab.c:32
>  slab_pre_alloc_hook mm/slab.h:421 [inline]
>  slab_alloc mm/slab.c:3371 [inline]
>  __do_kmalloc mm/slab.c:3709 [inline]
>  __kmalloc_track_caller+0x5f/0x760 mm/slab.c:3726
>  memdup_user+0x2c/0x90 mm/util.c:164
>  msr_io+0xec/0x3b0 arch/x86/kvm/x86.c:2650
>  kvm_arch_vcpu_ioctl+0x31d/0x4710 arch/x86/kvm/x86.c:3566
>  kvm_vcpu_ioctl+0x240/0x1010 arch/x86/kvm/../../../virt/kvm/kvm_main.c:2726
>  vfs_ioctl fs/ioctl.c:46 [inline]
>  do_vfs_ioctl+0x1b1/0x1530 fs/ioctl.c:686
>  SYSC_ioctl fs/ioctl.c:701 [inline]
>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:692
>  entry_SYSCALL_64_fastpath+0x1f/0x96
> RIP: 0033:0x4529d9
> RSP: 002b:00007fd7722d4c58 EFLAGS: 00000212 ORIG_RAX: 0000000000000010
> RAX: ffffffffffffffda RBX: 00007fd7722d4aa0 RCX: 00000000004529d9
> RDX: 0000000020002000 RSI: 000000004008ae89 RDI: 0000000000000016
> RBP: 00007fd7722d4a90 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000212 R12: 00000000004b759b
> R13: 00007fd7722d4bc8 R14: 00000000004b759b R15: 0000000000000000
> device lo left promiscuous mode
> device lo entered promiscuous mode
> device lo left promiscuous mode
> kvm_hv_set_msr: 127 callbacks suppressed
> kvm [8010]: vcpu0, guest rIP: 0x9112 Hyper-V uhandled wrmsr: 0x4000008e data
> 0x47
> kvm [8010]: vcpu0, guest rIP: 0x9112 Hyper-V uhandled wrmsr: 0x4000008c data
> 0x47
> kvm [8010]: vcpu0, guest rIP: 0x9112 Hyper-V uhandled wrmsr: 0x4000008a data
> 0x47
> kvm [8010]: vcpu0, guest rIP: 0x9112 Hyper-V uhandled wrmsr: 0x40000088 data
> 0x47
> kvm [8010]: vcpu0, guest rIP: 0x9112 Hyper-V uhandled wrmsr: 0x40000086 data
> 0x47
> program syz-executor2 is using a deprecated SCSI ioctl, please convert it to
> SG_IO
> sd 0:0:1:0: ioctl_internal_command: ILLEGAL REQUEST asc=0x20 ascq=0x0
> program syz-executor2 is using a deprecated SCSI ioctl, please convert it to
> SG_IO
> sd 0:0:1:0: ioctl_internal_command: ILLEGAL REQUEST asc=0x20 ascq=0x0
> netlink: 2 bytes leftover after parsing attributes in process
> `syz-executor5'.
> program syz-executor2 is using a deprecated SCSI ioctl, please convert it to
> SG_IO
> sd 0:0:1:0: ioctl_internal_command: ILLEGAL REQUEST asc=0x20 ascq=0x0
> netlink: 2 bytes leftover after parsing attributes in process
> `syz-executor5'.
> program syz-executor2 is using a deprecated SCSI ioctl, please convert it to
> SG_IO
> sd 0:0:1:0: ioctl_internal_command: ILLEGAL REQUEST asc=0x20 ascq=0x0
> kauditd_printk_skb: 264 callbacks suppressed
> audit: type=1326 audit(1512291148.643:889): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=8160 comm="syz-executor5"
> exe="/root/syz-executor5" sig=0 arch=c000003e syscall=202 compat=0
> ip=0x4529d9 code=0x7ffc0000
> audit: type=1326 audit(1512291148.643:890): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=8160 comm="syz-executor5"
> exe="/root/syz-executor5" sig=0 arch=c000003e syscall=202 compat=0
> ip=0x4529d9 code=0x7ffc0000
> audit: type=1326 audit(1512291148.643:891): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=8160 comm="syz-executor5"
> exe="/root/syz-executor5" sig=0 arch=c000003e syscall=22 compat=0
> ip=0x4529d9 code=0x7ffc0000
> audit: type=1326 audit(1512291148.650:892): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=8160 comm="syz-executor5"
> exe="/root/syz-executor5" sig=0 arch=c000003e syscall=202 compat=0
> ip=0x4529d9 code=0x7ffc0000
> audit: type=1326 audit(1512291148.650:893): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=8160 comm="syz-executor5"
> exe="/root/syz-executor5" sig=0 arch=c000003e syscall=54 compat=0
> ip=0x4529d9 code=0x7ffc0000
> audit: type=1326 audit(1512291148.650:894): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=8160 comm="syz-executor5"
> exe="/root/syz-executor5" sig=0 arch=c000003e syscall=202 compat=0
> ip=0x4529d9 code=0x7ffc0000
> audit: type=1326 audit(1512291148.650:895): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=8160 comm="syz-executor5"
> exe="/root/syz-executor5" sig=0 arch=c000003e syscall=298 compat=0
> ip=0x4529d9 code=0x7ffc0000
> audit: type=1326 audit(1512291148.672:896): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=8160 comm="syz-executor5"
> exe="/root/syz-executor5" sig=0 arch=c000003e syscall=202 compat=0
> ip=0x4529d9 code=0x7ffc0000
> audit: type=1326 audit(1512291148.705:897): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=8160 comm="syz-executor5"
> exe="/root/syz-executor5" sig=0 arch=c000003e syscall=2 compat=0 ip=0x40cd11
> code=0x7ffc0000
> audit: type=1326 audit(1512291148.705:898): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=8160 comm="syz-executor5"
> exe="/root/syz-executor5" sig=0 arch=c000003e syscall=202 compat=0
> ip=0x4529d9 code=0x7ffc0000
> QAT: Invalid ioctl
> QAT: Invalid ioctl
>
>
> ---
> This bug is generated by a dumb bot. It may contain errors.
> See https://goo.gl/tpsmEJ for details.
> Direct all questions to syzkaller@googlegroups.com.
> Please credit me with: Reported-by: syzbot <syzkaller@googlegroups.com>
>
> syzbot will keep track of this bug report.
> Once a fix for this bug is committed, please reply to this email with:
> #syz fix: exact-commit-title
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
> https://groups.google.com/d/msgid/syzkaller-bugs/94eb2c03c9bc75aff2055f70734c%40google.com.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
