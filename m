Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 595EC6B0047
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 23:51:05 -0500 (EST)
Received: by qw-out-1920.google.com with SMTP id 5so118443qwc.44
        for <linux-mm@kvack.org>; Wed, 27 Jan 2010 20:51:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201001212017.00160.toralf.foerster@gmx.de>
References: <201001212017.00160.toralf.foerster@gmx.de>
Date: Thu, 28 Jan 2010 12:51:02 +0800
Message-ID: <2375c9f91001272051x3d2e89r24133c42f52082ea@mail.gmail.com>
Subject: Re: kernel error : 'find /proc/ -type f | xargs -n 1 head -c 10
	>/dev/null'
From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?Q?Toralf_F=C3=B6rster?= <toralf.foerster@gmx.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

2010/1/22 Toralf F=C3=B6rster <toralf.foerster@gmx.de>:
> I was inspired by http://article.gmane.org/gmane.linux.kernel/941115 .
>
> Running the command (se subject) as a normal user at a 2.6.32.4 kernel
> gives this in /var/log/messages:
>
> 2010-01-21T20:11:39.171+01:00 n22 kernel: head: page allocation failure. =
order:9, mode:0xd0


Hmm, it is suspecious that we need 2^9 pages for seq_file...


> 2010-01-21T20:11:39.171+01:00 n22 kernel: Pid: 2324, comm: head Not taint=
ed 2.6.32.4 #1
> 2010-01-21T20:11:39.171+01:00 n22 kernel: Call Trace:
> 2010-01-21T20:11:39.171+01:00 n22 kernel: [<c106e2cc>] ? __alloc_pages_no=
demask+0x4bc/0x5a0
> 2010-01-21T20:11:39.171+01:00 n22 kernel: [<c108cf5a>] ? cache_alloc_refi=
ll+0x2ba/0x510
> 2010-01-21T20:11:39.171+01:00 n22 kernel: [<c108d299>] ? __kmalloc+0xe9/0=
xf0
> 2010-01-21T20:11:39.171+01:00 n22 kernel: [<c10aa755>] ? seq_read+0x195/0=
x370
> 2010-01-21T20:11:39.171+01:00 n22 kernel: [<c10aa5c0>] ? seq_read+0x0/0x3=
70
> 2010-01-21T20:11:39.171+01:00 n22 kernel: [<c10cbb6f>] ? proc_reg_read+0x=
5f/0x90
> 2010-01-21T20:11:39.171+01:00 n22 kernel: [<c10cbb10>] ? proc_reg_read+0x=
0/0x90
> 2010-01-21T20:11:39.171+01:00 n22 kernel: [<c10927c5>] ? vfs_read+0xa5/0x=
190
> 2010-01-21T20:11:39.171+01:00 n22 kernel: [<c1092981>] ? sys_read+0x41/0x=
80
> 2010-01-21T20:11:39.171+01:00 n22 kernel: [<c100300f>] ? sysenter_do_call=
+0x12/0x26
> 2010-01-21T20:11:39.171+01:00 n22 kernel: Mem-Info:
> 2010-01-21T20:11:39.171+01:00 n22 kernel: DMA per-cpu:
> 2010-01-21T20:11:39.172+01:00 n22 kernel: CPU =C2=A0 =C2=A00: hi: =C2=A0 =
=C2=A00, btch: =C2=A0 1 usd: =C2=A0 0
> 2010-01-21T20:11:39.172+01:00 n22 kernel: CPU =C2=A0 =C2=A01: hi: =C2=A0 =
=C2=A00, btch: =C2=A0 1 usd: =C2=A0 0
> 2010-01-21T20:11:39.172+01:00 n22 kernel: Normal per-cpu:
> 2010-01-21T20:11:39.172+01:00 n22 kernel: CPU =C2=A0 =C2=A00: hi: =C2=A01=
86, btch: =C2=A031 usd: =C2=A0 0
> 2010-01-21T20:11:39.172+01:00 n22 kernel: CPU =C2=A0 =C2=A01: hi: =C2=A01=
86, btch: =C2=A031 usd: =C2=A0 0
> 2010-01-21T20:11:39.172+01:00 n22 kernel: HighMem per-cpu:
> 2010-01-21T20:11:39.172+01:00 n22 kernel: CPU =C2=A0 =C2=A00: hi: =C2=A01=
86, btch: =C2=A031 usd: =C2=A0 0
> 2010-01-21T20:11:39.172+01:00 n22 kernel: CPU =C2=A0 =C2=A01: hi: =C2=A01=
86, btch: =C2=A031 usd: =C2=A0 0
> 2010-01-21T20:11:39.172+01:00 n22 kernel: active_anon:77374 inactive_anon=
:26716 isolated_anon:0
> 2010-01-21T20:11:39.172+01:00 n22 kernel: active_file:154367 inactive_fil=
e:77664 isolated_file:0
> 2010-01-21T20:11:39.172+01:00 n22 kernel: unevictable:0 dirty:74 writebac=
k:432 unstable:0
> 2010-01-21T20:11:39.172+01:00 n22 kernel: free:107209 slab_reclaimable:41=
314 slab_unreclaimable:3995
> 2010-01-21T20:11:39.172+01:00 n22 kernel: mapped:23759 shmem:19312 pageta=
bles:882 bounce:0
> 2010-01-21T20:11:39.172+01:00 n22 kernel: DMA free:12296kB min:64kB low:8=
0kB high:96kB active_anon:0kB inactive_anon:0kB active_file:772kB inactive_=
file:372kB unevictable:0kB
> isolated(anon):0kB isolated(file):0kB present:15864kB mlocked:0kB dirty:0=
kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:2520kB slab_unreclai=
mable:0kB kernel_stack:0kB pagetables:0kB
> unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimab=
le? no
> 2010-01-21T20:11:39.172+01:00 n22 kernel: lowmem_reserve[]: 0 865 1911 19=
11
> 2010-01-21T20:11:39.172+01:00 n22 kernel: Normal free:282076kB min:3728kB=
 low:4660kB high:5592kB active_anon:8kB inactive_anon:3320kB active_file:27=
