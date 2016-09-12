Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id DB0186B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 02:36:41 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id e1so249460072itb.0
        for <linux-mm@kvack.org>; Sun, 11 Sep 2016 23:36:41 -0700 (PDT)
Received: from mail-it0-x22b.google.com (mail-it0-x22b.google.com. [2607:f8b0:4001:c0b::22b])
        by mx.google.com with ESMTPS id n6si17925459itd.33.2016.09.11.23.36.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Sep 2016 23:36:40 -0700 (PDT)
Received: by mail-it0-x22b.google.com with SMTP id r192so2951068ita.0
        for <linux-mm@kvack.org>; Sun, 11 Sep 2016 23:36:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <004c01d20cbc$b429a9e0$1c7cfda0$@samsung.com>
References: <CGME20160910115611epcas5p27310a0c2f05290b5c3642f82c045554e@epcas5p2.samsung.com>
 <9250e22a60af484cbede7a1ba34ada5e@POCITMSXMB04.LntUniverse.com>
 <003e01d20cb2$a0a007c0$e1e01740$@samsung.com> <004c01d20cbc$b429a9e0$1c7cfda0$@samsung.com>
From: Adarsh Sharma <eddy.adarsh@gmail.com>
Date: Mon, 12 Sep 2016 12:06:20 +0530
Message-ID: <CAGx-QqLo-fc9enRjBe60Pq--39QBM+-B_VSpcAp1_e_uqNYD4Q@mail.gmail.com>
Subject: Re: Memory fragmentation issue related suggestion request
Content-Type: multipart/alternative; boundary=001a113eaff6fcb09f053c49b739
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu.k@samsung.com>
Cc: Ankur.Tank@lnttechservices.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, artfri2@gmail.com

--001a113eaff6fcb09f053c49b739
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi Pintu,

I am also looking for a mailing list where we can share memory related
issues at kernel level. I tried subscribing to that mailing list but it
says Invalid ID :

>>>> --001a11436926db8726053c49ac67
**** Command '--001a11436926db8726053c49ac67' not recognized.
>>>> Content-Type: text/plain; charset=3DUTF-8
**** Command 'content-type:' not recognized.
>>>>
>>>> subscribe linux-mm@kvack.org
**** subscribe: unknown list 'linux-mm@kvack.org'.

Thanks

On Mon, Sep 12, 2016 at 11:42 AM, PINTU KUMAR <pintu.k@samsung.com> wrote:

