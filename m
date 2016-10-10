Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7198F6B0069
	for <linux-mm@kvack.org>; Mon, 10 Oct 2016 05:16:13 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id n3so34618471lfn.5
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 02:16:13 -0700 (PDT)
Received: from mail-lf0-x22e.google.com (mail-lf0-x22e.google.com. [2a00:1450:4010:c07::22e])
        by mx.google.com with ESMTPS id 67si2993382ljf.100.2016.10.10.02.16.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Oct 2016 02:16:11 -0700 (PDT)
Received: by mail-lf0-x22e.google.com with SMTP id b75so115103175lfg.3
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 02:16:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <57f9c82e.wswaLjJd7sV05RiZ%fengguang.wu@intel.com>
References: <57f9c82e.wswaLjJd7sV05RiZ%fengguang.wu@intel.com>
From: Alexander Potapenko <glider@google.com>
Date: Mon, 10 Oct 2016 11:16:09 +0200
Message-ID: <CAG_fn=Vgv3Mr=KftNyu21Zjpam8wN9TFvwy2KHLy9cKi_XsQfA@mail.gmail.com>
Subject: Re: [mm, kasan] 80a9201a59: INFO: rcu_sched stall on CPU (84741 ticks
 this GP) idle=140000000000000 (t=100000 jiffies q=1)
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <fengguang.wu@intel.com>
Cc: LKP <lkp@01.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, wfg@linux.intel.com

The stack trace looks unrelated to KASAN.

On Sun, Oct 9, 2016 at 6:31 AM, kernel test robot
<fengguang.wu@intel.com> wrote:
> Greetings,
>
> 0day kernel testing robot got the below dmesg and the first bad commit is
>
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>
> commit 80a9201a5965f4715d5c09790862e0df84ce0614
> Author:     Alexander Potapenko <glider@google.com>
> AuthorDate: Thu Jul 28 15:49:07 2016 -0700
> Commit:     Linus Torvalds <torvalds@linux-foundation.org>
> CommitDate: Thu Jul 28 16:07:41 2016 -0700
>
>     mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SL=
UB
>
>     For KASAN builds:
>      - switch SLUB allocator to using stackdepot instead of storing the
>        allocation/deallocation stacks in the objects;
>      - change the freelist hook so that parts of the freelist can be put
>        into the quarantine.
>
>     [aryabinin@virtuozzo.com: fixes]
>       Link: http://lkml.kernel.org/r/1468601423-28676-1-git-send-email-ar=
yabinin@virtuozzo.com
>     Link: http://lkml.kernel.org/r/1468347165-41906-3-git-send-email-glid=
er@google.com
>     Signed-off-by: Alexander Potapenko <glider@google.com>
>     Cc: Andrey Konovalov <adech.fo@gmail.com>
>     Cc: Christoph Lameter <cl@linux.com>
>     Cc: Dmitry Vyukov <dvyukov@google.com>
>     Cc: Steven Rostedt (Red Hat) <rostedt@goodmis.org>
>     Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>     Cc: Kostya Serebryany <kcc@google.com>
>     Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
>     Cc: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
>
> +------------------------------------------------------------------------=
----+------------+------------+------------+
> |                                                                        =
    | c146a2b98e | 80a9201a59 | a61bc9c9af |
> +------------------------------------------------------------------------=
----+------------+------------+------------+
> | boot_successes                                                         =
    | 655        | 86         | 9          |
> | boot_failures                                                          =
    | 0          | 139        | 16         |
