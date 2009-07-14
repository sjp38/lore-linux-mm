Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0538D6B005D
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 01:11:57 -0400 (EDT)
Received: by gxk3 with SMTP id 3so4654312gxk.14
        for <linux-mm@kvack.org>; Mon, 13 Jul 2009 22:40:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090713134621.124aa18e.skraw@ithnet.com>
References: <20090713134621.124aa18e.skraw@ithnet.com>
Date: Mon, 13 Jul 2009 22:40:39 -0700
Message-ID: <4807377b0907132240g6f74c9cbnf1302d354a0e0a72@mail.gmail.com>
Subject: Re: What to do with this message (2.6.30.1) ?
From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Stephan von Krawczynski <skraw@ithnet.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 13, 2009 at 4:46 AM, Stephan von Krawczynski
<skraw@ithnet.com> wrote:
>
> Hello all,
>
> first day of using 2.6.30.1 on a box that mostly accepts rsync connection=
s
> revealed this message. This is in fact not the only one of this type. Qui=
te
> a lot from other processes follow. What can I do to prevent that? Is that
> a kind of a bug?
> I did not experience that on a box with the same job using tg3 instead of
> e1000e.
>
> Jul 13 01:10:57 backup kernel: swapper: page allocation failure. order:0,=
 mode:0x20
> Jul 13 01:10:57 backup kernel: Pid: 0, comm: swapper Not tainted 2.6.30.1=
 #3
> Jul 13 01:10:57 backup kernel: Call Trace:
> Jul 13 01:10:57 backup kernel: =A0<IRQ> =A0[<ffffffff80269182>] ? __alloc=
_pages_internal+0x3df/0x3ff
> Jul 13 01:10:57 backup kernel: =A0[<ffffffff802876cf>] ? cache_alloc_refi=
ll+0x25e/0x4a0
> Jul 13 01:10:57 backup kernel: =A0[<ffffffff803eb067>] ? sock_def_readabl=
e+0x10/0x62
> Jul 13 01:10:57 backup kernel: =A0[<ffffffff8028798a>] ? __kmalloc+0x79/0=
xa1
> Jul 13 01:10:57 backup kernel: =A0[<ffffffff803ef98a>] ? __alloc_skb+0x5c=
/0x12a
> Jul 13 01:10:57 backup kernel: =A0[<ffffffff803f0558>] ? __netdev_alloc_s=
kb+0x15/0x2f
> Jul 13 01:10:57 backup kernel: =A0[<ffffffffa000cda0>] ? e1000_alloc_rx_b=
uffers+0x8c/0x248 [e1000e]
> Jul 13 01:10:57 backup kernel: =A0[<ffffffffa000d262>] ? e1000_clean_rx_i=
rq+0x2a2/0x2db [e1000e]
> Jul 13 01:10:57 backup kernel: =A0[<ffffffffa000e8dc>] ? e1000_clean+0x70=
/0x219 [e1000e]
> Jul 13 01:10:57 backup kernel: =A0[<ffffffff803f3adf>] ? net_rx_action+0x=
69/0x11f
> Jul 13 01:10:58 backup kernel: =A0[<ffffffff802373eb>] ? __do_softirq+0x6=
6/0xf7
> Jul 13 01:10:58 backup kernel: =A0[<ffffffff8020bebc>] ? call_softirq+0x1=
c/0x28
> Jul 13 01:10:58 backup kernel: =A0[<ffffffff8020d680>] ? do_softirq+0x2c/=
0x68
> Jul 13 01:10:58 backup kernel: =A0[<ffffffff8020cf62>] ? do_IRQ+0xa9/0xbf
> Jul 13 01:10:58 backup kernel: =A0[<ffffffff8020b793>] ? ret_from_intr+0x=
0/0xa
> Jul 13 01:10:58 backup kernel: =A0<EOI> =A0[<ffffffff802116d8>] ? mwait_i=
dle+0x6e/0x73
> Jul 13 01:10:58 backup kernel: =A0[<ffffffff802116d8>] ? mwait_idle+0x6e/=
0x73
> Jul 13 01:10:58 backup kernel: =A0[<ffffffff8020a1cb>] ? cpu_idle+0x40/0x=
7c
> Jul 13 01:10:58 backup kernel: =A0[<ffffffff805a7bb0>] ? start_kernel+0x3=
1e/0x32a
> Jul 13 01:10:58 backup kernel: =A0[<ffffffff805a737e>] ? x86_64_start_ker=
nel+0xe5/0xeb
> Jul 13 01:10:58 backup kernel: DMA per-cpu:
> Jul 13 01:10:58 backup kernel: CPU =A0 =A00: hi: =A0 =A00, btch: =A0 1 us=
d: =A0 0
> Jul 13 01:10:58 backup kernel: CPU =A0 =A01: hi: =A0 =A00, btch: =A0 1 us=
d: =A0 0
> Jul 13 01:10:58 backup kernel: CPU =A0 =A02: hi: =A0 =A00, btch: =A0 1 us=
d: =A0 0
> Jul 13 01:10:58 backup kernel: CPU =A0 =A03: hi: =A0 =A00, btch: =A0 1 us=
d: =A0 0
> Jul 13 01:10:58 backup kernel: DMA32 per-cpu:
> Jul 13 01:10:58 backup kernel: CPU =A0 =A00: hi: =A0186, btch: =A031 usd:=
 130
