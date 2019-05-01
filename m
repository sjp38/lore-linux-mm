Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.1 required=3.0 tests=DATE_IN_PAST_03_06,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCCECC43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 04:56:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 565CB2075E
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 04:56:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VHkN+zj7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 565CB2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B0346B0005; Thu,  2 May 2019 00:56:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93A686B0006; Thu,  2 May 2019 00:56:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8011D6B0007; Thu,  2 May 2019 00:56:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 55A046B0005
	for <linux-mm@kvack.org>; Thu,  2 May 2019 00:56:15 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id r3so120845vsn.22
        for <linux-mm@kvack.org>; Wed, 01 May 2019 21:56:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to;
        bh=SFwX354iHZ+hTqT9nWh7vIFjr2BMLK4aUH9cqIc8sFE=;
        b=W33yDSZfxG8nAtOTl4PHvlrt1q6XWRCRIlPHtplNTuTGmce4VNbiIYCZXuRn+RObZ+
         2uP4Yi9zD4w1f+1JZccb2wMPchZcKmpNMqrD3GNOJo0CaDhCjI+psR4kfnsgeEf4/p6t
         bPuoFKRKQUIss4IvSyxq30ltWUh5NynBtl3AsQ3w+f3GRT1cxIiW+um05CbyPwgan0CS
         shQii4/8BmvM/btnM06tVbvj2gmj8FOxI2inb1M250VphO/VdeFwxSK1kFTxFyXDZWNK
         HEdlsHQt46CGD1r2PD5ZFPGT+eMPbh8bawwUz+4K9Kuq2n27BBT5OqICvSRARycGzhUT
         0FIA==
X-Gm-Message-State: APjAAAUcFiuaP5Ggo2DmQDW3e9SsTgqVAEdIXwGvmXndjdV59mY/bVDI
	AvfcjzjVKvkjdSiZLhv9fkEO8cVCzga4Q/7SBI9cIXhN2TVHUdd8bYthbrYocLWQgL1N5kDb3Vd
	ma2OC5JSxA3AZB/4DIKMxMDhzgly4kMhH/U1FM2G3pTtacPjOhDt7xvcpIED8t5iTnw==
X-Received: by 2002:a67:7444:: with SMTP id p65mr827072vsc.104.1556772974981;
        Wed, 01 May 2019 21:56:14 -0700 (PDT)
