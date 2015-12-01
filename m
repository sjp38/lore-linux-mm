Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f48.google.com (mail-lf0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 628356B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 06:56:23 -0500 (EST)
Received: by lffu14 with SMTP id u14so4844883lff.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 03:56:22 -0800 (PST)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [146.101.78.143])
        by mx.google.com with ESMTPS id p185si32029693lfp.239.2015.12.01.03.50.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 01 Dec 2015 03:50:26 -0800 (PST)
Message-ID: <565D8979.5050605@arm.com>
Date: Tue, 01 Dec 2015 11:50:17 +0000
From: Vladimir Murzin <vladimir.murzin@arm.com>
MIME-Version: 1.0
Subject: Re: [BISECTED] rcu_sched self-detected stall since 3.17
References: <564F3DCA.1080907@arm.com>
In-Reply-To: <564F3DCA.1080907@arm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: neilb@suse.de, oleg@redhat.com, peterz@infradead.org, mark.rutland@arm.com, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

On 20/11/15 15:35, Vladimir Murzin wrote:
> Hi,
>=20
> I've been getting rcu_sched self-detected stall on one of our test
> environment with the following (or similar) log:
>=20
> Linux 4.3

Anybody looking into this? Oleg, Peter, any ideas what's happening here?

Thanks
Vladimir