> Dear Ankur,
>
> I would suggest you register to linux-mm@kvack.org and explain your
> issues in details.
> There are other experts here, who can guide you.
>
> Few comments are inline below.
>
> > From: Ankur Tank [mailto:Ankur.Tank@LntTechservices.com]
> > Sent: Saturday, September 10, 2016 5:26 PM
> > To: pintu.k@samsung.com
> > Cc: artfri2@gmail.com
> > Subject: Memory fragmentation issue related suggestion request
> >
> > Hello Pintukumar,
> >
> > TL;DR
> > We have an issue in our Linux box, what looks like memory fragmentation
> issue,
> > while searching on net I referred talk you gave in Embedded Linux Conf.
> I have several talks in ELC, not sure which one you are referring to.
> Please point out.
>
> > I am facing this issue for couple of weeks so thought to ask you for
> suggestions.
> > Please forgive me If I offended you by writing mail to you, Ignore mail
> if you feel so.
> >
> > Details
> > We are facing one issue in our Embedded Linux board, Our board is
> Beaglebone
> > black based custom board, with 4GB eMMC as storage. We are using Linux
> kernel
> > 3.12.
> In addition, you may need to provide the following information:
> RAM size ?
> cat /proc/meminfo  (before and after the operation)
> cat /proc/buddyinfo (before and after the operation)
> cat /proc/vmstat (before and after the operation)
>
> > Our firmware upgrade strategy is using backgup partition for Bootloader=
,
> Kernel,
> > dtb, rootfs.
> > So,
> > During firmware upgrade with big rootfs and running dd to read the
> partition in raw
> > mode.
> > In short looks like those operations are overloading the system.
> >
> I am not sure, but I think this is the crude way of taking the backup.
> This will certainly overload your system.
> FOTA upgrade experts can give more comments here.
>
> > From below log looks like pages above 32KB size is not available and ma=
y
> be
> > because of that rootfs tar on the emmc is failing.
> > I have following queries in that regards,
> >
> > 1.       Do you think it is a memory fragmentation ?
> Yes, if all above 32KB (2^3 order) pages are not available, and pages are
> available in lower orders (2^0/1/2) then its certainly fragmentation
> problem.
> However, as I said, you need to provide the following output to confirm:
> cat /proc/buddyinfo
>
> > May be silly to ask so but just to confirm, because I had added the
> software swap
> > however with that also we were seeing issue reproducible and swap was
> not full at
> > that time =E2=98=B9
> >
> Well, adding swap should help a bit but it may not solve the problem
> completely.
> How much swap did you actually allocated?
> What kind of swap you used ?
> Is it ZRAM/ZSWAP (with compression support) ?
> What is the swappiness ratio ? (/proc/sys/vm/swappiness)
>
> > 2.       If it is so how do we handle it ? is there a some way similar
> to your shrinker
> > utility to reclaim the memory pages ?
> >
> Not sure which shrinker utility are you referring to ?
> Is it : /proc/sys/vm/shrink_memory ?
>
> > Any suggestion would help me move forward,
> >
> Did you tried enabling CONFIG_COMPACTION ?
> Try using ZRAM or ZSWAP (~30% of MemTotal).
> Try tuning : /proc/sys/vm/dirty_{background_ratio/bytes} and others.
> [Refer kernel/documentation for the same]
>
> From the logs, I observed the following:
> > [ 6676.674219] mmcqd/1: page allocation failure: order:1, mode:0x200020
> Order-1 allocation is failing, so pages might be sitting in order-0.
> > [ 6676.674739]  free_cma:1982
> You have around ~7MB of CMA free pages, so this cannot be used for
> non-movable allocation.
> > [ 6676.674885] 51661 total pagecache pages
> You have huge amount of memory sitting in caches. These can be reclaimed
> in back ground (with slight performance degradation).
> To experiment and debug you can try: echo 3 > /proc/sys/vm/drop_caches
> > [ 6676.674925] Total swap =3D 0kB
> Swap is not enabled on your system.
>
>
> > Regards,
> > Ankur
> >
> > Error log
> > ----------------------------
> >
> > [ 6676.674219] mmcqd/1: page allocation failure: order:1, mode:0x200020
> >    [ 6676.674256] CPU: 0 PID: 612 Comm: mmcqd/1 Tainted: P           O
> 3.12.10-005-
> > ts-armv7l #2
> >     [ 6676.674321] [<c0012d24>] (unwind_backtrace+0x0/0xf4) from
> [<c0011130>]
> > (show_stack+0x10/0x14)
> >     [ 6676.674355] [<c0011130>] (show_stack+0x10/0x14) from [<c0087548>=
]
> > (warn_alloc_failed+0xe0/0x118)
> >     [ 6676.674383] [<c0087548>] (warn_alloc_failed+0xe0/0x118) from
> [<c008a3ac>]
> > (__alloc_pages_nodemask+0x74c/0x8f8)
> >     [ 6676.674413] [<c008a3ac>] (__alloc_pages_nodemask+0x74c/0x8f8)
> from
> > [<c00b2e8c>] (cache_alloc_refill+0x328/0x620)
> >     [ 6676.674436] [<c00b2e8c>] (cache_alloc_refill+0x328/0x620) from
> > [<c00b3224>] (__kmalloc+0xa0/0xe8)
> >     [ 6676.674471] [<c00b3224>] (__kmalloc+0xa0/0xe8) from [<c0212904>]
> > (edma_prep_slave_sg+0x84/0x388)
> >     [ 6676.674505] [<c0212904>] (edma_prep_slave_sg+0x84/0x388) from
> > [<c02ec0a0>] (omap_hsmmc_request+0x414/0x508)
> >     [ 6676.674544] [<c02ec0a0>] (omap_hsmmc_request+0x414/0x508) from
> > [<c02d6748>] (mmc_start_request+0xc4/0xe0)
> >     [ 6676.674568] [<c02d6748>] (mmc_start_request+0xc4/0xe0) from
> > [<c02d7530>] (mmc_start_req+0x2d8/0x38c)
> >     [ 6676.674589] [<c02d7530>] (mmc_start_req+0x2d8/0x38c) from
> [<c02e4818>]
> > (mmc_blk_issue_rw_rq+0xb4/0x9d8)
> >     [ 6676.674611] [<c02e4818>] (mmc_blk_issue_rw_rq+0xb4/0x9d8) from
> > [<c02e52e0>] (mmc_blk_issue_rq+0x1a4/0x468)
> >     [ 6676.674631] [<c02e52e0>] (mmc_blk_issue_rq+0x1a4/0x468) from
> > [<c02e5c68>] (mmc_queue_thread+0x88/0x118)
> >     [ 6676.674657] [<c02e5c68>] (mmc_queue_thread+0x88/0x118) from
> > [<c004d8b8>] (kthread+0xb4/0xb8)
> >     [ 6676.674681] [<c004d8b8>] (kthread+0xb4/0xb8) from [<c000e298>]
> > (ret_from_fork+0x14/0x3c)
> >     [ 6676.674691] Mem-info:
> >     [ 6676.674700] Normal per-cpu:
> >     [ 6676.674711] CPU    0: hi:   90, btch:  15 usd:  79
> >     [ 6676.674739] active_anon:4889 inactive_anon:13 isolated_anon:0
> >     [ 6676.674739]  active_file:8082 inactive_file:43196 isolated_file:=
0
> >     [ 6676.674739]  unevictable:422 dirty:2 writeback:1152 unstable:0
> >     [ 6676.674739]  free:3286 slab_reclaimable:1090
> slab_unreclaimable:915
> >     [ 6676.674739]  mapped:1593 shmem:39 pagetables:181 bounce:0
> >     [ 6676.674739]  free_cma:1982
> >     [ 6676.674800] Normal free:13144kB min:2004kB low:2504kB high:3004k=
B
> > active_anon:19556kB inactive_anon:52kB active_file:32328kB
> > inactive_file:172784kB unevictable:o
> >     [ 6676.674813] lowmem_reserve[]: 0 0 0
> >     [ 6676.674831] Normal: 2584*4kB (UMC) 217*8kB (C) 57*16kB (C) 5*32k=
B
> (C)
> > 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB 0*8192kB =3D
> > 13144kB
> >     [ 6676.674885] 51661 total pagecache pages
> >     [ 6676.674900] 0 pages in swap cache
> >     [ 6676.674910] Swap cache stats: add 0, delete 0, find 0/0
> >     [ 6676.674918] Free swap  =3D 0kB
> >     [ 6676.674925] Total swap =3D 0kB
> >     [ 6676.674938] SLAB: Unable to allocate memory on node 0 (gfp=3D0x2=
0)
> >     [ 6676.674949]   cache: kmalloc-8192, object size: 8192, order: 1
> >     [ 6676.674962]   node 0: slabs: 3/3, objs: 3/3, free: 0
> >     [ 6676.674984] omap_hsmmc 481d8000.mmc: prep_slave_sg() failed
> >     [ 6676.674997] omap_hsmmc 481d8000.mmc: MMC start dma failure
> >     [ 6676.676181] mmcblk0: unknown error -1 sending read/write command=
,
> card
> > status 0x900
> >     [ 6676.676300] end_request: I/O error, dev mmcblk0, sector 27648
> >     [ 6676.676318] Buffer I/O error on device mmcblk0p9, logical block
> 896
> >     [ 6676.676329] lost page write due to I/O error on mmcblk0p9
> >     [ 6676.676401] end_request: I/O error, dev mmcblk0, sector 27656
> >     [ 6676.676415] Buffer I/O error on device mmcblk0p9, logical block
> 897
> >     [ 6676.676425] lost page write due to I/O error on mmcblk0p9
> >     [ 6676.676450] end_request: I/O error, dev mmcblk0, sector 27664
> >     [ 6676.676461] Buffer I/O error on device mmcblk0p9, logical block
> 898
> >     [ 6676.676471] lost page write due to I/O error on mmcblk0p9
> >     [ 6676.676494] end_request: I/O error, dev mmcblk0, sector 27672
> >     [ 6676.676505] Buffer I/O error on device mmcblk0p9, logical block
> 899
> >     [ 6676.676515] lost page write due to I/O error on mmcblk0p9
> >     [ 6676.676537] end_request: I/O error, dev mmcblk0, sector 27680
> >     [ 6676.676548] Buffer I/O error on device mmcblk0p9, logical block
> 900
> >     [ 6676.676558] lost page write due to I/O error on mmcblk0p9
> >     [ 6676.676580] end_request: I/O error, dev mmcblk0, sector 27688
> >     [ 6676.676591] Buffer I/O error on device mmcblk0p9, logical block
> 901
> >     [ 6676.676601] lost page write due to I/O error on mmcblk0p9
> >     [ 6676.676622] end_request: I/O error, dev mmcblk0, sector 27696
> >     [ 6676.676634] Buffer I/O error on device mmcblk0p9, logical block
> 902
> >     [ 6676.676643] lost page write due to I/O error on mmcblk0p9
> >     [ 6676.676665] end_request: I/O error, dev mmcblk0, sector 27704
> >     [ 6676.676676] Buffer I/O error on device mmcblk0p9, logical block
> 903
> >     [ 6676.676685] lost page write due to I/O error on mmcblk0p9
> >     [ 6676.676707] end_request: I/O error, dev mmcblk0, sector 27712
> >     [ 6676.676718] Buffer I/O error on device mmcblk0p9, logical block
> 904
> >     [ 6676.676728] lost page write due to I/O error on mmcblk0p9
> >     [ 6676.676749] end_request: I/O error, dev mmcblk0, sector 27720
> >     [ 6676.678266] mmcqd/1: page allocation failure: order:1,
> mode:0x200020
> >     [ 6676.678285] CPU: 0 PID: 612 Comm: mmcqd/1 Tainted: P           O
> 3.12.10-005-
> > ts-armv7l #2
> >     [ 6676.678330] [<c0012d24>] (unwind_backtrace+0x0/0xf4) from
> [<c0011130>]
> > (show_stack+0x10/0x14)
> >     [ 6676.678358] [<c0011130>] (show_stack+0x10/0x14) from [<c0087548>=
]
> > (warn_alloc_failed+0xe0/0x118)
> >     [ 6676.678385] [<c0087548>] (warn_alloc_failed+0xe0/0x118) from
> [<c008a3ac>]
> > (__alloc_pages_nodemask+0x74c/0x8f8)
> >     [ 6676.678412] [<c008a3ac>] (__alloc_pages_nodemask+0x74c/0x8f8)
> from
> > [<c00b2e8c>] (cache_alloc_refill+0x328/0x620)
> >     [ 6676.678434] [<c00b2e8c>] (cache_alloc_refill+0x328/0x620) from
> > [<c00b3224>] (__kmalloc+0xa0/0xe8)
> >     [ 6676.678464] [<c00b3224>] (__kmalloc+0xa0/0xe8) from [<c0212904>]
> > (edma_prep_slave_sg+0x84/0x388)
> >     [ 6676.678493] [<c0212904>] (edma_prep_slave_sg+0x84/0x388) from
> > [<c02ec0a0>] (omap_hsmmc_request+0x414/0x508)
> >     [ 6676.678524] [<c02ec0a0>] (omap_hsmmc_request+0x414/0x508) from
> > [<c02d6748>] (mmc_start_request+0xc4/0xe0)
> >     [ 6676.678547] [<c02d6748>] (mmc_start_request+0xc4/0xe0) from
> > [<c02d7530>] (mmc_start_req+0x2d8/0x38c)
> >     [ 6676.678568] [<c02d7530>] (mmc_start_req+0x2d8/0x38c) from
> [<c02e4994>]
> > (mmc_blk_issue_rw_rq+0x230/0x9d8)
> >     [ 6676.678589] [<c02e4994>] (mmc_blk_issue_rw_rq+0x230/0x9d8) from
> > [<c02e52e0>] (mmc_blk_issue_rq+0x1a4/0x468)
> >     [ 6676.678608] [<c02e52e0>] (mmc_blk_issue_rq+0x1a4/0x468) from
> > [<c02e5c68>] (mmc_queue_thread+0x88/0x118)
> >     [ 6676.678632] [<c02e5c68>] (mmc_queue_thread+0x88/0x118) from
> > [<c004d8b8>] (kthread+0xb4/0xb8)
> >     [ 6676.678655] [<c004d8b8>] (kthread+0xb4/0xb8) from [<c000e298>]
> > (ret_from_fork+0x14/0x3c)
> >     [ 6676.678664] Mem-info:
> >
>
>
>