9600kB inactive_file:121612kB
> unevictable:0kB isolated(anon):0kB isolated(file):0kB present:885944kB ml=
ocked:0kB dirty:140kB writeback:0kB mapped:276kB shmem:16kB slab_reclaimabl=
e:162736kB slab_unreclaimable:15980kB
> kernel_stack:900kB pagetables:3528kB unstable:0kB bounce:0kB writeback_tm=
p:0kB pages_scanned:0 all_unreclaimable? no
> 2010-01-21T20:11:39.172+01:00 n22 kernel: lowmem_reserve[]: 0 0 8369 8369
> 2010-01-21T20:11:39.172+01:00 n22 kernel: HighMem free:134464kB min:512kB=
 low:1636kB high:2764kB active_anon:309488kB inactive_anon:103544kB active_=
file:337096kB
> inactive_file:188672kB unevictable:0kB isolated(anon):0kB isolated(file):=
0kB present:1071256kB mlocked:0kB dirty:156kB writeback:1728kB mapped:94760=
kB shmem:77232kB slab_reclaimable:0kB
> slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounc=
e:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> 2010-01-21T20:11:39.172+01:00 n22 kernel: lowmem_reserve[]: 0 0 0 0
> 2010-01-21T20:11:39.172+01:00 n22 kernel: DMA: 288*4kB 121*8kB 80*16kB 62=
*32kB 48*64kB 22*128kB 4*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 12296=
kB
> 2010-01-21T20:11:39.172+01:00 n22 kernel: Normal: 19101*4kB 8755*8kB 3545=
*16kB 1846*32kB 186*64kB 34*128kB 2*256kB 2*512kB 0*1024kB 1*2048kB 0*4096k=
B =3D 282076kB

Obviously you have one 2^9-page chuck here, but page allocator doesn't
give this.


> 2010-01-21T20:11:39.172+01:00 n22 kernel: HighMem: 304*4kB 260*8kB 1594*1=
6kB 1644*32kB 571*64kB 89*128kB 18*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB=
 =3D 134464kB
> 2010-01-21T20:11:39.172+01:00 n22 kernel: 251864 total pagecache pages
> 2010-01-21T20:11:39.172+01:00 n22 kernel: 505 pages in swap cache
> 2010-01-21T20:11:39.172+01:00 n22 kernel: Swap cache stats: add 587, dele=
te 82, find 189/195
> 2010-01-21T20:11:39.172+01:00 n22 kernel: Free swap =C2=A0=3D 2001148kB
> 2010-01-21T20:11:39.172+01:00 n22 kernel: Total swap =3D 2003360kB
> 2010-01-21T20:11:39.172+01:00 n22 kernel: 498176 pages RAM
> 2010-01-21T20:11:39.172+01:00 n22 kernel: 270850 pages HighMem
> 2010-01-21T20:11:39.172+01:00 n22 kernel: 5979 pages reserved
> 2010-01-21T20:11:39.172+01:00 n22 kernel: 251238 pages shared
> 2010-01-21T20:11:39.172+01:00 n22 kernel: 209073 pages non-shared
> 2010-01-21T20:11:39.480+01:00 n22 kernel: ACPI: Please implement acpi_vid=
eo_bus_ROM_seq_show
>

For me, this seems to be either a problem of mm page allocator or a problem
of seq_file, the former seems to be more likely since we already got some o=
ther
page allocation failure report...

Adding linux-mm and linux-fs-devel into Cc...

Thanks for your report.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