X-Received: by 2002:a67:7444:: with SMTP id p65mr827034vsc.104.1556772973527;
        Wed, 01 May 2019 21:56:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556772973; cv=none;
        d=google.com; s=arc-20160816;
        b=e2gsoGIa1O5HziloX9Npy6LpPraFRFPy1vngDSPJ8s2M44SbBE73Jx/9/ka1yMC+ND
         nW/fjcZlHQgUJ7TeqDXqfNNF8tLY2vg+yQ72UPDY/L8EAKqZ5cLmEIX88uw505tbXCjU
         2+ZoJX/fXeNdj6DT0p1KfMzSpcliVAvwaTmisbSUbe9bQR4hQ7LRrP/oEwyMHcAgAGnL
         eS8OrqXbCLBtwaT13XH7PSGyKwrtz4Z0g6PIxJdt1Lx2F8nW5pnP6CFV99F168hkLd6+
         kGhweQoS20WelTZThBRUYzK2AU4syrMH06mjhsvGdt95ng3Ky9kfXrq7atw9NcY+gUR0
         0kvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=SFwX354iHZ+hTqT9nWh7vIFjr2BMLK4aUH9cqIc8sFE=;
        b=ChiAbOTBoKGrsdNLCDmEUYiYRHeQeIHBB1zQMquZPWHMYeDI5XB9oOyHKMw6tBX00O
         oSfJqbyjq4pHKwgKpwDdQGwXG6hpLU4CV2th9/KYr4SpzMJo9xEXtpXpwtDhzgZZUW/V
         7+nZK2QDw0tC0vVL4NgC7jP+0F2Rv+z77QcnFeR68kAClX1Hi0dHxaZ5VX4VtCId/9Mt
         ky4mzhMDEtv0NbHRnaOhKS5WBi0VgthIg6ZIW4pZW1RnH8F7oVgVdJj0fH80jOZGF/3B
         Ns+Ju8odwHfmnEFP7CgC3x70V1aVEOa0LD3BRAE8/eolk8afQsYEhMfQU8XlhaTm//SG
         D/Hw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VHkN+zj7;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n26sor4208227vso.13.2019.05.01.21.56.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 May 2019 21:56:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VHkN+zj7;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=SFwX354iHZ+hTqT9nWh7vIFjr2BMLK4aUH9cqIc8sFE=;
        b=VHkN+zj7MEunuCntpNE6fsmxuRxsohytCQWxJ1Wi/GXVdoebOxsHavjdz6b9+KD0Ot
         HqXsdvyi8GIdiqnZk285j2fhIpDAZoko7OKjNQDp2z8VS0jCLD+H6N6qcYzdFEh63oYy
         RQDEi/0TAJMb+hsK0OVzKrPDeLK7WF8+JvCphGsIpWFh4DoR10CL9+OxEl2llcQb5voq
         tSpYqNDLZvzT1KD45UhtECH+yM/MQiwlO2xSH7JS2/uuxZNYa7qZODGyXltwOYkygdhZ
         4WBOeYmP9bZk793HNw+0WWeZevpe+SSD5ATt/7vn9hMnddr5O40NPtzYn47g+1Y0Ox3p
         Qk5w==
X-Google-Smtp-Source: APXvYqz7ccMqjOZWDhTPMtXdzfdFZyKXpu9056q7oQEgh83donMbcGDwO3N5V5wokqbEJpnRbfsJUb9vZSzn0AW7uEI=
X-Received: by 2002:a67:cb12:: with SMTP id b18mr823185vsl.191.1556772972991;
 Wed, 01 May 2019 21:56:12 -0700 (PDT)
MIME-Version: 1.0
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Thu, 2 May 2019 04:56:05 +0530
Message-ID: <CACDBo57s_ZxmxjmRrCSwaqQzzO5r0SadzMhseeb9X0t0mOwJZA@mail.gmail.com>
Subject: Page Allocation Failure and Page allocation stalls
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	kernelnewbies@kernelnewbies.org, Vlastimil Babka <vbabka@suse.cz>, 
	Michal Hocko <mhocko@kernel.org>, minchan@kernel.org
Content-Type: multipart/alternative; boundary="0000000000000d1a7a0587e074ed"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000000d1a7a0587e074ed
Content-Type: text/plain; charset="UTF-8"

Hi All,

Please help me to decode the error messages and reason for this errors.

System Configuration
1. Kernel 4.14.65 For Android Pie.
2. RAM 2GB

As per my understanding its because of
i) I am out of memory or due to fragmentation.

I also tried to set /proc/sys/vm/min_freekbytes from 3MB to 64MB, but issue
still persists.

Below are the errors.

