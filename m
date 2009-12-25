Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5B674620002
	for <linux-mm@kvack.org>; Thu, 24 Dec 2009 22:14:40 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBP3EbqN027178
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 25 Dec 2009 12:14:37 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E89E645DE70
	for <linux-mm@kvack.org>; Fri, 25 Dec 2009 12:14:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C233645DE6F
	for <linux-mm@kvack.org>; Fri, 25 Dec 2009 12:14:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F6521DB803A
	for <linux-mm@kvack.org>; Fri, 25 Dec 2009 12:14:36 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5137F1DB803E
	for <linux-mm@kvack.org>; Fri, 25 Dec 2009 12:14:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: OOM killer unexpectedly called with kernel 2.6.32
In-Reply-To: <200912250042.43312.arnaud.boulan@libertysurf.fr>
References: <200912250042.43312.arnaud.boulan@libertysurf.fr>
Message-Id: <20091225121335.AA7E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 25 Dec 2009 12:14:35 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "A. Boulan" <arnaud.boulan@libertysurf.fr>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Hello,
>=20
> When using kernel version 2.6.32.2 I have  a problem where the kernel cal=
ls the OOM killer
> although there are still plenty of RAM and swap available.
>=20
> I am able to easily reproduce the problem when there is a huge background=
 file tansfer between