>=20
>> INFO: rcu_sched self-detected stall on CPU
>> =092: (2099 ticks this GP) idle=3Da73/140000000000001/0 softirq=3D277/28=
3 fqs=3D2092=20
>> =09 (t=3D2100 jiffies g=3D-197 c=3D-198 q=3D230)
>> Task dump for CPU 2:
>> paranoia        R running      0   423      1 0x00000003
>> [<c0016f20>] (unwind_backtrace) from [<c0012fd0>] (show_stack+0x10/0x14)
>> [<c0012fd0>] (show_stack) from [<c006c52c>] (rcu_dump_cpu_stacks+0xa4/0x=
c4)
>> [<c006c52c>] (rcu_dump_cpu_stacks) from [<c006f188>] (rcu_check_callback=
s+0x2dc/0x81c)
>> [<c006f188>] (rcu_check_callbacks) from [<c0072278>] (update_process_tim=
es+0x38/0x64)
>> [<c0072278>] (update_process_times) from [<c007e7b8>] (tick_periodic+0xa=
8/0xb8)
>> [<c007e7b8>] (tick_periodic) from [<c007e904>] (tick_handle_periodic+0x2=
8/0x88)
>> [<c007e904>] (tick_handle_periodic) from [<c0223074>] (arch_timer_handle=
r_virt+0x28/0x30)
>> [<c0223074>] (arch_timer_handler_virt) from [<c0068008>] (handle_percpu_=
devid_irq+0x6c/0x84)
>> [<c0068008>] (handle_percpu_devid_irq) from [<c0064244>] (generic_handle=
_irq+0x24/0x34)
>> [<c0064244>] (generic_handle_irq) from [<c0064518>] (__handle_domain_irq=
+0x98/0xac)
>> [<c0064518>] (__handle_domain_irq) from [<c0009444>] (gic_handle_irq+0x5=
4/0x90)
>> [<c0009444>] (gic_handle_irq) from [<c0013b14>] (__irq_svc+0x54/0x70)
>> Exception stack(0xdb007c60 to 0xdb007ca8)
>> 7c60: 00000000 00000000 00000000 00000001 dc3e9a20 00000000 00000000 000=
00001
>> 7c80: dc3e9a20 0000001b 00080000 0000000b ffffffff db007cb0 c00ac8f0 c00=
aa96c
>> 7ca0: 600d0113 ffffffff
>> [<c0013b14>] (__irq_svc) from [<c00aa96c>] (free_pages_prepare+0x18c/0x2=
18)
>> [<c00aa96c>] (free_pages_prepare) from [<c00ac8f0>] (free_hot_cold_page+=
0x34/0x168)
>> [<c00ac8f0>] (free_hot_cold_page) from [<c00c996c>] (handle_mm_fault+0x7=
b8/0xe60)
>> [<c00c996c>] (handle_mm_fault) from [<c001c194>] (do_page_fault+0x12c/0x=
378)
>> [<c001c194>] (do_page_fault) from [<c00092dc>] (do_DataAbort+0x38/0xb4)
>> [<c00092dc>] (do_DataAbort) from [<c0013aa0>] (__dabt_svc+0x40/0x60)
>> Exception stack(0xdb007e68 to 0xdb007eb0)
>> 7e60:                   0001b2c8 00000d30 00000000 00000055 00000051 dbb=
04600
>> 7e80: 00000000 db007ec8 db8ea700 db8f3080 dba43240 0001b2c8 00000000 db0=
07eb8
>> 7ea0: c012c178 c0174ce8 200d0113 ffffffff
>> [<c0013aa0>] (__dabt_svc) from [<c0174ce8>] (__clear_user_std+0x34/0x68)
>> [<c0174ce8>] (__clear_user_std) from [<c012c178>] (padzero+0x58/0x74)
>> [<c012c178>] (padzero) from [<c012cb4c>] (load_elf_binary+0x730/0x1250)
>> [<c012cb4c>] (load_elf_binary) from [<c00ecd6c>] (search_binary_handler+=
0xa0/0x23c)
>> [<c00ecd6c>] (search_binary_handler) from [<c00ed730>] (do_execveat_comm=
on+0x444/0x5d8)
>> [<c00ed730>] (do_execveat_common) from [<c00ed8e8>] (do_execve+0x24/0x2c=
)
>> [<c00ed8e8>] (do_execve) from [<c000f580>] (ret_fast_syscall+0x0/0x3c)
>=20
> (I put report for Linux 3.17 under [2])
>=20
> This rcu_sched self-detected stall is usually reproduced 2 or 3 times
> out of 10 runs, but sometimes even more runs go without issue.
>=20
> I bisected [1] it to commit
>=20
> commit 743162013d40ca612b4cb53d3a200dff2d9ab26e
> Author: NeilBrown <neilb@suse.de>
> Date:   Mon Jul 7 15:16:04 2014 +1000
>=20
>     sched: Remove proliferation of wait_on_bit() action functions
>=20
> The only change I noticed is from (mm/filemap.c)
>=20
> =09io_schedule();
> =09fatal_signal_pending(current)
>=20
> to (kernel/sched/wait.c)
>=20
> =09signal_pending_state(current->state, current)
> =09io_schedule();
>=20
> and if I apply following diff I don't see stalls anymore.
>=20
> diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
> index a104879..2d68cdb 100644
> --- a/kernel/sched/wait.c
> +++ b/kernel/sched/wait.c
> @@ -514,9 +514,10 @@ EXPORT_SYMBOL(bit_wait);
>=20
>  __sched int bit_wait_io(void *word)
>  {
> +       io_schedule();
> +
>         if (signal_pending_state(current->state, current))
>                 return 1;
> -       io_schedule();
>         return 0;
>  }
>  EXPORT_SYMBOL(bit_wait_io);
>=20
> Any ideas why it might happen and why diff above helps?
>=20
> [1] Bisect log:
>=20
> I checked 4.[0-3] and 3.1[7-9] manually
> I have https://lkml.org/lkml/2015/8/26/649 for better report
>=20
>> git bisect start '--no-checkout'
>> # good: [19583ca584d6f574384e17fe7613dfaeadcdc4a6] Linux 3.16
>> git bisect good 19583ca584d6f574384e17fe7613dfaeadcdc4a6
>> # bad: [53ee983378ff23e8f3ff95ecf99dea7c6c221900] Merge tag 'staging-3.1=
7-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging
>> git bisect bad 53ee983378ff23e8f3ff95ecf99dea7c6c221900
>> # good: [2042088cd67d0064d18c52c13c69af2499907bb1] staging: comedi: ni_l=
abpc: tidy up labpc_ai_scan_mode()
>> git bisect good 2042088cd67d0064d18c52c13c69af2499907bb1
>> # bad: [98959948a7ba33cf8c708626e0d2a1456397e1c6] Merge branch 'sched-co=
re-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
>> git bisect bad 98959948a7ba33cf8c708626e0d2a1456397e1c6
>> # good: [c9b88e9581828bb8bba06c5e7ee8ed1761172b6e] Merge tag 'trace-3.17=
-2' of git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-trace
>> git bisect good c9b88e9581828bb8bba06c5e7ee8ed1761172b6e
>> # good: [5bda4f638f36ef4c4e3b1397b02affc3db94356e] Merge branch 'core-rc=
u-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
>> git bisect good 5bda4f638f36ef4c4e3b1397b02affc3db94356e
>> # good: [2336ebc32676df5b794acfe0c980583ec6c05f34] Merge tag 'perf-core-=
for-mingo' of git://git.kernel.org/pub/scm/linux/kernel/git/jolsa/perf into=
 perf/core
>> git bisect good 2336ebc32676df5b794acfe0c980583ec6c05f34
>> # good: [ef35ad26f8ff44d2c93e29952cdb336bda729d9d] Merge branch 'perf-co=
re-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
>> git bisect good ef35ad26f8ff44d2c93e29952cdb336bda729d9d
>> # good: [1c5d3eb3759013bc7ee4197aa0a9f245bdb6eb90] sched/numa: Simplify =
task_numa_compare()
>> git bisect good 1c5d3eb3759013bc7ee4197aa0a9f245bdb6eb90
>> # good: [6e76ea8a8209386c3cc7ee5594e6ea5d25525cf2] sched: Remove extra s=
tatic_key*() function indirection
>> git bisect good 6e76ea8a8209386c3cc7ee5594e6ea5d25525cf2
>> # bad: [c1221321b7c25b53204447cff9949a6d5a7ddddc] sched: Allow wait_on_b=
it_action() functions to support a timeout
>> git bisect bad c1221321b7c25b53204447cff9949a6d5a7ddddc
>> # good: [e720fff6341fe4b95e5a93c939bd3c77fa55ced4] sched/numa: Revert "U=
se effective_load() to balance NUMA loads"
>> git bisect good e720fff6341fe4b95e5a93c939bd3c77fa55ced4
>> # bad: [743162013d40ca612b4cb53d3a200dff2d9ab26e] sched: Remove prolifer=
ation of wait_on_bit() action functions
>> git bisect bad 743162013d40ca612b4cb53d3a200dff2d9ab26e
>> # good: [d26fad5b38e1c4667d4f2604936e59c837caa54d] Merge tag 'v3.16-rc5'=
 into sched/core, to refresh the branch before applying bigger tree-wide ch=