1)
[ 3205.818891] HwBinder:1894_6: page allocation failure: order:7,
mode:0x14040c0(GFP_KERNEL|__GFP_COMP), nodemask=(null)
[ 3205.830189] CPU: 3 PID: 23012 Comm: HwBinder:1894_6 Tainted: P
O    4.14.65 #261
[ 3205.838803] Hardware name: Android(Flattened Device Tree)
[ 3205.845153] Backtrace:
[ 3205.847617] [<8020dbec>] (dump_backtrace) from [<8020ded0>]
(show_stack+0x18/0x1c)
[ 3205.855187]  r6:600f0013 r5:8141c21c r4:00000000 r3:d98a4108
[ 3205.860852] [<8020deb8>] (show_stack) from [<80bab014>]
(dump_stack+0x94/0xa8)
[ 3205.868081] [<80baaf80>] (dump_stack) from [<80350674>]
(warn_alloc+0xe0/0x194)
[ 3205.875389]  r6:80e09abc r5:00000000 r4:81216588 r3:d98a4108
[ 3205.881054] [<80350598>] (warn_alloc) from [<80351544>]
(__alloc_pages_nodemask+0xd70/0x124c)
[ 3205.889576]  r3:00000007 r2:80e09abc
[ 3205.893149]  r6:00000040 r5:00000000 r4:00000000
[ 3205.897771] [<803507d4>] (__alloc_pages_nodemask) from [<80375484>]
(kmalloc_order_trace+0x34/0x124)
[ 3205.906906]  r10:00080000 r9:803a983c r8:00080000 r7:00000007
r6:17c00000 r5:014000c0
[ 3205.914731]  r4:bf20b800
[ 3205.917268] [<80375450>] (kmalloc_order_trace) from [<803a983c>]
(__kmalloc+0x1e0/0x318)
[ 3205.925358]  r9:80607760 r8:014000c0 r7:20000008 r6:17c00000 r5:17c00000
r4:bf20b800
[ 3205.933107] [<803a965c>] (__kmalloc) from [<806a9464>]
(dma_common_contiguous_remap+0x40/0xc8)
[ 3205.941721]  r10:bf20b800 r9:80607760 r8:af78bd34 r7:20000008
r6:17c00000 r5:17c00000
[ 3205.949546]  r4:bf20b800
[ 3205.952085] [<806a9424>] (dma_common_contiguous_remap) from [<802187e4>]
(__alloc_from_contiguous+0x118/0x144)
[ 3205.962086]  r7:00017c00 r6:17c00000 r5:81216588 r4:00000001
[ 3205.967748] [<802186cc>] (__alloc_from_contiguous) from [<80218854>]
(cma_allocator_alloc+0x44/0x4c)
[ 3205.976881]  r10:00000000 r9:af78bdd8 r8:81216588 r7:00c00000
r6:b93ac300 r5:80607760
[ 3205.984707]  r4:00000001
[ 3205.987241] [<80218810>] (cma_allocator_alloc) from [<80217e28>]
(__dma_alloc+0x19c/0x2e4)
[ 3205.995501]  r5:be30a400 r4:014000c0
[ 3205.999094] [<80217c8c>] (__dma_alloc) from [<80218000>]
(arm_dma_alloc+0x4c/0x54)
[ 3206.006677]  r10:00000080 r9:17c00000 r8:80c01778 r7:be30a400
r6:81216588 r5:00c00000
[ 3206.014533]  r4:00000707
[ 3206.017100] [<80217fb4>] (arm_dma_alloc) from [<80607760>]
(pmap_cma_alloc+0xbc/0x14c)
[ 3206.025048]  r5:814278b8 r4:814901f8


2)

[  671.925663] kworker/u8:13: page allocation stalls for 10090ms, order:1,
mode:0x15080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO), nodemask=(null)
[  671.938469] CPU: 2 PID: 3551 Comm: kworker/u8:13 Tainted: P           O
   4.14.65#273