> Jul 13 01:10:58 backup kernel: CPU =A0 =A01: hi: =A0186, btch: =A031 usd:=
 =A090
> Jul 13 01:10:59 backup kernel: CPU =A0 =A02: hi: =A0186, btch: =A031 usd:=
 142
> Jul 13 01:10:59 backup kernel: CPU =A0 =A03: hi: =A0186, btch: =A031 usd:=
 177
> Jul 13 01:10:59 backup kernel: Normal per-cpu:
> Jul 13 01:10:59 backup kernel: CPU =A0 =A00: hi: =A0186, btch: =A031 usd:=
 =A076
> Jul 13 01:10:59 backup kernel: CPU =A0 =A01: hi: =A0186, btch: =A031 usd:=
 160
> Jul 13 01:10:59 backup kernel: CPU =A0 =A02: hi: =A0186, btch: =A031 usd:=
 170
> Jul 13 01:10:59 backup kernel: CPU =A0 =A03: hi: =A0186, btch: =A031 usd:=
 165
> Jul 13 01:10:59 backup kernel: Active_anon:117688 active_file:169003 inac=
tive_anon:22048
> Jul 13 01:10:59 backup kernel: =A0inactive_file:1425813 unevictable:0 dir=
ty:337125 writeback:4493 unstable:0
> Jul 13 01:10:59 backup kernel: =A0free:8260 slab:297474 mapped:1475 paget=
ables:1685 bounce:0
> Jul 13 01:11:00 backup kernel: DMA free:11712kB min:12kB low:12kB high:16=
kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unev=
ictable:0kB present:10756kB pages_scanned:0 all_unreclaimable? yes
> Jul 13 01:11:00 backup kernel: lowmem_reserve[]: 0 3767 8059 8059
> Jul 13 01:11:00 backup kernel: DMA32 free:19060kB min:5364kB low:6704kB h=
igh:8044kB active_anon:180632kB inactive_anon:38496kB active_file:318456kB =
inactive_file:2581460kB unevictable:0kB present:3857440kB pages_scanned:0 a=
ll_unreclaimable? no
> Jul 13 01:11:00 backup kernel: lowmem_reserve[]: 0 0 4292 4292
> Jul 13 01:11:00 backup kernel: Normal free:2268kB min:6112kB low:7640kB h=
igh:9168kB active_anon:290120kB inactive_anon:49696kB active_file:357556kB =
inactive_file:3121792kB unevictable:0kB present:4395520kB pages_scanned:0 a=
ll_unreclaimable? no
> Jul 13 01:11:00 backup kernel: lowmem_reserve[]: 0 0 0 0
> Jul 13 01:11:00 backup kernel: DMA: 6*4kB 3*8kB 3*16kB 3*32kB 4*64kB 2*12=
8kB 1*256kB 1*512kB 2*1024kB 0*2048kB 2*4096kB =3D 11712kB
> Jul 13 01:11:00 backup kernel: DMA32: 2720*4kB 2*8kB 1*16kB 0*32kB 1*64kB=
 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB =3D 19040kB
> Jul 13 01:11:00 backup kernel: Normal: 1*4kB 1*8kB 1*16kB 1*32kB 0*64kB 1=
*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB =3D 2236kB
> Jul 13 01:11:00 backup kernel: 1594864 total pagecache pages
> Jul 13 01:11:00 backup kernel: 9 pages in swap cache
> Jul 13 01:11:00 backup kernel: Swap cache stats: add 1047, delete 1038, f=
ind 0/0
> Jul 13 01:11:00 backup kernel: Free swap =A0=3D 2100300kB
> Jul 13 01:11:00 backup kernel: Total swap =3D 2104488kB

Try increasing /proc/sys/vm/min_free_kbytes

can you show some more of the messages?  I'm guessing you should
include linux-mm next time (I did this time)

are you running jumbo frames perhaps?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
