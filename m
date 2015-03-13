Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9F4238299B
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 10:25:28 -0400 (EDT)
Received: by obcvb8 with SMTP id vb8so19892109obc.10
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 07:25:28 -0700 (PDT)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id s65si1125605oib.114.2015.03.13.07.25.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 07:25:27 -0700 (PDT)
Received: by oifz81 with SMTP id z81so1789052oif.13
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 07:25:27 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 13 Mar 2015 19:55:27 +0530
Message-ID: <CAB5gotvwyD74UugjB6XQ_v=o11Hu9wAuA6N94UvGObPARYEz0w@mail.gmail.com>
Subject: kswapd hogging in lowmem_shrink
From: Vaibhav Shinde <v.bhav.shinde@gmail.com>
Content-Type: multipart/alternative; boundary=001a113d662a99a3d905112c45ff
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

--001a113d662a99a3d905112c45ff
Content-Type: text/plain; charset=UTF-8

On low memory situation, I see various shrinkers being invoked, but in
lowmem_shrink() case, kswapd is found to be hogging for around 150msecs.

Due to this my application suffer latency issue, as the cpu was not
released by kswapd0.

I took below traces with vmscan events, that show lowmem_shrink taking such
long time for execution.

kswapd0-67 [003] ...1  1501.987110: mm_shrink_slab_start:
lowmem_shrink+0x0/0x580 c0ee8e34: objects to shrink 122 gfp_flags
GFP_KERNEL pgs_scanned 83 lru_pgs 241753 cache items 241754 delta 10
total_scan 132
kswapd0-67 [003] ...1  1502.020827: mm_shrink_slab_end:
lowmem_shrink+0x0/0x580 c0ee8e34: unused scan count 122 new scan count 4
total_scan -118 last shrinker return val 237339

Please provide inputs on the same.

Thanks and Regards,
Vaibhav

--001a113d662a99a3d905112c45ff
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br>On low memory situation, I see various shrinkers being=
 invoked, but in lowmem_shrink() case, kswapd is found to be hogging for ar=
ound 150msecs.<br><br>Due to this my application suffer latency issue, as t=
he cpu was not released by kswapd0.<br><br>I took below traces with vmscan =
events, that show lowmem_shrink taking such long time for execution.<br><br=
>kswapd0-67 [003] ...1 =C2=A01501.987110: mm_shrink_slab_start: lowmem_shri=
nk+0x0/0x580 c0ee8e34: objects to shrink 122 gfp_flags GFP_KERNEL pgs_scann=
ed 83 lru_pgs 241753 cache items 241754 delta 10 total_scan 132<br>kswapd0-=
67 [003] ...1 =C2=A01502.020827: mm_shrink_slab_end: lowmem_shrink+0x0/0x58=
0 c0ee8e34: unused scan count 122 new scan count 4 total_scan -118 last shr=
inker return val 237339<br><br>Please provide inputs on the same.<br><br>Th=
anks and Regards,<br>Vaibhav<br></div>

--001a113d662a99a3d905112c45ff--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