anges
>> git bisect good d26fad5b38e1c4667d4f2604936e59c837caa54d
>=20
> [2] rcu_sched self-detected stall under Linux 3.17
>=20
>> INFO: rcu_sched self-detected stall on CPU { 2}  (t=3D2100 jiffies g=3D-=
199 c=3D-200 q=3D172)
>> Task dump for CPU 2:
>> paranoia        R running      0   414      1 0x00000003
>> [<c0015394>] (unwind_backtrace) from [<c00117dc>] (show_stack+0x10/0x14)
>> [<c00117dc>] (show_stack) from [<c00602d0>] (rcu_dump_cpu_stacks+0xa4/0x=
c4)
>> [<c00602d0>] (rcu_dump_cpu_stacks) from [<c0062aec>] (rcu_check_callback=
s+0x280/0x6f8)
>> [<c0062aec>] (rcu_check_callbacks) from [<c0065b9c>] (update_process_tim=
es+0x40/0x60)
>> [<c0065b9c>] (update_process_times) from [<c007169c>] (tick_periodic+0xa=
8/0xb8)
>> [<c007169c>] (tick_periodic) from [<c00717bc>] (tick_handle_periodic+0x2=
8/0x88)
>> [<c00717bc>] (tick_handle_periodic) from [<c01fc414>] (arch_timer_handle=
r_virt+0x28/0x30)
>> [<c01fc414>] (arch_timer_handler_virt) from [<c005d100>] (handle_percpu_=
devid_irq+0x6c/0x84)
>> [<c005d100>] (handle_percpu_devid_irq) from [<c0059658>] (generic_handle=
_irq+0x2c/0x3c)
>> [<c0059658>] (generic_handle_irq) from [<c000ee3c>] (handle_IRQ+0x7c/0x8=
c)
>> [<c000ee3c>] (handle_IRQ) from [<c00085f8>] (gic_handle_irq+0x40/0x5c)
>> [<c00085f8>] (gic_handle_irq) from [<c0012300>] (__irq_svc+0x40/0x54)
>> Exception stack(0xdb063c60 to 0xdb063ca8)
>> 3c60: 00000000 0001b000 dbbfc000 0000000b dbbfc000 0000000b dbbfc000 000=
1b000
>> 3c80: 0001b000 dbb2d6e0 0000001b db03c380 0000006c db063ca8 c00b935c c00=
b935c
>> 3ca0: a00d0113 ffffffff
>> [<c0012300>] (__irq_svc) from [<c00b935c>] (do_cow_fault.isra.97+0x1c/0x=
198)
>> [<c00b935c>] (do_cow_fault.isra.97) from [<c00b9804>] (handle_mm_fault+0=
x14c/0x900)
>> [<c00b9804>] (handle_mm_fault) from [<c001ae38>] (do_page_fault+0x120/0x=
3d8)
>> [<c001ae38>] (do_page_fault) from [<c00084c0>] (do_DataAbort+0x38/0x98)
>> [<c00084c0>] (do_DataAbort) from [<c0012298>] (__dabt_svc+0x38/0x60)
>> Exception stack(0xdb063e70 to 0xdb063eb8)
>> 3e60:                                     0001b2c8 00000d30 00000000 000=
00000
>> 3e80: db902a80 dbadc100 00000000 db063ec8 db062008 dbadc200 0001b2c8 000=
1b6cc
>> 3ea0: 00000000 db063eb8 c011689c c015a884 200d0013 ffffffff
>> [<c0012298>] (__dabt_svc) from [<c015a884>] (__clear_user_std+0x34/0x64)
>> [<c015a884>] (__clear_user_std) from [<c011689c>] (padzero+0x44/0x58)
>> [<c011689c>] (padzero) from [<c01182e8>] (load_elf_binary+0x778/0x138c)
>> [<c01182e8>] (load_elf_binary) from [<c00da960>] (search_binary_handler+=
0x98/0x1d8)
>> [<c00da960>] (search_binary_handler) from [<c00dbc2c>] (do_execve+0x35c/=
0x4bc)
>> [<c00dbc2c>] (do_execve) from [<c000e520>] (ret_fast_syscall+0x0/0x30)
>=20
> Thanks
> Vladimir
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>=20
>=20
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