> | INFO:rcu_sched_stall_on_CPU(#ticks_this_GP)idle=3D#(t=3D#jiffies_q=3D#)=
          | 0          | 139        | 10         |
> | calltrace:mark_rodata_ro                                               =
    | 0          | 139        | 14         |
> | Kernel_panic-not_syncing:VFS:Unable_to_mount_root_fs_on_unknown-block(#=
,#) | 0          | 0          | 2          |
> | calltrace:prepare_namespace                                            =
    | 0          | 0          | 2          |
> | WARNING:at_arch/x86/mm/dump_pagetables.c:#note_page                    =
    | 0          | 0          | 6          |
> +------------------------------------------------------------------------=
----+------------+------------+------------+
>
> [   14.024541] Write protecting the kernel read-only data: 18432k
> [   14.030857] Freeing unused kernel memory: 1936K (ffff88000e81c000 - ff=
ff88000ea00000)
> [   14.043192] Freeing unused kernel memory: 248K (ffff88000efc2000 - fff=
f88000f000000)
> [  114.005845] INFO: rcu_sched stall on CPU (84741 ticks this GP) idle=3D=
140000000000000 (t=3D100000 jiffies q=3D1)
> [  114.009928] CPU: 0 PID: 1 Comm: swapper Not tainted 4.7.0-05999-g80a92=
01 #1
> [  114.011362] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIO=
S Debian-1.8.2-1 04/01/2014
> [  114.013154]  0000000000000000 ffffffffacc40db8 ffffffffabfc7274 ffffff=
ffacc40df8
> [  114.014763]  ffffffffabae00ec 0000000000000001 0000000000000000 000000=
0000000000
> [  114.016378]  00000019dcf1a68b ffffffffacc40f18 fffffffface7e488 ffffff=
ffacc40e18
> [  114.017988] Call Trace:
> [  114.018504]  <IRQ>  [<ffffffffabfc7274>] dump_stack+0x19/0x1b
> [  114.019739]  [<ffffffffabae00ec>] check_cpu_stall+0xc0/0x124
> [  114.021041]  [<ffffffffabae0283>] rcu_check_callbacks+0x50/0xa0
> [  114.022263]  [<ffffffffabae62fe>] update_process_times+0x2e/0x52
> [  114.023503]  [<ffffffffabaf8f5f>] tick_sched_handle+0x66/0x6d
> [  114.024813]  [<ffffffffabaf8fa3>] tick_sched_timer+0x3d/0x78
> [  114.025977]  [<ffffffffabae733d>] __hrtimer_run_queues+0x252/0x45b
> [  114.027461]  [<ffffffffabaf8f66>] ? tick_sched_handle+0x6d/0x6d
> [  114.028793]  [<ffffffffabae70eb>] ? hrtimer_start_range_ns+0x315/0x315
> [  114.030130]  [<ffffffffaba29b24>] ? kvm_clock_get_cycles+0x9/0xb
> [  114.031367]  [<ffffffffabaf1120>] ? ktime_get_update_offsets_now+0xf1/=
0x184
> [  114.032784]  [<ffffffffabae76d4>] hrtimer_interrupt+0x8c/0x189
> [  114.033983]  [<ffffffffaba1f190>] local_apic_timer_interrupt+0x42/0x44
> [  114.035337]  [<ffffffffac417ba8>] smp_apic_timer_interrupt+0x55/0x66
> [  114.036636]  [<ffffffffac416b6d>] apic_timer_interrupt+0x7d/0x90
> [  114.037864]  <EOI>  [<ffffffffaba37538>] ? note_page+0x2b/0x7af
> [  114.039125]  [<ffffffffaba375db>] ? note_page+0xce/0x7af
> [  114.040219]  [<ffffffffaba37fff>] ptdump_walk_pgd_level_core+0x343/0x4=
83
> [  114.041583]  [<ffffffffaba37cbc>] ? note_page+0x7af/0x7af
> [  114.042577]  [<ffffffffaba38168>] ptdump_walk_pgd_level_checkwx+0x17/0=
x2f
> [  114.043639]  [<ffffffffaba2dc93>] mark_rodata_ro+0x14b/0x152
> [  114.044545]  [<ffffffffac40ce10>] kernel_init+0x29/0x100
> [  114.045393]  [<ffffffffac4162df>] ret_from_fork+0x1f/0x40
> [  114.046252]  [<ffffffffac40cde7>] ? rest_init+0xce/0xce
> [  118.107577] x86/mm: Checked W+X mappings: passed, no W+X pages found.
> [  118.113902] rcu-torture: rtc: ffffffffaddea720 ver: 1 tfle: 0 rta: 1 r=
taf: 0 rtf: 0 rtmbe: 0 rtbke: 0 rtbre: 0 rtbf: 0 rtb: 0 nt: 1 barrier: 0/0:=
0 cbflood: 1
>
> git bisect start v4.8 v4.7 --
> git bisect  bad e6e7214fbbdab1f90254af68e0927bdb24708d22  # 07:46      9-=
      9  Merge branch 'sched-urgent-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/tip
> git bisect  bad ba929b6646c5b87c7bb15cd8d3e51617725c983b  # 08:00     14-=
      7  Merge branch 'for-linus-4.8' of git://git.kernel.org/pub/scm/linux=
/kernel/git/mason/linux-btrfs
> git bisect good 468fc7ed5537615efe671d94248446ac24679773  # 08:21    219+=
      2  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
> git bisect  bad e55884d2c6ac3ae50e49a1f6fe38601a91181719  # 08:34     17-=
      7  Merge tag 'vfio-v4.8-rc1' of git://github.com/awilliam/linux-vfio
> git bisect good 554828ee0db41618d101d9549db8808af9fd9d65  # 08:47    220+=
      0  Merge branch 'salted-string-hash'
> git bisect good ce8c891c3496d3ea4a72ec40beac9a7b7f6649bf  # 09:07    225+=
      0  Merge tag 'rproc-v4.8' of git://github.com/andersson/remoteproc
> git bisect  bad 1c88e19b0f6a8471ee50d5062721ba30b8fd4ba9  # 09:20      2-=
      3  Merge branch 'akpm' (patches from Andrew)
> git bisect good c9b011a87dd49bac1632311811c974bb7cd33c25  # 09:39    225+=
      1  Merge tag 'hwlock-v4.8' of git://github.com/andersson/remoteproc
> git bisect good 6039b80eb50a893476fea7d56e86ed2d19290054  # 10:02    216+=
      1  Merge tag 'dmaengine-4.8-rc1' of git://git.infradead.org/users/vko=
ul/slave-dma
> git bisect good bca6759258dbef378bcf5b872177bcd2259ceb68  # 10:20    224+=
      0  mm, vmstat: remove zone and node double accounting by approximatin=
g retries
> git bisect good efdc94907977d2db84b4b00cb9bd98ca011f6819  # 10:33    225+=
      0  mm: fix memcg stack accounting for sub-page stacks
> git bisect good fb399b4854d2159a4d23fbfbd7daaed914fd54fa  # 10:46    225+=
      1  mm/memblock.c: fix index adjustment error in __next_mem_range_rev(=
)
> git bisect  bad 31a6c1909f51dbe9bf08eb40dc64e3db90cf6f79  # 11:00      6-=
      6  mm, page_alloc: set alloc_flags only once in slowpath
> git bisect good c146a2b98eb5898eb0fab15a332257a4102ecae9  # 11:14    215+=
      0  mm, kasan: account for object redzone in SLUB's nearest_obj()
> git bisect  bad 87cc271d5e4320d705cfdf59f68d4d037b3511b2  # 11:24     14-=
      5  lib/stackdepot.c: use __GFP_NOWARN for stack allocations
> git bisect  bad 80a9201a5965f4715d5c09790862e0df84ce0614  # 11:36      1-=
      1  mm, kasan: switch SLUB to stackdepot, enable memory quarantine for=
 SLUB
> # first bad commit: [80a9201a5965f4715d5c09790862e0df84ce0614] mm, kasan:=
 switch SLUB to stackdepot, enable memory quarantine for SLUB
> git bisect good c146a2b98eb5898eb0fab15a332257a4102ecae9  # 11:52    655+=
      0  mm, kasan: account for object redzone in SLUB's nearest_obj()
> # extra tests with CONFIG_DEBUG_INFO_REDUCED
> git bisect  bad 80a9201a5965f4715d5c09790862e0df84ce0614  # 12:11      8-=
      5  mm, kasan: switch SLUB to stackdepot, enable memory quarantine for=
 SLUB
> # extra tests on HEAD of linux-devel/devel-spot-201610090613
> git bisect  bad a61bc9c9af01517642ddecff8d6f2425baf33e61  # 12:12      0-=
     16  0day head guard for 'devel-spot-201610090613'
> # extra tests on tree/branch linus/master
> git bisect  bad b66484cd74706fa8681d051840fe4b18a3da40ff  # 12:29      6-=
      2  Merge branch 'akpm' (patches from Andrew)
> # extra tests on tree/branch linus/master
> git bisect  bad b66484cd74706fa8681d051840fe4b18a3da40ff  # 12:30      0-=
      2  Merge branch 'akpm' (patches from Andrew)
> # extra tests on tree/branch linux-next/master
> git bisect  bad c802e87fbe2d4dd58982d01b3c39bc5a781223aa  # 12:31      0-=
      1  Add linux-next specific files for 20161006
>
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Ce=
nter
> https://lists.01.org/pipermail/lkp                          Intel Corpora=
tion



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