--001a113eaff6fcb09f053c49b739
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><div><div>Hi Pintu,<br><br></div>I am also looking fo=
r a mailing list where we can share memory related issues at kernel level. =
I tried subscribing to that mailing list but it says Invalid ID :<br><br>&g=
t;&gt;&gt;&gt; --001a11436926db8726053c49ac67<br>
**** Command &#39;--<wbr>001a11436926db8726053c49ac67&#39; not recognized.<=
br>
<span class=3D"gmail-im">&gt;&gt;&gt;&gt; Content-Type: text/plain; charset=
=3DUTF-8<br>
**** Command &#39;content-type:&#39; not recognized.<br>
&gt;&gt;&gt;&gt;<br>
</span>&gt;&gt;&gt;&gt; subscribe <a href=3D"mailto:linux-mm@kvack.org">lin=
ux-mm@kvack.org</a><br>
**** subscribe: unknown list &#39;<a href=3D"mailto:linux-mm@kvack.org">lin=
ux-mm@kvack.org</a>&#39;.<br><br></div>Thanks<br></div></div><div class=3D"=
gmail_extra"><br><div class=3D"gmail_quote">On Mon, Sep 12, 2016 at 11:42 A=
M, PINTU KUMAR <span dir=3D"ltr">&lt;<a href=3D"mailto:pintu.k@samsung.com"=
 target=3D"_blank">pintu.k@samsung.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex">Dear Ankur,<br>
