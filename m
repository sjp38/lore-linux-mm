Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 44AB96B0005
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 06:36:54 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 33so69639004lfw.1
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 03:36:54 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id b4si56007wjh.22.2016.07.15.03.36.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 03:36:52 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id q128so1754629wma.1
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 03:36:52 -0700 (PDT)
From: Topi Miettinen <toiwoton@gmail.com>
Subject: [PATCH 00/14] Present useful limits to user (v2)
Date: Fri, 15 Jul 2016 13:35:47 +0300
Message-Id: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Topi Miettinen <toiwoton@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Alexander Graf <agraf@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "maintainer:X86 ARCHITECTURE 32-BIT AND 64-BIT" <x86@kernel.org>, Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>, Dave Goodell <dgoodell@cisco.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Alex Williamson <alex.williamson@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Alexei Starovoitov <ast@kernel.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Balbir Singh <bsingharora@gmail.com>, Markus Elfring <elfring@users.sourceforge.net>, "David S. Miller" <davem@davemloft.net>, Nicolas Dichtel <nicolas.dichtel@6wind.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Jiri Slaby <jslaby@suse.cz>, Cyrill Gorcunov <gorcunov@openvz.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Carpenter <dan.carpenter@oracle.com>, Michael Kerrisk <mtk.manpages@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Marcus Gelderie <redmnic@gmail.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Joe Perches <joe@perches.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andi Kleen <ak@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Stas Sergeev <stsp@list.ru>, Amanieu d'Antras <amanieu@gmail.com>, Richard Weinberger <richard@nod.at>, Wang Xiaoqiang <wangxq10@lzu.edu.cn>, Helge Deller <deller@gmx.de>, Mateusz Guzik <mguzik@redhat.com>, Alex Thorlton <athorlton@sgi.com>, Ben Segall <bsegall@google.com>, John Stultz <john.stultz@linaro.org>, Rik van Riel <riel@redhat.com>, Eric B Munson <emunson@akamai.com>, Alexey Klimov <klimov.linux@gmail.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:IA64 Itanium PLATFORM" <linux-ia64@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE KVM FOR POWERPC" <kvm-ppc@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE KVM" <kvm@vger.kernel.org>, "open list:LINUX FOR POWERPC 32-BIT AND 64-BIT" <linuxppc-dev@lists.ozlabs.org>, "open list:INFINIBAND SUBSYSTEM" <linux-rdma@vger.kernel.org>, "open list:FILESYSTEMS VFS and infrastructure" <linux-fsdevel@vger.kernel.org>, "open list:CONTROL GROUP CGROUP" <cgroups@vger.kernel.org>, "open list:BPF Safe dynamic programs and tools" <netdev@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Hello,

There are many basic ways to control processes, including capabilities,
cgroups and resource limits. However, there are far fewer ways to find out
useful values for the limits, except blind trial and error.

This patch series attempts to fix that by giving at least a nice starting
point from the highwater mark values of the resources in question.
I looked where each limit is checked and added a call to update the mark
nearby.

Example run of program from Documentation/accounting/getdelauys.c:

./getdelays -R -p `pidof smartd`
printing resource accounting
RLIMIT_CPU=0
RLIMIT_FSIZE=0
RLIMIT_DATA=18198528
RLIMIT_STACK=135168
RLIMIT_CORE=0
RLIMIT_RSS=0
RLIMIT_NPROC=1
RLIMIT_NOFILE=55
RLIMIT_MEMLOCK=0
RLIMIT_AS=130879488
RLIMIT_LOCKS=0
RLIMIT_SIGPENDING=0
RLIMIT_MSGQUEUE=0
RLIMIT_NICE=0
RLIMIT_RTPRIO=0
RLIMIT_RTTIME=0

./getdelays -R -C /sys/fs/cgroup/systemd/system.slice/smartd.service/
printing resource accounting
sleeping 1, blocked 0, running 0, stopped 0, uninterruptible 0
RLIMIT_CPU=0
RLIMIT_FSIZE=0
RLIMIT_DATA=18198528
RLIMIT_STACK=135168
RLIMIT_CORE=0
RLIMIT_RSS=0
RLIMIT_NPROC=1
RLIMIT_NOFILE=55
RLIMIT_MEMLOCK=0
RLIMIT_AS=130879488
RLIMIT_LOCKS=0
RLIMIT_SIGPENDING=0
RLIMIT_MSGQUEUE=0
RLIMIT_NICE=0
RLIMIT_RTPRIO=0
RLIMIT_RTTIME=0

