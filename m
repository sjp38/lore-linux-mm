Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 526EB6B004D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 11:49:10 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id l33so67624rvb.26
        for <linux-mm@kvack.org>; Tue, 30 Jun 2009 08:50:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090630140512.GA16923@localhost>
References: <20090628142239.GA20986@localhost>
	 <20090628151026.GB25076@localhost>
	 <20090629091741.ab815ae7.minchan.kim@barrios-desktop>
	 <17678.1246270219@redhat.com> <20090629125549.GA22932@localhost>
	 <29432.1246285300@redhat.com>
	 <28c262360906290800v37f91d7av3642b1ad8b5f0477@mail.gmail.com>
	 <30071.1246290885@redhat.com>
	 <1246291007.663.630.camel@macbook.infradead.org>
	 <20090630140512.GA16923@localhost>
Date: Wed, 1 Jul 2009 00:50:42 +0900
Message-ID: <28c262360906300850l402e2bb0xca14a2d0571eb3cf@mail.gmail.com>
Subject: Re: Found the commit that causes the OOMs
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@gmail.com>
Cc: David Woodhouse <dwmw2@infradead.org>, David Howells <dhowells@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 30, 2009 at 11:05 PM, Wu Fengguang<fengguang.wu@gmail.com> wrot=
e:
>
> More data: I boot 2.6.30-rc1 with mem=3D1G and enabled 1GB swap and run m=
sgctl11.
>
> It goes OOM at the 2nd run. They are very interesting numbers: memory lea=
ked?

Hmm. It's very serious and another problem since this system have swap
device and it's not full.

Can you reproduce it easily ?

I want to reproduce it in my system.

Did you ran only msgctl11 not all LTP test ?
Just default parameter ? ex) $ ./testcases/bin/msgctl11

2nd run ? You mean you execute msgctl11 two time in order ?
I mean after first test is finished successfully and OOM happens
second test before ending successfully ?


> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.825958] msgctl11 invoked oom-killer: gf=
p_mask=3D0x84d0, order=3D0, oom_adj=3D0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.828092] Pid: 29657, comm: msgctl11 Not =
tainted 2.6.31-rc1 #22
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.830505] Call Trace:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.832010] =C2=A0[<ffffffff8156f366>] ? _s=
pin_unlock+0x26/0x30
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.834219] =C2=A0[<ffffffff810c8b26>] oom_=
kill_process+0x176/0x270
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.837603] =C2=A0[<ffffffff810c8def>] ? ba=
dness+0x18f/0x300
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.839906] =C2=A0[<ffffffff810c9095>] __ou=
t_of_memory+0x135/0x170
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.842035] =C2=A0[<ffffffff810c91c5>] out_=
of_memory+0xf5/0x180
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.844270] =C2=A0[<ffffffff810cd86c>] __al=
loc_pages_nodemask+0x6ac/0x6c0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.846743] =C2=A0[<ffffffff810f8fa8>] allo=
c_pages_current+0x78/0x100
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.849083] =C2=A0[<ffffffff81033515>] pte_=
alloc_one+0x15/0x50
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.851282] =C2=A0[<ffffffff810e0eda>] __pt=
e_alloc+0x2a/0xf0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.853454] =C2=A0[<ffffffff810e16e2>] hand=
le_mm_fault+0x742/0x830
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.855793] =C2=A0[<ffffffff815725cb>] do_p=
age_fault+0x1cb/0x330
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.858033] =C2=A0[<ffffffff8156fdf5>] page=
_fault+0x25/0x30
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.860301] Mem-Info:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.861706] Node 0 DMA per-cpu:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.862523] CPU =C2=A0 =C2=A00: hi: =C2=A0 =
=C2=A00, btch: =C2=A0 1 usd: =C2=A0 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.864454] CPU =C2=A0 =C2=A01: hi: =C2=A0 =
=C2=A00, btch: =C2=A0 1 usd: =C2=A0 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.866608] Node 0 DMA32 per-cpu:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.867404] CPU =C2=A0 =C2=A00: hi: =C2=A01=
86, btch: =C2=A031 usd: 197
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.869283] CPU =C2=A0 =C2=A01: hi: =C2=A01=
86, btch: =C2=A031 usd: 175
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.870511] Active_anon:0 active_file:11 in=
active_anon:0
>
> zero anon pages!
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.870512] =C2=A0inactive_file:0 unevictab=
le:0 dirty:0 writeback:0 unstable:0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.870513] =C2=A0free:1986 slab:42170 mapp=
ed:96 pagetables:59427 bounce:0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.877722] Node 0 DMA free:3976kB min:56kB=
 low:68kB high:84kB active_anon:0kB inactive_anon:0kB active_file:0kB inact=
ive_file:0kB unevictable:0kB present:15164kB pages_scanned:429 all_unreclai=
mable? no
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.883804] lowmem_reserve[]: 0 982 982 982
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.885814] Node 0 DMA32 free:3968kB min:39=
80kB low:4972kB high:5968kB active_anon:0kB inactive_anon:0kB active_file:4=
4kB inactive_file:0kB unevictable:0kB present:1005984kB pages_scanned:152 a=
ll_unreclaimable? no
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.890958] lowmem_reserve[]: 0 0 0 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.893183] Node 0 DMA: 4*4kB 3*8kB 2*16kB =
0*32kB 1*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB =3D 3976kB
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.897406] Node 0 DMA32: 334*4kB 77*8kB 24=
*16kB 27*32kB 10*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =
=3D 3968kB
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.902753] 625 total pagecache pages
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.903623] 454 pages in swap cache
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.905299] Swap cache stats: add 95129, de=
lete 94675, find 55783/67607
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.908858] Free swap =C2=A0=3D 1041232kB
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.909618] Total swap =3D 1048568kB
>
> swap far from full!
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.919456] 262144 pages RAM
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.921071] 12513 pages reserved
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.922790] 314212 pages shared
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.923548] 165757 pages non-shared
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.925234] Out of memory: kill process 207=
91 (msgctl11) score 2280094 or a child
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[ 2259.928982] Killed process 21946 (msgctl11)
>
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