<br>
I would suggest you register to <a href=3D"mailto:linux-mm@kvack.org">linux=
-mm@kvack.org</a> and explain your issues in details.<br>
There are other experts here, who can guide you.<br>
<br>
Few comments are inline below.<br>
<br>
&gt; From: Ankur Tank [mailto:<a href=3D"mailto:Ankur.Tank@LntTechservices.=
com">Ankur.Tank@<wbr>LntTechservices.com</a>]<br>
&gt; Sent: Saturday, September 10, 2016 5:26 PM<br>
&gt; To: <a href=3D"mailto:pintu.k@samsung.com">pintu.k@samsung.com</a><br>
&gt; Cc: <a href=3D"mailto:artfri2@gmail.com">artfri2@gmail.com</a><br>
&gt; Subject: Memory fragmentation issue related suggestion request<br>
&gt;<br>
&gt; Hello Pintukumar,<br>
&gt;<br>
&gt; TL;DR<br>
&gt; We have an issue in our Linux box, what looks like memory fragmentatio=
n issue,<br>
&gt; while searching on net I referred talk you gave in Embedded Linux Conf=
.<br>
I have several talks in ELC, not sure which one you are referring to. Pleas=
e point out.<br>
<br>
&gt; I am facing this issue for couple of weeks so thought to ask you for s=
uggestions.<br>
&gt; Please forgive me If I offended you by writing mail to you, Ignore mai=
l if you feel so.<br>
&gt;<br>
&gt; Details<br>
&gt; We are facing one issue in our Embedded Linux board, Our board is Beag=
lebone<br>
&gt; black based custom board, with 4GB eMMC as storage. We are using Linux=
 kernel<br>
&gt; 3.12.<br>
In addition, you may need to provide the following information:<br>
RAM size ?<br>
cat /proc/meminfo=C2=A0 (before and after the operation)<br>
cat /proc/buddyinfo (before and after the operation)<br>
cat /proc/vmstat (before and after the operation)<br>
<br>
&gt; Our firmware upgrade strategy is using backgup partition for Bootloade=
r, Kernel,<br>
&gt; dtb, rootfs.<br>
&gt; So,<br>
&gt; During firmware upgrade with big rootfs and running dd to read the par=
tition in raw<br>
&gt; mode.<br>
&gt; In short looks like those operations are overloading the system.<br>
&gt;<br>
I am not sure, but I think this is the crude way of taking the backup.<br>
This will certainly overload your system.<br>
FOTA upgrade experts can give more comments here.<br>
<br>
&gt; From below log looks like pages above 32KB size is not available and m=
ay be<br>
&gt; because of that rootfs tar on the emmc is failing.<br>
&gt; I have following queries in that regards,<br>
&gt;<br>
&gt; 1.=C2=A0 =C2=A0 =C2=A0 =C2=A0Do you think it is a memory fragmentation=
 ?<br>
Yes, if all above 32KB (2^3 order) pages are not available, and pages are a=
vailable in lower orders (2^0/1/2) then its certainly fragmentation problem=
.<br>
However, as I said, you need to provide the following output to confirm:<br=
>
cat /proc/buddyinfo<br>
<br>
&gt; May be silly to ask so but just to confirm, because I had added the so=
ftware swap<br>
&gt; however with that also we were seeing issue reproducible and swap was =
not full at<br>
&gt; that time =E2=98=B9<br>
&gt;<br>
Well, adding swap should help a bit but it may not solve the problem comple=
tely.<br>
How much swap did you actually allocated?<br>
What kind of swap you used ?<br>
Is it ZRAM/ZSWAP (with compression support) ?<br>
What is the swappiness ratio ? (/proc/sys/vm/swappiness)<br>
<br>
&gt; 2.=C2=A0 =C2=A0 =C2=A0 =C2=A0If it is so how do we handle it ? is ther=
e a some way similar to your shrinker<br>
&gt; utility to reclaim the memory pages ?<br>
&gt;<br>
Not sure which shrinker utility are you referring to ?<br>
Is it : /proc/sys/vm/shrink_memory ?<br>
<br>
&gt; Any suggestion would help me move forward,<br>
&gt;<br>
Did you tried enabling CONFIG_COMPACTION ?<br>
Try using ZRAM or ZSWAP (~30% of MemTotal).<br>
Try tuning : /proc/sys/vm/dirty_{<wbr>background_ratio/bytes} and others.<b=
r>
[Refer kernel/documentation for the same]<br>
<br>
>From the logs, I observed the following:<br>
&gt; [ 6676.674219] mmcqd/1: page allocation failure: order:1, mode:0x20002=
0<br>
Order-1 allocation is failing, so pages might be sitting in order-0.<br>
&gt; [ 6676.674739]=C2=A0 free_cma:1982<br>
You have around ~7MB of CMA free pages, so this cannot be used for non-mova=
ble allocation.<br>
&gt; [ 6676.674885] 51661 total pagecache pages<br>
You have huge amount of memory sitting in caches. These can be reclaimed in=
 back ground (with slight performance degradation).<br>
To experiment and debug you can try: echo 3 &gt; /proc/sys/vm/drop_caches<b=
r>
&gt; [ 6676.674925] Total swap =3D 0kB<br>
Swap is not enabled on your system.<br>
<br>
<br>
&gt; Regards,<br>
&gt; Ankur<br>
&gt;<br>
&gt; Error log<br>
&gt; ----------------------------<br>
&gt;<br>
&gt; [ 6676.674219] mmcqd/1: page allocation failure: order:1, mode:0x20002=
0<br>
&gt;=C2=A0 =C2=A0 [ 6676.674256] CPU: 0 PID: 612 Comm: mmcqd/1 Tainted: P=
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0O 3.12.10-005-<br>
&gt; ts-armv7l #2<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674321] [&lt;c0012d24&gt;] (unwind_backtrace=
+0x0/0xf4) from [&lt;c0011130&gt;]<br>
&gt; (show_stack+0x10/0x14)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674355] [&lt;c0011130&gt;] (show_stack+0x10/=
0x14) from [&lt;c0087548&gt;]<br>
&gt; (warn_alloc_failed+0xe0/0x118)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674383] [&lt;c0087548&gt;] (warn_alloc_faile=
d+0xe0/0x118) from [&lt;c008a3ac&gt;]<br>
&gt; (__alloc_pages_nodemask+0x74c/<wbr>0x8f8)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674413] [&lt;c008a3ac&gt;] (__alloc_pages_no=
demask+0x74c/<wbr>0x8f8) from<br>
&gt; [&lt;c00b2e8c&gt;] (cache_alloc_refill+0x328/<wbr>0x620)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674436] [&lt;c00b2e8c&gt;] (cache_alloc_refi=
ll+0x328/<wbr>0x620) from<br>
&gt; [&lt;c00b3224&gt;] (__kmalloc+0xa0/0xe8)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674471] [&lt;c00b3224&gt;] (__kmalloc+0xa0/0=
xe8) from [&lt;c0212904&gt;]<br>
&gt; (edma_prep_slave_sg+0x84/<wbr>0x388)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674505] [&lt;c0212904&gt;] (edma_prep_slave_=
sg+0x84/<wbr>0x388) from<br>
&gt; [&lt;c02ec0a0&gt;] (omap_hsmmc_request+0x414/<wbr>0x508)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674544] [&lt;c02ec0a0&gt;] (omap_hsmmc_reque=
st+0x414/<wbr>0x508) from<br>
&gt; [&lt;c02d6748&gt;] (mmc_start_request+0xc4/0xe0)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674568] [&lt;c02d6748&gt;] (mmc_start_reques=
t+0xc4/0xe0) from<br>
&gt; [&lt;c02d7530&gt;] (mmc_start_req+0x2d8/0x38c)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674589] [&lt;c02d7530&gt;] (mmc_start_req+0x=
2d8/0x38c) from [&lt;c02e4818&gt;]<br>
&gt; (mmc_blk_issue_rw_rq+0xb4/<wbr>0x9d8)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674611] [&lt;c02e4818&gt;] (mmc_blk_issue_rw=
_rq+0xb4/<wbr>0x9d8) from<br>
&gt; [&lt;c02e52e0&gt;] (mmc_blk_issue_rq+0x1a4/0x468)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674631] [&lt;c02e52e0&gt;] (mmc_blk_issue_rq=
+0x1a4/0x468) from<br>
&gt; [&lt;c02e5c68&gt;] (mmc_queue_thread+0x88/0x118)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674657] [&lt;c02e5c68&gt;] (mmc_queue_thread=
+0x88/0x118) from<br>
&gt; [&lt;c004d8b8&gt;] (kthread+0xb4/0xb8)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674681] [&lt;c004d8b8&gt;] (kthread+0xb4/0xb=
8) from [&lt;c000e298&gt;]<br>
&gt; (ret_from_fork+0x14/0x3c)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674691] Mem-info:<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674700] Normal per-cpu:<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674711] CPU=C2=A0 =C2=A0 0: hi:=C2=A0 =C2=A0=
90, btch:=C2=A0 15 usd:=C2=A0 79<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674739] active_anon:4889 inactive_anon:13 is=
olated_anon:0<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674739]=C2=A0 active_file:8082 inactive_file=
:43196 isolated_file:0<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674739]=C2=A0 unevictable:422 dirty:2 writeb=
ack:1152 unstable:0<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674739]=C2=A0 free:3286 slab_reclaimable:109=
0 slab_unreclaimable:915<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674739]=C2=A0 mapped:1593 shmem:39 pagetable=
s:181 bounce:0<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674739]=C2=A0 free_cma:1982<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674800] Normal free:13144kB min:2004kB low:2=
504kB high:3004kB<br>
&gt; active_anon:19556kB inactive_anon:52kB active_file:32328kB<br>
&gt; inactive_file:172784kB unevictable:o<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674813] lowmem_reserve[]: 0 0 0<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674831] Normal: 2584*4kB (UMC) 217*8kB (C) 5=
7*16kB (C) 5*32kB (C)<br>
&gt; 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB 0*8192kB =3D=
<br>
&gt; 13144kB<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674885] 51661 total pagecache pages<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674900] 0 pages in swap cache<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674910] Swap cache stats: add 0, delete 0, f=
ind 0/0<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674918] Free swap=C2=A0 =3D 0kB<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674925] Total swap =3D 0kB<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674938] SLAB: Unable to allocate memory on n=
ode 0 (gfp=3D0x20)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674949]=C2=A0 =C2=A0cache: kmalloc-8192, obj=
ect size: 8192, order: 1<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674962]=C2=A0 =C2=A0node 0: slabs: 3/3, objs=
: 3/3, free: 0<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674984] omap_hsmmc 481d8000.mmc: prep_slave_=
sg() failed<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.674997] omap_hsmmc 481d8000.mmc: MMC start d=
ma failure<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676181] mmcblk0: unknown error -1 sending re=
ad/write command, card<br>
&gt; status 0x900<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676300] end_request: I/O error, dev mmcblk0,=
 sector 27648<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676318] Buffer I/O error on device mmcblk0p9=
