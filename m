Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47010C43381
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 04:12:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1A6420833
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 04:12:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1A6420833
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3820F6B0003; Tue,  2 Apr 2019 00:12:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 331896B0005; Tue,  2 Apr 2019 00:12:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 221836B0007; Tue,  2 Apr 2019 00:12:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id E68086B0003
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 00:12:10 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id x125so4302128oix.17
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 21:12:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=F2vJTDUQQPekEsio9ABNwpo/nIflzHrX3NvpI0eAfgE=;
        b=XuYkyD/CgMChjCpFWZSbKUh2EK9oTfdmnK8tcznF99nAj/A7JfxfPylrbl8GtHPgnh
         D4sOwMClK4hvZUduyiARMHwN0zylzmKeX1/ZRF2hx+VziQASgzmtl11SD+o61haqhxHp
         v5twC3DN16pf1EfXbnV522BpV138lp7wFwiyTUbTSfBvyuBMG382K4Zatxh+15QRPRMm
         uGs4aGSA6YGcAS7F+i+zTIkXmCraVMU17YfQ5DmV753c24h4mv4NE3NTKhFgyLQdSF3R
         eYXB7JjumWzK2puKGQDVBqPmz3iCWz9XPAaHWUvCah8EjQZoUXtsROfOCxB2proMfR70
         YjeQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fanglinxu@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=fanglinxu@huawei.com
X-Gm-Message-State: APjAAAVUJnLF5FJHAyTNAT+zxWpvA/n7BoeZw7Ge1C5oy1bBy8eqRIsq
	YZFTU4GNOPBLFreBPzkZKonc1omtPIMfuRHXbZcPQQYOHUDUgeFkiHSeqvssNlwRNBS1yI6FYti
	NnBvDbeIiICEYm0+leGFdfwGRw+6BrghWHt55ccAGDkIqzzRrvsY+G56+y4fPBs0MQw==
X-Received: by 2002:a05:6830:1454:: with SMTP id w20mr44542992otp.190.1554178330601;
        Mon, 01 Apr 2019 21:12:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwi49z8NK88zSRLz7yNc63ZpWBuHFmFTg/XAbyLecdeGvO9AO1sV46swJ9sPEyND29G5LHu
X-Received: by 2002:a05:6830:1454:: with SMTP id w20mr44542964otp.190.1554178329720;
        Mon, 01 Apr 2019 21:12:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554178329; cv=none;
        d=google.com; s=arc-20160816;
        b=zh3IzFjl0edF5rCk6Gq2zxeIC5ZULnwiCGqB5xv/5nW+Mj01SUCtj6WTLtHpNFEIhM
         /rqbK8fwLjmvtgzxLil8rErsorhptaRAVmiuKNRRir/vQSSiX/hCff6SRaJf8HTg61eZ
         Zqqw13+ILiPdcB+kmwuAqurcRYQHzaywGxV8Kphre6/dWbcPHclYUYUWdOtHSTInjj2I
         CVzDy/JIAb6LYvYkMGHocHB0HO1xKL2PAI2bnYqU+IsTbWz7cXi73ki+2XRKhLatAL4v
         PXhztmwR8FdDOogKfy+UQe0kFMofA3+0pan77nWwP1jZ9HC8hs5H8KyEIakA+PbTAy2X
         xClg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=F2vJTDUQQPekEsio9ABNwpo/nIflzHrX3NvpI0eAfgE=;
        b=GL6wVMKIEkLqYAQz+WJ0CuSWAIfU1ZP2fI6mYAK1beO0pWIDK0mxP7PcK8mk1nje/N
         57KMrFKzUsxZmonML8UiurxpEaWlP3mrlBZpGHLvs/j8yNq63wQ4TYYQ0zUQuEK7R1uF
         w+n93L0n2DY4hUYsJNM4dy/rzW2TkNAF/HDjapF7G1xUhDvy8uFNpyDQTduDJL9w0qXI
         92R5MUbz/H5kBhUFOdmhBMTgprlY9RsFeQfzaujJNvLp+N82Vi0nvm4H2c3J+6BOymlk
         jYdxPfJQRdrKLn3HV0Adm0Q6hladVIIwPARqoYu0aWxEwYSSuK5CCtscP7KQz3Z1lDuB
         Kn0w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fanglinxu@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=fanglinxu@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id u123si5178793oif.64.2019.04.01.21.12.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 21:12:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of fanglinxu@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fanglinxu@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=fanglinxu@huawei.com
Received: from DGGEMS405-HUB.china.huawei.com (unknown [10.3.19.205])
	by Forcepoint Email with ESMTP id 04CAE364207D0B2989F6;
	Tue,  2 Apr 2019 12:12:06 +0800 (CST)
Received: from huawei.com (10.66.68.70) by DGGEMS405-HUB.china.huawei.com
 (10.3.19.205) with Microsoft SMTP Server id 14.3.408.0; Tue, 2 Apr 2019
 12:12:03 +0800