In this example, smartd is running as a non-root user. The presented
values can be used as a starting point for giving new limits to the
service.

There's one problem with the patch 07/13, kernel initialization calls
create_worker() which seems to use different locking model or something:

[    0.145410] =========================================================
[    0.148000] [ INFO: possible irq lock inversion dependency detected ]
[    0.148000] 4.7.0-rc7+ #155 Not tainted
[    0.148000] ---------------------------------------------------------
[    0.148000] swapper/0/1 just changed the state of lock:
[    0.148000]  (&(&(&sig->stats_lock)->lock)->rlock){+.....}, at: [<ffffffff810bf769>] __sched_setscheduler+0x339/0xbd0
[    0.148000] but this lock was taken by another, HARDIRQ-safe lock in the past:
[    0.148000]  (&rq->lock){-.....}

and interrupts could create inverse lock ordering between them.

[    0.148000] 
[    0.148000] other info that might help us debug this:
[    0.148000]  Possible interrupt unsafe locking scenario:
[    0.148000] 
[    0.148000]        CPU0                    CPU1
[    0.148000]        ----                    ----
[    0.148000]   lock(&(&(&sig->stats_lock)->lock)->rlock);
[    0.148000]                                local_irq_disable();
[    0.148000]                                lock(&rq->lock);
[    0.148000]                                lock(&(&(&sig->stats_lock)->lock)->rlock);
[    0.148000]   <Interrupt>
[    0.148000]     lock(&rq->lock);
[    0.148000] 
[    0.148000]  *** DEADLOCK ***
[    0.148000] 
[    0.148000] 2 locks held by swapper/0/1:
[    0.148000]  #0:  (cpu_hotplug.lock){.+.+.+}, at: [<ffffffff81092824>] get_online_cpus+0x24/0x70
[    0.148000]  #1:  (smpboot_threads_lock){+.+.+.}, at: [<ffffffff810ba517>] smpboot_register_percpu_thread_cpumask+0x37/0xf0
[    0.148000] 
[    0.148000] the shortest dependencies between 2nd lock and 1st lock:
[    0.148000]  -> (&rq->lock){-.....} ops: 181 {
[    0.148000]     IN-HARDIRQ-W at:
[    0.148000]                       [<ffffffff810e8439>] __lock_acquire+0x6e9/0x1440
[    0.148000]                       [<ffffffff810e95d3>] lock_acquire+0xe3/0x1c0
[    0.148000]                       [<ffffffff818cf661>] _raw_spin_lock+0x31/0x40
[    0.148000]                       [<ffffffff810c3a41>] scheduler_tick+0x41/0xd0
[    0.148000]                       [<ffffffff81110471>] update_process_times+0x51/0x60
[    0.148000]                       [<ffffffff8111fa4f>] tick_periodic+0x2f/0xc0
[    0.148000]                       [<ffffffff8111fb05>] tick_handle_periodic+0x25/0x70
[    0.148000]                       [<ffffffff8101ebf5>] timer_interrupt+0x15/0x20
[    0.148000]                       [<ffffffff810fc731>] handle_irq_event_percpu+0x41/0x320
[    0.148000]                       [<ffffffff810fca49>] handle_irq_event+0x39/0x60
[    0.148000]                       [<ffffffff810ffe08>] handle_level_irq+0x88/0x110
[    0.148000]                       [<ffffffff8101e58a>] handle_irq+0x1a/0x30
[    0.148000]                       [<ffffffff818d2281>] do_IRQ+0x61/0x120
[    0.148000]                       [<ffffffff818d0949>] ret_from_intr+0x0/0x19
[    0.148000]                       [<ffffffff810fe969>] __setup_irq+0x3f9/0x5e0
[    0.148000]                       [<ffffffff810feb96>] setup_irq+0x46/0xa0
[    0.148000]                       [<ffffffff821878e2>] setup_default_timer_irq+0x1e/0x20
[    0.148000]                       [<ffffffff821878fb>] hpet_time_init+0x17/0x19
[    0.148000]                       [<ffffffff821878bd>] x86_late_time_init+0xa/0x11
[    0.148000]                       [<ffffffff82181ef9>] start_kernel+0x39d/0x465
[    0.148000]                       [<ffffffff82181294>] x86_64_start_reservations+0x2f/0x31
[    0.148000]                       [<ffffffff8218140e>] x86_64_start_kernel+0x178/0x18b
[    0.148000]     INITIAL USE at:
[    0.148000]                      [<ffffffff810e7f90>] __lock_acquire+0x240/0x1440
[    0.148000]                      [<ffffffff810e95d3>] lock_acquire+0xe3/0x1c0
[    0.148000]                      [<ffffffff818cf82c>] _raw_spin_lock_irqsave+0x3c/0x50
[    0.148000]                      [<ffffffff810bdc9d>] rq_attach_root+0x1d/0x100
[    0.148000]                      [<ffffffff8219deab>] sched_init+0x2f5/0x44c
[    0.148000]                      [<ffffffff82181d9d>] start_kernel+0x241/0x465
[    0.148000]                      [<ffffffff82181294>] x86_64_start_reservations+0x2f/0x31
[    0.148000]                      [<ffffffff8218140e>] x86_64_start_kernel+0x178/0x18b
[    0.148000]   }
[    0.148000]   ... key      at: [<ffffffff822f3ad0>] __key.60059+0x0/0x8
[    0.148000]   ... acquired at:
[    0.148000]    [<ffffffff810e95d3>] lock_acquire+0xe3/0x1c0
[    0.148000]    [<ffffffff818cf661>] _raw_spin_lock+0x31/0x40
[    0.148000]    [<ffffffff810c0514>] set_user_nice.part.92+0xf4/0x270
[    0.148000]    [<ffffffff810c06b6>] set_user_nice+0x26/0x30
[    0.148000]    [<ffffffff810aee10>] create_worker+0xf0/0x1a0
[    0.148000]    [<ffffffff8219c195>] init_workqueues+0x317/0x51e
[    0.148000]    [<ffffffff81000450>] do_one_initcall+0x50/0x180
[    0.148000]    [<ffffffff821820d2>] kernel_init_freeable+0x111/0x25d
[    0.148000]    [<ffffffff818c206e>] kernel_init+0xe/0x100
[    0.148000]    [<ffffffff818d01ff>] ret_from_fork+0x1f/0x40
[    0.148000] 
[    0.148000] -> (&(&(&sig->stats_lock)->lock)->rlock){+.....} ops: 2 {
[    0.148000]    HARDIRQ-ON-W at:
[    0.148000]                     [<ffffffff810e82e0>] __lock_acquire+0x590/0x1440
[    0.148000]                     [<ffffffff810e95d3>] lock_acquire+0xe3/0x1c0
[    0.148000]                     [<ffffffff818cf661>] _raw_spin_lock+0x31/0x40
[    0.148000]                     [<ffffffff810bf769>] __sched_setscheduler+0x339/0xbd0
[    0.148000]                     [<ffffffff810c0076>] _sched_setscheduler+0x76/0x90
[    0.148000]                     [<ffffffff810c1012>] sched_set_stop_task+0x62/0xb0
[    0.148000]                     [<ffffffff81143983>] cpu_stop_create+0x23/0x30
[    0.148000]                     [<ffffffff810ba48d>] __smpboot_create_thread.part.2+0xad/0x100
[    0.148000]                     [<ffffffff810ba57f>] smpboot_register_percpu_thread_cpumask+0x9f/0xf0
[    0.148000]                     [<ffffffff821a1708>] cpu_stop_init+0x7d/0xb8
[    0.148000]                     [<ffffffff81000450>] do_one_initcall+0x50/0x180
[    0.148000]                     [<ffffffff821820d2>] kernel_init_freeable+0x111/0x25d
[    0.148000]                     [<ffffffff818c206e>] kernel_init+0xe/0x100
[    0.148000]                     [<ffffffff818d01ff>] ret_from_fork+0x1f/0x40
[    0.148000]    INITIAL USE at:
[    0.148000]                    [<ffffffff810e7f90>] __lock_acquire+0x240/0x1440
[    0.148000]                    [<ffffffff810e95d3>] lock_acquire+0xe3/0x1c0
[    0.148000]                    [<ffffffff818cf661>] _raw_spin_lock+0x31/0x40
[    0.148000]                    [<ffffffff810c0514>] set_user_nice.part.92+0xf4/0x270
[    0.148000]                    [<ffffffff810c06b6>] set_user_nice+0x26/0x30
[    0.148000]                    [<ffffffff810aee10>] create_worker+0xf0/0x1a0
[    0.148000]                    [<ffffffff8219c195>] init_workqueues+0x317/0x51e
[    0.148000]                    [<ffffffff81000450>] do_one_initcall+0x50/0x180
[    0.148000]                    [<ffffffff821820d2>] kernel_init_freeable+0x111/0x25d
[    0.148000]                    [<ffffffff818c206e>] kernel_init+0xe/0x100
[    0.148000]                    [<ffffffff818d01ff>] ret_from_fork+0x1f/0x40
[    0.148000]  }
[    0.148000]  ... key      at: [<ffffffff822f2190>] __key.55894+0x0/0x8
[    0.148000]  ... acquired at:
[    0.148000]    [<ffffffff810e6885>] check_usage_backwards+0x155/0x160
[    0.148000]    [<ffffffff810e7533>] mark_lock+0x333/0x610
[    0.148000]    [<ffffffff810e82e0>] __lock_acquire+0x590/0x1440
[    0.148000]    [<ffffffff810e95d3>] lock_acquire+0xe3/0x1c0
[    0.148000]    [<ffffffff818cf661>] _raw_spin_lock+0x31/0x40
[    0.148000]    [<ffffffff810bf769>] __sched_setscheduler+0x339/0xbd0
[    0.148000]    [<ffffffff810c0076>] _sched_setscheduler+0x76/0x90
[    0.148000]    [<ffffffff810c1012>] sched_set_stop_task+0x62/0xb0
[    0.148000]    [<ffffffff81143983>] cpu_stop_create+0x23/0x30
[    0.148000]    [<ffffffff810ba48d>] __smpboot_create_thread.part.2+0xad/0x100
[    0.148000]    [<ffffffff810ba57f>] smpboot_register_percpu_thread_cpumask+0x9f/0xf0
[    0.148000]    [<ffffffff821a1708>] cpu_stop_init+0x7d/0xb8
[    0.148000]    [<ffffffff81000450>] do_one_initcall+0x50/0x180
[    0.148000]    [<ffffffff821820d2>] kernel_init_freeable+0x111/0x25d
[    0.148000]    [<ffffffff818c206e>] kernel_init+0xe/0x100
[    0.148000]    [<ffffffff818d01ff>] ret_from_fork+0x1f/0x40
[    0.148000] 
[    0.148000] 
[    0.148000] stack backtrace:
[    0.148000] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.7.0-rc7+ #155
[    0.148000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[    0.148000]  0000000000000086 00000000aea03eae ffff88003de6ba60 ffffffff813cb2d5
[    0.148000]  ffffffff82d48e60 ffff88003de6bac0 ffff88003de6baa0 ffffffff811a6b05
[    0.148000]  ffff88003de647d8 ffff88003de647d8 ffff88003de64040 ffffffff81d531a7
[    0.148000] Call Trace:
[    0.148000]  [<ffffffff813cb2d5>] dump_stack+0x67/0x92
[    0.148000]  [<ffffffff811a6b05>] print_irq_inversion_bug.part.38+0x1a4/0x1b0
[    0.148000]  [<ffffffff810e6885>] check_usage_backwards+0x155/0x160
[    0.148000]  [<ffffffff810e7533>] mark_lock+0x333/0x610
[    0.148000]  [<ffffffff810e6730>] ? check_usage_forwards+0x160/0x160
[    0.148000]  [<ffffffff810e82e0>] __lock_acquire+0x590/0x1440
[    0.148000]  [<ffffffff810e7a6d>] ? trace_hardirqs_on+0xd/0x10
[    0.148000]  [<ffffffff81104aad>] ? debug_lockdep_rcu_enabled+0x1d/0x20
[    0.148000]  [<ffffffff810e95d3>] lock_acquire+0xe3/0x1c0
[    0.148000]  [<ffffffff810bf769>] ? __sched_setscheduler+0x339/0xbd0
[    0.148000]  [<ffffffff818cf661>] _raw_spin_lock+0x31/0x40
[    0.148000]  [<ffffffff810bf769>] ? __sched_setscheduler+0x339/0xbd0
[    0.148000]  [<ffffffff810bf769>] __sched_setscheduler+0x339/0xbd0
[    0.148000]  [<ffffffff810c0076>] _sched_setscheduler+0x76/0x90
[    0.148000]  [<ffffffff810c1012>] sched_set_stop_task+0x62/0xb0
[    0.148000]  [<ffffffff81143983>] cpu_stop_create+0x23/0x30
[    0.148000]  [<ffffffff810ba48d>] __smpboot_create_thread.part.2+0xad/0x100
[    0.148000]  [<ffffffff810ba57f>] smpboot_register_percpu_thread_cpumask+0x9f/0xf0
[    0.148000]  [<ffffffff821a1708>] cpu_stop_init+0x7d/0xb8
[    0.148000]  [<ffffffff821a168b>] ? pid_namespaces_init+0x40/0x40
[    0.148000]  [<ffffffff81000450>] do_one_initcall+0x50/0x180
[    0.148000]  [<ffffffff8102c24d>] ? print_cpu_info+0x7d/0xe0
[    0.148000]  [<ffffffff821820d2>] kernel_init_freeable+0x111/0x25d
[    0.148000]  [<ffffffff818c206e>] kernel_init+0xe/0x100
[    0.148000]  [<ffffffff818d01ff>] ret_from_fork+0x1f/0x40
[    0.148000]  [<ffffffff818c2060>] ? rest_init+0x130/0x130

In this v2, I tried to address all comments, thanks for reviews.

-Topi

Topi Miettinen (14):
  resource limits: foundation for resource highwater tracking
  resource limits: aggregate task highwater marks to cgroup level
  resource limits: track highwater mark of file sizes
  resource limits: track highwater mark of VM data segment
  resource limits: track highwater mark of stack size
  resource limits: track highwater mark of cores dumped
  resource limits: track highwater mark of user processes
  resource limits: track highwater mark of number of files
  resource limits: track highwater mark of locked memory
  resource limits: track highwater mark of address space size
  resource limits: track highwater mark of number of pending signals
  resource limits: track highwater mark of size of message queues
  resource limits: track highwater mark of niceness
  resource limits: track highwater mark of RT priority

 Documentation/accounting/getdelays.c       | 62 ++++++++++++++++++++++--
 arch/ia64/kernel/perfmon.c                 |  1 +
 arch/powerpc/kvm/book3s_64_vio.c           |  2 +
 arch/powerpc/mm/mmu_context_iommu.c        |  2 +
 arch/x86/ia32/ia32_aout.c                  |  2 +
 drivers/infiniband/core/umem.c             |  1 +
 drivers/infiniband/hw/hfi1/user_pages.c    |  2 +
 drivers/infiniband/hw/qib/qib_user_pages.c |  2 +
 drivers/infiniband/hw/usnic/usnic_uiom.c   |  2 +
 drivers/misc/mic/scif/scif_rma.c           |  1 +
 drivers/vfio/vfio_iommu_spapr_tce.c        |  2 +
 drivers/vfio/vfio_iommu_type1.c            |  5 ++
 fs/attr.c                                  |  2 +
 fs/binfmt_aout.c                           |  2 +
 fs/binfmt_flat.c                           |  2 +
 fs/coredump.c                              | 11 +++--
 fs/file.c                                  |  4 ++
 include/linux/cgroup-defs.h                |  5 ++
 include/linux/sched.h                      | 61 +++++++++++++++++++++++
 include/linux/tsacct_kern.h                |  3 ++
 include/uapi/linux/cgroupstats.h           |  3 ++
 include/uapi/linux/taskstats.h             | 10 +++-
 ipc/mqueue.c                               |  1 +
 kernel/bpf/syscall.c                       |  8 +++
 kernel/cgroup.c                            | 78 ++++++++++++++++++++++++++++++
 kernel/cred.c                              |  1 +
 kernel/events/core.c                       |  1 +
 kernel/fork.c                              |  2 +
 kernel/sched/core.c                        |  6 +++
 kernel/signal.c                            |  2 +
 kernel/sys.c                               |  5 ++
 kernel/taskstats.c                         |  4 ++
 kernel/tsacct.c                            | 47 ++++++++++++++++++
 mm/mlock.c                                 |  8 +++
 mm/mmap.c                                  | 17 ++++++-
 mm/mremap.c                                |  7 +++
 36 files changed, 365 insertions(+), 9 deletions(-)

-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