, logical block 896<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676329] lost page write due to I/O error on =
mmcblk0p9<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676401] end_request: I/O error, dev mmcblk0,=
 sector 27656<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676415] Buffer I/O error on device mmcblk0p9=
, logical block 897<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676425] lost page write due to I/O error on =
mmcblk0p9<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676450] end_request: I/O error, dev mmcblk0,=
 sector 27664<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676461] Buffer I/O error on device mmcblk0p9=
, logical block 898<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676471] lost page write due to I/O error on =
mmcblk0p9<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676494] end_request: I/O error, dev mmcblk0,=
 sector 27672<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676505] Buffer I/O error on device mmcblk0p9=
, logical block 899<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676515] lost page write due to I/O error on =
mmcblk0p9<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676537] end_request: I/O error, dev mmcblk0,=
 sector 27680<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676548] Buffer I/O error on device mmcblk0p9=
, logical block 900<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676558] lost page write due to I/O error on =
mmcblk0p9<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676580] end_request: I/O error, dev mmcblk0,=
 sector 27688<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676591] Buffer I/O error on device mmcblk0p9=
, logical block 901<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676601] lost page write due to I/O error on =
mmcblk0p9<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676622] end_request: I/O error, dev mmcblk0,=
 sector 27696<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676634] Buffer I/O error on device mmcblk0p9=