From: Linxu Fang <fanglinxu@huawei.com>
To: <akpm@linux-foundation.org>, <mhocko@suse.com>, <vbabka@suse.cz>,
	<pavel.tatashin@microsoft.com>, <osalvador@suse.de>
CC: <linux-mm@kvack.org>
Subject: [PATCH] mem-hotplug: fix node spanned pages when we have a node with only zone_movable
Date: Tue, 2 Apr 2019 12:11:16 +0800
Message-ID: <1554178276-10372-1-git-send-email-fanglinxu@huawei.com>
X-Mailer: git-send-email 2.8.1.windows.1
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.66.68.70]
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

commit <342332e6a925> ("mm/page_alloc.c: introduce kernelcore=mirror
option") and series patches rewrote the calculation of node spanned
pages.
commit <e506b99696a2> (mem-hotplug: fix node spanned pages when we have a
movable node), but the current code still has problems,
when we have a node with only zone_movable and the node id is not zero,
the size of node spanned pages is double added.
That's because we have an empty normal zone, and zone_start_pfn or
zone_end_pfn is not between arch_zone_lowest_possible_pfn and
arch_zone_highest_possible_pfn, so we need to use clamp to constrain the
range just like the commit <96e907d13602> (bootmem: Reimplement
__absent_pages_in_range() using for_each_mem_pfn_range()).

e.g.
Zone ranges:
  DMA      [mem 0x0000000000001000-0x0000000000ffffff]
  DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
  Normal   [mem 0x0000000100000000-0x000000023fffffff]
Movable zone start for each node
  Node 0: 0x0000000100000000
  Node 1: 0x0000000140000000
Early memory node ranges
  node   0: [mem 0x0000000000001000-0x000000000009efff]
  node   0: [mem 0x0000000000100000-0x00000000bffdffff]
  node   0: [mem 0x0000000100000000-0x000000013fffffff]
  node   1: [mem 0x0000000140000000-0x000000023fffffff]

node 0 DMA	spanned:0xfff   present:0xf9e   absent:0x61
node 0 DMA32	spanned:0xff000 present:0xbefe0	absent:0x40020
node 0 Normal	spanned:0	present:0	absent:0
node 0 Movable	spanned:0x40000 present:0x40000 absent:0
On node 0 totalpages(node_present_pages): 1048446
node_spanned_pages:1310719
node 1 DMA	spanned:0	    present:0		absent:0
node 1 DMA32	spanned:0	    present:0		absent:0
node 1 Normal	spanned:0x100000    present:0x100000	absent:0
node 1 Movable	spanned:0x100000    present:0x100000	absent:0
On node 1 totalpages(node_present_pages): 2097152
node_spanned_pages:2097152
Memory: 6967796K/12582392K available (16388K kernel code, 3686K rwdata,
4468K rodata, 2160K init, 10444K bss, 5614596K reserved, 0K
cma-reserved)

It shows that the current memory of node 1 is double added.
After this patch, the problem is fixed.

node 0 DMA	spanned:0xfff   present:0xf9e   absent:0x61
node 0 DMA32	spanned:0xff000 present:0xbefe0	absent:0x40020
node 0 Normal	spanned:0	present:0	absent:0
node 0 Movable	spanned:0x40000 present:0x40000 absent:0
On node 0 totalpages(node_present_pages): 1048446
node_spanned_pages:1310719
node 1 DMA	spanned:0	    present:0		absent:0
node 1 DMA32	spanned:0	    present:0		absent:0
node 1 Normal	spanned:0	    present:0		absent:0
node 1 Movable	spanned:0x100000    present:0x100000	absent:0
On node 1 totalpages(node_present_pages): 1048576
node_spanned_pages:1048576
memory: 6967796K/8388088K available (16388K kernel code, 3686K rwdata,
4468K rodata, 2160K init, 10444K bss, 1420292K reserved, 0K
cma-reserved)

Signed-off-by: Linxu Fang <fanglinxu@huawei.com>
---
 mm/page_alloc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3eb01de..5cd0cb2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6233,13 +6233,15 @@ static unsigned long __init zone_spanned_pages_in_node(int nid,
 					unsigned long *zone_end_pfn,
 					unsigned long *ignored)
 {
+	unsigned long zone_low = arch_zone_lowest_possible_pfn[zone_type];
+	unsigned long zone_high = arch_zone_highest_possible_pfn[zone_type];
 	/* When hotadd a new node from cpu_up(), the node should be empty */
 	if (!node_start_pfn && !node_end_pfn)
 		return 0;
 
 	/* Get the start and end of the zone */
-	*zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
-	*zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];
+	*zone_start_pfn = clamp(node_start_pfn, zone_low, zone_high);
+	*zone_end_pfn = clamp(node_end_pfn, zone_low, zone_high);
 	adjust_zone_range_for_zone_movable(nid, zone_type,
 				node_start_pfn, node_end_pfn,
 				zone_start_pfn, zone_end_pfn);
-- 
1.8.5.6