[  671.946822] Hardware name: Android (Flattened Device Tree)
[  671.953184] Workqueue: events_unbound call_usermodehelper_exec_work
[  671.959449] Backtrace:
[  671.961901] [<8020dbec>] (dump_backtrace) from [<8020ded0>]
(show_stack+0x18/0x1c)
[  671.969469]  r6:60060113 r5:8141c09c r4:00000000 r3:db12065c
[  671.975129] [<8020deb8>] (show_stack) from [<80ba6850>]
(dump_stack+0x94/0xa8)
[  671.982356] [<80ba67bc>] (dump_stack) from [<80350610>]
(warn_alloc+0xe0/0x194)
[  671.989664]  r6:80e09180 r5:00000000 r4:81216588 r3:db12065c
[  671.995326] [<80350534>] (warn_alloc) from [<80351520>]
(__alloc_pages_nodemask+0xdb0/0x124c)
[  672.003846]  r3:0000276a r2:80e09180
[  672.007417]  r6:812166a4 r5:8141d880 r4:00000000
[  672.012039] [<80350770>] (__alloc_pages_nodemask) from [<8021e914>]
(copy_process.part.5+0x114/0x1a28)
[  672.021345]  r10:00000000 r9:99848780 r8:00000000 r7:81447c48
r6:81216588 r5:00808111
[  672.029169]  r4:9b355280
[  672.031702] [<8021e800>] (copy_process.part.5) from [<802203b0>]
(_do_fork+0xd0/0x464)
[  672.039617]  r10:00000000 r9:00000000 r8:9d008400 r7:00000000
r6:81216588 r5:9b62f840
[  672.047441]  r4:00808111
[  672.049972] [<802202e0>] (_do_fork) from [<802207a4>]
(kernel_thread+0x38/0x40)
[  672.057281]  r10:00000000 r9:81422554 r8:9d008400 r7:00000000
r6:9d004500 r5:9b62f840
[  672.065105]  r4:81216588
[  672.067642] [<8022076c>] (kernel_thread) from [<802399b4>]
(call_usermodehelper_exec_work+0x44/0xe0)
[  672.076775] [<80239970>] (call_usermodehelper_exec_work) from
[<8023cfc8>] (process_one_work+0x154/0x518)
[  672.086338]  r5:9b62f840 r4:98b43480
[  672.089913] [<8023ce74>] (process_one_work) from [<8023d3e4>]
(worker_thread+0x58/0x56c)
[  672.098003]  r10:00000088 r9:98b43480 r8:98b43498 r7:8120f900
r6:88eea038 r5:9d008424
[  672.105827]  r4:9d008400
[  672.108362] [<8023d38c>] (worker_thread) from [<802440d8>]
(kthread+0x134/0x164)
[  672.115757]  r10:838dbe68 r9:99e7a2a8 r8:8023d38c r7:98b43480
r6:9bf0d600 r5:00000000
[  672.123581]  r4:99e7a280
[  672.126116] [<80243fa4>] (kthread) from [<80209258>]
(ret_from_fork+0x14/0x3c)
[  672.133338]  r10:00000000 r9:00000000 r8:00000000 r7:00000000
r6:00000000 r5:80243fa4
[  672.141162]  r4:9bf0d600 r3:00000000
[  672.147376] Mem-Info:
[  672.149667] active_anon:68540 inactive_anon:101042 isolated_anon:207
[  672.149667]  active_file:26674 inactive_file:17535 isolated_file:2
[  672.149667]  unevictable:610 dirty:0 writeback:152 unstable:0
[  672.149667]  slab_reclaimable:5039 slab_unreclaimable:9749
[  672.149667]  mapped:32149 shmem:45729 pagetables:4266 bounce:0
[  672.149667]  free:18378 free_pcp:59 free_cma:0
[  672.183745] Node 0 active_anon:274456kB inactive_anon:404216kB
active_file:106672kB inactive_file:70164kB unevictable:2440kB
isolated(anon):416kB isolated(file):8kB mapped:128596kB dirty:0kB
writeback:544kB shmem:182916kB writeback_tmp:0kB unstable:0kB
all_unreclaimable? no
[  672.208055] DMA free:72984kB min:65536kB low:87004kB high:103388kB
active_anon:109860kB inactive_anon:109304kB active_file:408kB
inactive_file:772kB unevictable:0kB writepending:616kB present:450560kB
managed:414704kB mlocked:0kB kernel_stack:5984kB pagetables:7024kB
bounce:0kB free_pcp:708kB local_pcp:4kB free_cma:0kB


Regards,
Pankaj

--0000000000000d1a7a0587e074ed
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi All,<br><br>Please help me to decode the error messages=
 and reason for this errors.<br><br>System Configuration<br>1. Kernel 4.14.=