, logical block 902<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676643] lost page write due to I/O error on =
mmcblk0p9<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676665] end_request: I/O error, dev mmcblk0,=
 sector 27704<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676676] Buffer I/O error on device mmcblk0p9=
, logical block 903<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676685] lost page write due to I/O error on =
mmcblk0p9<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676707] end_request: I/O error, dev mmcblk0,=
 sector 27712<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676718] Buffer I/O error on device mmcblk0p9=
, logical block 904<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676728] lost page write due to I/O error on =
mmcblk0p9<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.676749] end_request: I/O error, dev mmcblk0,=
 sector 27720<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.678266] mmcqd/1: page allocation failure: or=
der:1, mode:0x200020<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.678285] CPU: 0 PID: 612 Comm: mmcqd/1 Tainte=
d: P=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0O 3.12.10-005-<br>
&gt; ts-armv7l #2<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.678330] [&lt;c0012d24&gt;] (unwind_backtrace=
+0x0/0xf4) from [&lt;c0011130&gt;]<br>
&gt; (show_stack+0x10/0x14)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.678358] [&lt;c0011130&gt;] (show_stack+0x10/=
0x14) from [&lt;c0087548&gt;]<br>
&gt; (warn_alloc_failed+0xe0/0x118)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.678385] [&lt;c0087548&gt;] (warn_alloc_faile=
d+0xe0/0x118) from [&lt;c008a3ac&gt;]<br>
&gt; (__alloc_pages_nodemask+0x74c/<wbr>0x8f8)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.678412] [&lt;c008a3ac&gt;] (__alloc_pages_no=
demask+0x74c/<wbr>0x8f8) from<br>
&gt; [&lt;c00b2e8c&gt;] (cache_alloc_refill+0x328/<wbr>0x620)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.678434] [&lt;c00b2e8c&gt;] (cache_alloc_refi=
ll+0x328/<wbr>0x620) from<br>
&gt; [&lt;c00b3224&gt;] (__kmalloc+0xa0/0xe8)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.678464] [&lt;c00b3224&gt;] (__kmalloc+0xa0/0=
xe8) from [&lt;c0212904&gt;]<br>
&gt; (edma_prep_slave_sg+0x84/<wbr>0x388)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.678493] [&lt;c0212904&gt;] (edma_prep_slave_=
sg+0x84/<wbr>0x388) from<br>
&gt; [&lt;c02ec0a0&gt;] (omap_hsmmc_request+0x414/<wbr>0x508)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.678524] [&lt;c02ec0a0&gt;] (omap_hsmmc_reque=
st+0x414/<wbr>0x508) from<br>
&gt; [&lt;c02d6748&gt;] (mmc_start_request+0xc4/0xe0)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.678547] [&lt;c02d6748&gt;] (mmc_start_reques=
t+0xc4/0xe0) from<br>
&gt; [&lt;c02d7530&gt;] (mmc_start_req+0x2d8/0x38c)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.678568] [&lt;c02d7530&gt;] (mmc_start_req+0x=
2d8/0x38c) from [&lt;c02e4994&gt;]<br>
&gt; (mmc_blk_issue_rw_rq+0x230/<wbr>0x9d8)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.678589] [&lt;c02e4994&gt;] (mmc_blk_issue_rw=
_rq+0x230/<wbr>0x9d8) from<br>
&gt; [&lt;c02e52e0&gt;] (mmc_blk_issue_rq+0x1a4/0x468)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.678608] [&lt;c02e52e0&gt;] (mmc_blk_issue_rq=
+0x1a4/0x468) from<br>
&gt; [&lt;c02e5c68&gt;] (mmc_queue_thread+0x88/0x118)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.678632] [&lt;c02e5c68&gt;] (mmc_queue_thread=
+0x88/0x118) from<br>
&gt; [&lt;c004d8b8&gt;] (kthread+0xb4/0xb8)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.678655] [&lt;c004d8b8&gt;] (kthread+0xb4/0xb=
8) from [&lt;c000e298&gt;]<br>
&gt; (ret_from_fork+0x14/0x3c)<br>
&gt;=C2=A0 =C2=A0 =C2=A0[ 6676.678664] Mem-info:<br>
&gt;<br>
<br>
<br>
</blockquote></div><br></div>

--001a113eaff6fcb09f053c49b739--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
