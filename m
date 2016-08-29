Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D307583102
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 10:52:24 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 33so99737332lfw.1
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 07:52:24 -0700 (PDT)
Received: from mo6-p00-ob.smtp.rzone.de (mo6-p00-ob.smtp.rzone.de. [2a01:238:20a:202:5300::5])
        by mx.google.com with ESMTPS id gz2si32413566wjc.141.2016.08.29.07.52.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 07:52:23 -0700 (PDT)
Date: Mon, 29 Aug 2016 16:52:03 +0200
From: Olaf Hering <olaf@aepfle.de>
Subject: Re: OOM detection regressions since 4.7
Message-ID: <20160829145203.GA30660@aepfle.de>
References: <20160822093249.GA14916@dhcp22.suse.cz>
 <20160822093707.GG13596@dhcp22.suse.cz>
 <20160822100528.GB11890@kroah.com>
 <20160822105441.GH13596@dhcp22.suse.cz>
 <20160822133114.GA15302@kroah.com>
 <20160822134227.GM13596@dhcp22.suse.cz>
 <20160822150517.62dc7cce74f1af6c1f204549@linux-foundation.org>
 <20160823074339.GB23577@dhcp22.suse.cz>
 <20160825071103.GC4230@dhcp22.suse.cz>
 <20160825071728.GA3169@aepfle.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="r5Pyd7+fXNt84Ff3"
Content-Disposition: inline
In-Reply-To: <20160825071728.GA3169@aepfle.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Greg KH <gregkh@linuxfoundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 25, Olaf Hering wrote:

> On Thu, Aug 25, Michal Hocko wrote:
>=20
> > Any luck with the testing of this patch?

I ran rc3 for a few hours on Friday amd FireFox was not killed.
Now rc3 is running for a day with the usual workload and FireFox is
still running.

Today I noticed the nfsserver was disabled, probably since months already.
Starting it gives a OOM, not sure if this is new with 4.7+.
Full dmesg attached.


[    0.000000] Linux version 4.8.0-rc3-3.bug994066-default (geeko@buildhost=
) (gcc version 6.1.1 20160815 [gcc-6-branch revision 239479] (SUSE Linux) )=
 #1 SMP PREEMPT Mon Aug 22 14:52:18 UTC 2016 (c0d2ef5)

[64378.582489] tun: Universal TUN/TAP device driver, 1.6
[64378.582493] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[93347.645123] RPC: Registered named UNIX socket transport module.
[93347.645128] RPC: Registered udp transport module.
[93347.645130] RPC: Registered tcp transport module.
[93347.645132] RPC: Registered tcp NFSv4.1 backchannel transport module.
[93348.227828] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[93348.306369] modprobe: page allocation failure: order:4, mode:0x26040c0(G=
FP_KERNEL|__GFP_COMP|__GFP_NOTRACK)
[93348.306379] CPU: 2 PID: 30467 Comm: modprobe Not tainted 4.8.0-rc3-3.bug=
994066-default #1
[93348.306382] Hardware name: Hewlett-Packard HP ProBook 6555b/1455, BIOS 6=
8DTM Ver. F.21 06/14/2012
[93348.306386]  0000000000000000 ffffffff813a2952 0000000000000004 ffff8800=
3fb6ba30
[93348.306394]  ffffffff81198a4b 026040c00000000f 026040c000000001 ffff8800=
3fb6c000
[93348.306400]  0000000000000004 ffff88003fb6baac 00000000026040c0 00000000=
00000040
[93348.306406] Call Trace:
[93348.306437]  [<ffffffff8102eefe>] dump_trace+0x5e/0x310
[93348.306449]  [<ffffffff8102f2cb>] show_stack_log_lvl+0x11b/0x1a0
[93348.306459]  [<ffffffff81030001>] show_stack+0x21/0x40
[93348.306468]  [<ffffffff813a2952>] dump_stack+0x5c/0x7a
[93348.306478]  [<ffffffff81198a4b>] warn_alloc_failed+0xdb/0x150
[93348.306490]  [<ffffffff81198cef>] __alloc_pages_slowpath+0x1af/0xa10
[93348.306501]  [<ffffffff811997a0>] __alloc_pages_nodemask+0x250/0x290
[93348.306511]  [<ffffffff811f1c3d>] cache_grow_begin+0x8d/0x540
[93348.306520]  [<ffffffff811f23d1>] fallback_alloc+0x161/0x200
[93348.306530]  [<ffffffff811f43f2>] __kmalloc+0x1d2/0x570
[93348.306589]  [<ffffffffa08f025a>] nfsd_reply_cache_init+0xaa/0x110 [nfsd]
[93348.306649]  [<ffffffffa093f1b6>] init_nfsd+0x56/0xea0 [nfsd]
[93348.306664]  [<ffffffff8100218b>] do_one_initcall+0x4b/0x180
[93348.306674]  [<ffffffff8118e119>] do_init_module+0x5b/0x1fe
[93348.306684]  [<ffffffff81105395>] load_module+0x1a75/0x1d00
[93348.306695]  [<ffffffff81105804>] SYSC_finit_module+0xa4/0xe0
[93348.306705]  [<ffffffff816d2cb6>] entry_SYSCALL_64_fastpath+0x1e/0xa8
[93348.313626] DWARF2 unwinder stuck at entry_SYSCALL_64_fastpath+0x1e/0xa8