> 2 disks (cp -a of several Gigabytes), and then starting a few application=
s. In less than a minute
> the kernel starts killing random processes (firefox, kmail, kdesktop, etc=
), although there is still
> free (or buffers/cache) memory and the swap is not used at all...
>=20
> I do not reproduce this problem when using kernel 2.6.31.8 (compiled with=
 the same compiler,=20
> and with the same userspace)
>=20
> I have no idea what could cause this problem. Any help will be appreciate=
d.
> Regards,
>=20
> Arnaud
>=20
> (please CC me for any reply, i'm not subscribed to the list)
>=20
>=20
> Dec 24 18:16:03 picchu kernel: X invoked oom-killer: gfp_mask=3D0x0, orde=
r=3D0, oom_adj=3D0
> Dec 24 18:16:03 picchu kernel: X cpuset=3D/ mems_allowed=3D0
> Dec 24 18:16:03 picchu kernel: Pid: 10719, comm: X Not tainted 2.6.32.2 #=
1
> Dec 24 18:16:03 picchu kernel: Call Trace:
> Dec 24 18:16:03 picchu kernel: [<ffffffff8106d513>] ? cpuset_print_task_m=
ems_allowed+0x8d/0x98
> Dec 24 18:16:03 picchu kernel: [<ffffffff8108166c>] oom_kill_process+0x82=
/0x241
> Dec 24 18:16:03 picchu kernel: [<ffffffff81052014>] ? ktime_get_ts+0xb1/0=
xbe
> Dec 24 18:16:03 picchu kernel: [<ffffffff81081cfb>] __out_of_memory+0x134=
/0x14b
> Dec 24 18:16:03 picchu kernel: [<ffffffff81081dff>] pagefault_out_of_memo=
ry+0x55/0x7a
> Dec 24 18:16:03 picchu kernel: [<ffffffff8102594e>] mm_fault_error+0x3b/0=
xf6
> Dec 24 18:16:03 picchu kernel: [<ffffffff81093639>] ? handle_mm_fault+0x3=
59/0x6a4
> Dec 24 18:16:03 picchu kernel: [<ffffffff81025b9d>] do_page_fault+0x194/0=
x1e3
> Dec 24 18:16:03 picchu kernel: [<ffffffff813aed1f>] page_fault+0x1f/0x30
> Dec 24 18:16:03 picchu kernel: Mem-Info:
> Dec 24 18:16:03 picchu kernel: DMA per-cpu:
> Dec 24 18:16:03 picchu kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Dec 24 18:16:03 picchu kernel: CPU    1: hi:    0, btch:   1 usd:   0
> Dec 24 18:16:03 picchu kernel: DMA32 per-cpu:
> Dec 24 18:16:03 picchu kernel: CPU    0: hi:  186, btch:  31 usd: 165
> Dec 24 18:16:03 picchu kernel: CPU    1: hi:  186, btch:  31 usd:  64
> Dec 24 18:16:03 picchu kernel: active_anon:155933 inactive_anon:54013 iso=
lated_anon:0
> Dec 24 18:16:03 picchu kernel: active_file:122843 inactive_file:129683 is=
olated_file:35
> Dec 24 18:16:03 picchu kernel: unevictable:464 dirty:20768 writeback:1818=
6 unstable:0
> Dec 24 18:16:03 picchu kernel: free:3398 slab_reclaimable:22778 slab_unre=
claimable:8060
> Dec 24 18:16:03 picchu kernel: mapped:19607 shmem:63182 pagetables:8230 b=
ounce:0
> Dec 24 18:16:03 picchu kernel: DMA free:8004kB min:40kB low:48kB high:60k=
B active_anon:120kB inactive_anon:340kB active_file:1384kB inactive
> _file:3672kB unevictable:0kB isolated(anon):0kB isolated(file):0kB presen=
t:15368kB mlocked:0kB dirty:0kB writeback:0kB mapped:52kB shmem:0kB
>  slab_reclaimable:2300kB slab_unreclaimable:4kB kernel_stack:8kB pagetabl=
es:100kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
> all_unreclaimable? no
> Dec 24 18:16:03 picchu kernel: lowmem_reserve[]: 0 1993 1993 1993
> Dec 24 18:16:03 picchu kernel: DMA32 free:5588kB min:5692kB low:7112kB hi=
gh:8536kB active_anon:623612kB inactive_anon:215712kB active_file:4
> 89988kB inactive_file:515060kB unevictable:1856kB isolated(anon):0kB isol=
ated(file):140kB present:2041776kB mlocked:1856kB dirty:83072kB wri
> teback:72744kB mapped:78376kB shmem:252728kB slab_reclaimable:88812kB sla=
b_unreclaimable:32236kB kernel_stack:2416kB pagetables:32820kB unst
> able:0kB bounce:0kB writeback_tmp:0kB pages_scanned:192 all_unreclaimable=
? no
> Dec 24 18:16:03 picchu kernel: lowmem_reserve[]: 0 0 0 0
> Dec 24 18:16:03 picchu kernel: DMA: 15*4kB 3*8kB 41*16kB 49*32kB 31*64kB =
13*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB =3D 8004kB
> Dec 24 18:16:03 picchu kernel: DMA32: 1129*4kB 14*8kB 8*16kB 2*32kB 0*64k=
B 0*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB =3D 5588kB
> Dec 24 18:16:03 picchu kernel: 316114 total pagecache pages
> Dec 24 18:16:03 picchu kernel: 0 pages in swap cache
> Dec 24 18:16:03 picchu kernel: Swap cache stats: add 11, delete 11, find =
1/3
> Dec 24 18:16:03 picchu kernel: Free swap  =3D 2048248kB
> Dec 24 18:16:03 picchu kernel: Total swap =3D 2048248kB
> Dec 24 18:16:03 picchu kernel: 521616 pages RAM
> Dec 24 18:16:03 picchu kernel: 9625 pages reserved
> Dec 24 18:16:03 picchu kernel: 382065 pages shared
> Dec 24 18:16:03 picchu kernel: 296585 pages non-shared
> Dec 24 18:16:03 picchu kernel: Out of memory: kill process 3418 (kdesktop=
) score 967315 or a child
> Dec 24 18:16:03 picchu kernel: Killed process 14144 (firefox)
>=20

We've seen similar issue recently. can you please try following patch?


-----------------------------------------------------------
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>

When do_nonlinear_fault() realizes that the page table must have been
corrupted for it to have been called, it does print_bad_pte() and returns
=2E..  VM_FAULT_OOM, which is hard to understand.

It made some sense when I did it for 2.6.15, when do_page_fault() just
killed the current process; but nowadays it lets the OOM killer decide who
to kill - so page table corruption in one process would be liable to kill
another.

Change it to return VM_FAULT_SIGBUS instead: that doesn't guarantee that
the process will be killed, but is good enough for such a rare
abnormality, accompanied as it is by the "BUG: Bad page map" message.

And recent HWPOISON work has copied that code into do_swap_page(), when it
finds an impossible swap entry: fix that to VM_FAULT_SIGBUS too.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Izik Eidus <ieidus@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Nick Piggin <npiggin@suse.de>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <andi@firstfloor.org>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memory.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN mm/memory.c~mm-sigbus-instead-of-abusing-oom mm/memory.c
--- a/mm/memory.c~mm-sigbus-instead-of-abusing-oom
+++ a/mm/memory.c
@@ -2527,7 +2527,7 @@ static int do_swap_page(struct mm_struct
 			ret =3D VM_FAULT_HWPOISON;
 		} else {
 			print_bad_pte(vma, address, orig_pte, NULL);
-			ret =3D VM_FAULT_OOM;
+			ret =3D VM_FAULT_SIGBUS;
 		}
 		goto out;
 	}
@@ -2923,7 +2923,7 @@ static int do_nonlinear_fault(struct mm_
 		 * Page table corrupted: show pte and kill process.
 		 */
 		print_bad_pte(vma, address, orig_pte, NULL);
-		return VM_FAULT_OOM;
+		return VM_FAULT_SIGBUS;
 	}
=20
 	pgoff =3D pte_to_pgoff(orig_pte);
_




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
