Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 3BF326B0044
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 07:42:17 -0400 (EDT)
Message-ID: <1332762120.16159.100.camel@twins>
Subject: Re: [RFC][PATCH 00/26] sched/numa
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 26 Mar 2012 13:42:00 +0200
In-Reply-To: <CAOhV88O+1=e9+Jrv3cx1j=wbbypzkXL=B6wToOPYRArgYVF9cQ@mail.gmail.com>
References: <20120316144028.036474157@chello.nl>
	 <CAOhV88NafiU7hseTzQfApthMk3X=_GT09gEM2Zzx5OJ=8z6vvw@mail.gmail.com>
	 <1332409539.18960.508.camel@twins>
	 <CAOhV88O+1=e9+Jrv3cx1j=wbbypzkXL=B6wToOPYRArgYVF9cQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2012-03-23 at 18:41 -0700, Nish Aravamudan wrote:
> [2012-03-20 00:46:33]   Unable to handle kernel paging request for data a=
t address 0x00001688
> [2012-03-20 00:46:33]   Faulting instruction address: 0xc000000000168338
> [2012-03-20 00:46:33]   Oops: Kernel access of bad area, sig: 11 [#1]
> [2012-03-20 00:46:33]   SMP NR_CPUS=3D32 NUMA pSeries
> [2012-03-20 00:46:33]   Modules linked in:
> [2012-03-20 00:46:33]   NIP: c000000000168338 LR: c0000000001b523c CTR: 0=
000000000000000
> [2012-03-20 00:46:33]   REGS: c00000013d887700 TRAP: 0300   Not tainted (=
3.3.0-rc7)
> [2012-03-20 00:46:33]   MSR: 8000000000009032 <SF,EE,ME,IR,DR,RI>  CR: 24=
004022  XER: 00000008
> [2012-03-20 00:46:33]   CFAR: 0000000000005374
> [2012-03-20 00:46:33]   DAR: 0000000000001688, DSISR: 40000000
> [2012-03-20 00:46:33]   TASK =3D c00000013d888000[1] 'swapper/0' THREAD: =
c00000013d884000 CPU: 0
> [2012-03-20 00:46:33]   GPR00: 0000000000000000 c00000013d887980 c0000000=
00ce7990 00000000000012d0
> [2012-03-20 00:46:33]   GPR04: 0000000000000000 0000000000001680 00000000=
00000000 0003005500000001
> [2012-03-20 00:46:33]   GPR08: 0000000000000001 0000000000000000 c0000000=
00d25000 0000000000000010
> [2012-03-20 00:46:33]   GPR12: 0000000044004024 c00000000fffa000 00000000=
00000000 0000000000000060
> [2012-03-20 00:46:33]   GPR16: c000000000a69040 c000000000a66828 00000000=
02e317f0 0000000001a3f930
> [2012-03-20 00:46:33]   GPR20: 0000000000000000 0000000000001680 00000000=
00000001 0000000000210d00
> [2012-03-20 00:46:33]   GPR24: c000000000d193a0 0000000000000000 00000000=
00001680 00000000000012d0
> [2012-03-20 00:46:33]   GPR28: 0000000000000000 0000000000000000 c0000000=
00c5d6e8 c00000013e009200
> [2012-03-20 00:46:33]   NIP [c000000000168338] .__alloc_pages_nodemask+0x=
b8/0x860
> [2012-03-20 00:46:33]   LR [c0000000001b523c] .new_slab+0xcc/0x3d0
> [2012-03-20 00:46:33]   Call Trace:
> [2012-03-20 00:46:33]   [c00000013d887980] [c0000000001683dc] .__alloc_pa=
ges_nodemask+0x15c/0x860 (unreliable)
> [2012-03-20 00:46:33]   [c00000013d887b00] [c0000000001b523c] .new_slab+0=
xcc/0x3d0
> [2012-03-20 00:46:33]   [c00000013d887bb0] [c0000000007fc780] .__slab_all=
oc+0x388/0x4e0
> [2012-03-20 00:46:33]   [c00000013d887cd0] [c0000000001b5af8] .kmem_cache=
_alloc_node_trace+0x98/0x230
> [2012-03-20 00:46:33]   [c00000013d887d90] [c000000000b83ed0] .numa_init+=
0x90/0x1d0
> [2012-03-20 00:46:33]   [c00000013d887e20] [c00000000000ab60] .do_one_ini=
tcall+0x60/0x1e0
> [2012-03-20 00:46:33]   [c00000013d887ee0] [c000000000b5cad4] .kernel_ini=
t+0xf0/0x1e0
> [2012-03-20 00:46:33]   [c00000013d887f90] [c000000000021e14] .kernel_thr=
ead+0x54/0x70
> [2012-03-20 00:46:33]   Instruction dump:
> [2012-03-20 00:46:33]   0b000000 eb1e8000 3ba00000 801800a8 2f800000 409e=
001c 7860efe3 38000000
> [2012-03-20 00:46:33]   41820008 38000002 7b7d6fe2 7fbd0378 <e81a0008> 82=
7800a4 3be00000 2fa00000
> [2012-03-20 00:46:33]   ---[ end trace 31fd0ba7d8756001 ]---=20

Can't say I've ever seen that one before.. that looks to be the
kzalloc() in numa_init() which is ran as an early_initcall(), which is
way after mm_init() and numa_policy_init() in init/main.c.

Where exactly in __alloc_pages_nodemask() is this?

The only thing I can think of is that the policy returned by
get_task_policy() is wonky and we get a weird zone_list, but that would
mean this is the first kmalloc() ever.. also all that should be set up
by now.

Hmm..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