65 For Android Pie.<br>2. RAM 2GB<div><br></div><div>As per my understandin=
g its because of</div><div>i) I am out of memory or due to fragmentation.</=
div><div><br></div><div>I also tried to set /proc/sys/vm/min_freekbytes fro=
m 3MB to 64MB, but issue still persists.<br><br>Below are the errors.<br><b=
r>1)<br>[ 3205.818891] HwBinder:1894_6: page allocation failure: order:7, m=
ode:0x14040c0(GFP_KERNEL|__GFP_COMP), nodemask=3D(null)<br>[ 3205.830189] C=
PU: 3 PID: 23012 Comm: HwBinder:1894_6 Tainted: P =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 O =C2=A0 =C2=A04.14.65 #261<br>[ 3205.838803] Hardware name: And=
roid(Flattened Device Tree)<br>[ 3205.845153] Backtrace:<br>[ 3205.847617] =
[&lt;8020dbec&gt;] (dump_backtrace) from [&lt;8020ded0&gt;] (show_stack+0x1=
8/0x1c)<br>[ 3205.855187] =C2=A0r6:600f0013 r5:8141c21c r4:00000000 r3:d98a=
4108<br>[ 3205.860852] [&lt;8020deb8&gt;] (show_stack) from [&lt;80bab014&g=
t;] (dump_stack+0x94/0xa8)<br>[ 3205.868081] [&lt;80baaf80&gt;] (dump_stack=
) from [&lt;80350674&gt;] (warn_alloc+0xe0/0x194)<br>[ 3205.875389] =C2=A0r=
6:80e09abc r5:00000000 r4:81216588 r3:d98a4108<br>[ 3205.881054] [&lt;80350=
598&gt;] (warn_alloc) from [&lt;80351544&gt;] (__alloc_pages_nodemask+0xd70=
/0x124c)<br>[ 3205.889576] =C2=A0r3:00000007 r2:80e09abc<br>[ 3205.893149] =
=C2=A0r6:00000040 r5:00000000 r4:00000000<br>[ 3205.897771] [&lt;803507d4&g=
t;] (__alloc_pages_nodemask) from [&lt;80375484&gt;] (kmalloc_order_trace+0=
x34/0x124)<br>[ 3205.906906] =C2=A0r10:00080000 r9:803a983c r8:00080000 r7:=
00000007 r6:17c00000 r5:014000c0<br>[ 3205.914731] =C2=A0r4:bf20b800<br>[ 3=
205.917268] [&lt;80375450&gt;] (kmalloc_order_trace) from [&lt;803a983c&gt;=
] (__kmalloc+0x1e0/0x318)<br>[ 3205.925358] =C2=A0r9:80607760 r8:014000c0 r=
7:20000008 r6:17c00000 r5:17c00000 r4:bf20b800<br>[ 3205.933107] [&lt;803a9=
65c&gt;] (__kmalloc) from [&lt;806a9464&gt;] (dma_common_contiguous_remap+0=
x40/0xc8)<br>[ 3205.941721] =C2=A0r10:bf20b800 r9:80607760 r8:af78bd34 r7:2=
0000008 r6:17c00000 r5:17c00000<br>[ 3205.949546] =C2=A0r4:bf20b800<br>[ 32=
05.952085] [&lt;806a9424&gt;] (dma_common_contiguous_remap) from [&lt;80218=
7e4&gt;] (__alloc_from_contiguous+0x118/0x144)<br>[ 3205.962086] =C2=A0r7:0=
0017c00 r6:17c00000 r5:81216588 r4:00000001<br>[ 3205.967748] [&lt;802186cc=
&gt;] (__alloc_from_contiguous) from [&lt;80218854&gt;] (cma_allocator_allo=
c+0x44/0x4c)<br>[ 3205.976881] =C2=A0r10:00000000 r9:af78bdd8 r8:81216588 r=
7:00c00000 r6:b93ac300 r5:80607760<br>[ 3205.984707] =C2=A0r4:00000001<br>[=
 3205.987241] [&lt;80218810&gt;] (cma_allocator_alloc) from [&lt;80217e28&g=
t;] (__dma_alloc+0x19c/0x2e4)<br>[ 3205.995501] =C2=A0r5:be30a400 r4:014000=
c0<br>[ 3205.999094] [&lt;80217c8c&gt;] (__dma_alloc) from [&lt;80218000&gt=
;] (arm_dma_alloc+0x4c/0x54)<br>[ 3206.006677] =C2=A0r10:00000080 r9:17c000=
00 r8:80c01778 r7:be30a400 r6:81216588 r5:00c00000<br>[ 3206.014533] =C2=A0=
r4:00000707<br>[ 3206.017100] [&lt;80217fb4&gt;] (arm_dma_alloc) from [&lt;=
80607760&gt;] (pmap_cma_alloc+0xbc/0x14c)<br>[ 3206.025048] =C2=A0r5:814278=
b8 r4:814901f8<br><br><br>2)<br><br>[ =C2=A0671.925663] kworker/u8:13: page=
 allocation stalls for 10090ms, order:1, mode:0x15080c0(GFP_KERNEL_ACCOUNT|=
__GFP_ZERO), nodemask=3D(null)<br>[ =C2=A0671.938469] CPU: 2 PID: 3551 Comm=
: kworker/u8:13 Tainted: P =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 O =C2=A0 =C2=
=A04.14.65#273<br>[ =C2=A0671.946822] Hardware name: Android (Flattened Dev=
ice Tree)<br>[ =C2=A0671.953184] Workqueue: events_unbound call_usermodehel=
per_exec_work<br>[ =C2=A0671.959449] Backtrace:<br>[ =C2=A0671.961901] [&lt=
;8020dbec&gt;] (dump_backtrace) from [&lt;8020ded0&gt;] (show_stack+0x18/0x=
1c)<br>[ =C2=A0671.969469] =C2=A0r6:60060113 r5:8141c09c r4:00000000 r3:db1=
2065c<br>[ =C2=A0671.975129] [&lt;8020deb8&gt;] (show_stack) from [&lt;80ba=
6850&gt;] (dump_stack+0x94/0xa8)<br>[ =C2=A0671.982356] [&lt;80ba67bc&gt;] =
(dump_stack) from [&lt;80350610&gt;] (warn_alloc+0xe0/0x194)<br>[ =C2=A0671=
.989664] =C2=A0r6:80e09180 r5:00000000 r4:81216588 r3:db12065c<br>[ =C2=A06=
71.995326] [&lt;80350534&gt;] (warn_alloc) from [&lt;80351520&gt;] (__alloc=
_pages_nodemask+0xdb0/0x124c)<br>[ =C2=A0672.003846] =C2=A0r3:0000276a r2:8=
0e09180<br>[ =C2=A0672.007417] =C2=A0r6:812166a4 r5:8141d880 r4:00000000<br=
>[ =C2=A0672.012039] [&lt;80350770&gt;] (__alloc_pages_nodemask) from [&lt;=
8021e914&gt;] (copy_process.part.5+0x114/0x1a28)<br>[ =C2=A0672.021345] =C2=
=A0r10:00000000 r9:99848780 r8:00000000 r7:81447c48 r6:81216588 r5:00808111=
<br>[ =C2=A0672.029169] =C2=A0r4:9b355280<br>[ =C2=A0672.031702] [&lt;8021e=
800&gt;] (copy_process.part.5) from [&lt;802203b0&gt;] (_do_fork+0xd0/0x464=
)<br>[ =C2=A0672.039617] =C2=A0r10:00000000 r9:00000000 r8:9d008400 r7:0000=
0000 r6:81216588 r5:9b62f840<br>[ =C2=A0672.047441] =C2=A0r4:00808111<br>[ =
=C2=A0672.049972] [&lt;802202e0&gt;] (_do_fork) from [&lt;802207a4&gt;] (ke=
rnel_thread+0x38/0x40)<br>[ =C2=A0672.057281] =C2=A0r10:00000000 r9:8142255=
4 r8:9d008400 r7:00000000 r6:9d004500 r5:9b62f840<br>[ =C2=A0672.065105] =
=C2=A0r4:81216588<br>[ =C2=A0672.067642] [&lt;8022076c&gt;] (kernel_thread)=
 from [&lt;802399b4&gt;] (call_usermodehelper_exec_work+0x44/0xe0)<br>[ =C2=
=A0672.076775] [&lt;80239970&gt;] (call_usermodehelper_exec_work) from [&lt=
;8023cfc8&gt;] (process_one_work+0x154/0x518)<br>[ =C2=A0672.086338] =C2=A0=
r5:9b62f840 r4:98b43480<br>[ =C2=A0672.089913] [&lt;8023ce74&gt;] (process_=
one_work) from [&lt;8023d3e4&gt;] (worker_thread+0x58/0x56c)<br>[ =C2=A0672=
.098003] =C2=A0r10:00000088 r9:98b43480 r8:98b43498 r7:8120f900 r6:88eea038=
 r5:9d008424<br>[ =C2=A0672.105827] =C2=A0r4:9d008400<br>[ =C2=A0672.108362=
] [&lt;8023d38c&gt;] (worker_thread) from [&lt;802440d8&gt;] (kthread+0x134=
/0x164)<br>[ =C2=A0672.115757] =C2=A0r10:838dbe68 r9:99e7a2a8 r8:8023d38c r=
7:98b43480 r6:9bf0d600 r5:00000000<br>[ =C2=A0672.123581] =C2=A0r4:99e7a280=
<br>[ =C2=A0672.126116] [&lt;80243fa4&gt;] (kthread) from [&lt;80209258&gt;=
] (ret_from_fork+0x14/0x3c)<br>[ =C2=A0672.133338] =C2=A0r10:00000000 r9:00=
000000 r8:00000000 r7:00000000 r6:00000000 r5:80243fa4<br>[ =C2=A0672.14116=
2] =C2=A0r4:9bf0d600 r3:00000000<br>[ =C2=A0672.147376] Mem-Info:<br>[ =C2=
=A0672.149667] active_anon:68540 inactive_anon:101042 isolated_anon:207<br>=
[ =C2=A0672.149667] =C2=A0active_file:26674 inactive_file:17535 isolated_fi=
le:2<br>[ =C2=A0672.149667] =C2=A0unevictable:610 dirty:0 writeback:152 uns=
table:0<br>[ =C2=A0672.149667] =C2=A0slab_reclaimable:5039 slab_unreclaimab=
le:9749<br>[ =C2=A0672.149667] =C2=A0mapped:32149 shmem:45729 pagetables:42=
66 bounce:0<br>[ =C2=A0672.149667] =C2=A0free:18378 free_pcp:59 free_cma:0<=
br>[ =C2=A0672.183745] Node 0 active_anon:274456kB inactive_anon:404216kB a=
ctive_file:106672kB inactive_file:70164kB unevictable:2440kB isolated(anon)=
:416kB isolated(file):8kB mapped:128596kB dirty:0kB writeback:544kB shmem:1=
82916kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no<br>[ =C2=A0672=
.208055] DMA free:72984kB min:65536kB low:87004kB high:103388kB active_anon=
:109860kB inactive_anon:109304kB active_file:408kB inactive_file:772kB unev=
ictable:0kB writepending:616kB present:450560kB managed:414704kB mlocked:0k=
B kernel_stack:5984kB pagetables:7024kB bounce:0kB free_pcp:708kB local_pcp=
:4kB free_cma:0kB</div><div><br></div><div><br></div><div>Regards,</div><di=
v>Pankaj</div></div>

--0000000000000d1a7a0587e074ed--