[93348.313629] Leftover inexact backtrace:

[93348.313691] Mem-Info:
[93348.313704] active_anon:467209 inactive_anon:125491 isolated_anon:0
                active_file:264880 inactive_file:166389 isolated_file:0
                unevictable:8 dirty:250 writeback:0 unstable:0
                slab_reclaimable:796425 slab_unreclaimable:34803
                mapped:54783 shmem:24119 pagetables:9083 bounce:0
                free:51321 free_pcp:68 free_cma:0
[93348.313717] Node 0 active_anon:1868836kB inactive_anon:501964kB active_f=
ile:1059520kB inactive_file:665556kB unevictable:32kB isolated(anon):0kB is=
olated(file):0kB mapped:219132kB dirty:1000kB writeback:0kB shmem:0kB shmem=
_thp: 0kB shmem_pmdmapped: 749568kB anon_thp: 96476kB writeback_tmp:0kB uns=
table:0kB pages_scanned:24 all_unreclaimable? no
[93348.313719] Node 0 DMA free:15908kB min:136kB low:168kB high:200kB activ=
e_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:=
0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB slab_recla=
imable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0k=
B free_pcp:0kB local_pcp:0kB free_cma:0kB
[93348.313729] lowmem_reserve[]: 0 2626 7621 7621 7621
[93348.313745] Node 0 DMA32 free:133192kB min:23244kB low:29052kB high:3486=
0kB active_anon:642152kB inactive_anon:119848kB active_file:257900kB inacti=
ve_file:116560kB unevictable:0kB writepending:292kB present:2847412kB manag=
ed:2766832kB mlocked:0kB slab_reclaimable:1418576kB slab_unreclaimable:3900=
4kB kernel_stack:256kB pagetables:1448kB bounce:0kB free_pcp:128kB local_pc=
p:0kB free_cma:0kB
[93348.313755] lowmem_reserve[]: 0 0 4994 4994 4994
[93348.313762] Node 0 Normal free:56184kB min:44200kB low:55248kB high:6629=
6kB active_anon:1226576kB inactive_anon:382200kB active_file:801508kB inact=
ive_file:548992kB unevictable:32kB writepending:536kB present:5242880kB man=
aged:5114880kB mlocked:32kB slab_reclaimable:1767124kB slab_unreclaimable:1=
00208kB kernel_stack:9104kB pagetables:34884kB bounce:0kB free_pcp:144kB lo=
cal_pcp:0kB free_cma:0kB
[93348.313771] lowmem_reserve[]: 0 0 0 0 0
[93348.313778] Node 0 DMA: 1*4kB (U) 0*8kB 0*16kB 1*32kB (U) 2*64kB (U) 1*1=
28kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) =3D 159=
08kB
[93348.313803] Node 0 DMA32: 13633*4kB (UME) 8035*8kB (UME) 890*16kB (UME) =
10*32kB (U) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 1=
33372kB
[93348.313822] Node 0 Normal: 14003*4kB (UME) 25*8kB (UME) 2*16kB (UM) 0*32=
kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 56244kB
[93348.313843] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_surp=
=3D0 hugepages_size=3D1048576kB
[93348.313846] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_surp=
=3D0 hugepages_size=3D2048kB
[93348.313848] 457622 total pagecache pages
[93348.313850] 2194 pages in swap cache
[93348.313853] Swap cache stats: add 60025, delete 57831, find 17283/19516
[93348.313854] Free swap  =3D 8170356kB
[93348.313856] Total swap =3D 8384508kB
[93348.313858] 2026571 pages RAM
[93348.313859] 0 pages HighMem/MovableOnly
[93348.313860] 52166 pages reserved
[93348.313861] 0 pages hwpoisoned
[93348.313865] nfsd: failed to allocate reply cache

Olaf

--r5Pyd7+fXNt84Ff3
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEARECAAYFAlfETAgACgkQXUKg+qaYNn64UgCgp6crqzc56pYUBuKJAJ2UD/lU
wskAmwV73qidoKukC/59OYYf7H7k1COe
=KS7/
-----END PGP SIGNATURE-----

--r5Pyd7+fXNt84Ff3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
