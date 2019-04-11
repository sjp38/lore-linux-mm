Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CAF6C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:31:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAA622146F
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:31:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="EU8l7n5j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAA622146F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 622CE6B026E; Thu, 11 Apr 2019 17:31:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D2F26B0284; Thu, 11 Apr 2019 17:31:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C2446B0285; Thu, 11 Apr 2019 17:31:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2A4396B026E
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 17:31:49 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id n10so6943806qtk.9
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:31:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=3OqG8bpvaiUhwKE/BjM7CPLdVnvy5MPJ5aI4Qoz+FGA=;
        b=gxc/B4O0rhSXxafXR65xxXQ7/H2D29yy+ruN5EFEbGDllNOrN/nl5Q8oSr9XLlK85g
         YGTTePKnmk6TspZj90fJxtkp23z/9zpqlFCY8DInozUQ3W5QnNwQs7uIfSIcSLvxusaE
         Yo28MpN94ijxZZJVtH9dGYKrquyeveDSRVBywnMQKVenHR4X1ThOkP0uqezpPfdkt2JL
         Vja1+m6pqynA2k7aThRjNI5+FHcVDZZLA6R8aDjBYvjfOLA9gdSFtOZoheut0DbjKe4i
         QbRQbKOoJwlhp5dq58nidLY6c/ibKNYTp/2HEC1v7krAfjsAgsXwFUbngYQD/Z4oBcvp
         mm8w==
X-Gm-Message-State: APjAAAXPMV+V+4jmb5mMUVW2tzchChylLQ1j0iAkEeC3oadGi21GiWLX
	fcgZyoBD8tFEQJiuP7mjldigEQ3H0LR/isTI/x24+EurfEpEKMe3kfkGjwcwlhysrJNxk9Kol7S
	5qAyAazbtcY756M9MV8Fuc65WaYvGI9EBwxIYcF25Tp/tWB5H9y5nkQOLKz2waCBaaA==
X-Received: by 2002:ac8:8d4:: with SMTP id y20mr44205831qth.13.1555018308685;
        Thu, 11 Apr 2019 14:31:48 -0700 (PDT)
X-Received: by 2002:ac8:8d4:: with SMTP id y20mr44205750qth.13.1555018307537;
        Thu, 11 Apr 2019 14:31:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555018307; cv=none;
        d=google.com; s=arc-20160816;
        b=f96Pa4oYY+wqGyHtnHRksI21ZWNe6qZLj+DyBiA5YoHTzeB9QLFSAFGH59FYkOiaq5
         WXnZaw62mcFTkdsru8USH9sW5xdazQYdUHwHr3MzZjf7pGntSOKpHy6aFkWFxjbzcuFr
         aKpUqPQaadfyUvRmMZFkpMb6skQLnblqNF83U0tb1QLHn6ksZwNnl24RTY4hH3CfHXiS
         FYqeGuVTBK8wjCofg4HhpnBBniMzL2MrYf87HQIJq6TGEZLeerIVcosKcU6lbLAzX3Nk
         jG3WKEHNg00O3iamjZodnA2vvwAG/eajAjRH4gI3abh4VgWm22gxzy+4gwxmGjqi8Hkw
         TeuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=3OqG8bpvaiUhwKE/BjM7CPLdVnvy5MPJ5aI4Qoz+FGA=;
        b=Jyq92SsbKdj9DXlv/pLVZ4pNISnMLy4NZIDgbmIueG0Mby0WuksmF86DzZ3dgAGPtX
         4nJU/odlmwbo6dpchH0xLn+3WAw7b4QG7gbUvqeRHOIw3IZ09HZZjJ5uwxqhArL/O1iK
         xe5s9Mdc/TkAhn+mQ+krTi6qX2iLIXYCJ+LlWcDmM29q87oXPeOclCv6na+zeOk1xnsw
         kRyrAX/zH9ZlS7MOMdt2AmADdfU7xZjac9zVDp/8A10B03/wce1pp9No6YlX/epF41YI
         3JPAYWDGrhcC2lLM8YFd5/7wpQpIZlfcfxo0JIaLhuJZFgNAeqHAVlQcE+K9nmsT36lU
         ptcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=EU8l7n5j;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q7sor36170979qvh.48.2019.04.11.14.31.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 14:31:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=EU8l7n5j;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=3OqG8bpvaiUhwKE/BjM7CPLdVnvy5MPJ5aI4Qoz+FGA=;
        b=EU8l7n5jrbaWT2rnF5SCnjzHOtqGp+detg+64WnL25G/HHKCHiFxcpQjAI9iMFsUVr
         aQznuQJq1S2biRCBSk4PlYxEgwPFOi32NJjhYXVRjG4/LHiqtoRPLb2F05y5xEwJZPDQ
         jck9lw413exw9RYdeq2xhfp/RiqdXR+R2F8SWqH0pbo1g9bZvQwwGzxqCTUODemukeaX
         vRr0a8oKHpzRx6LE6rkoClK+6l0lm9AACZK5xkuDi+RkyJPBpBIgtFcb8daAk2Zhieb4
         wLvdQFoeCp5SIkjHKULM1jlarkaoVvXDsqBS9JupMhIQPE4Rv30Lek2gqF2A+AQ8AHWq
         8WIA==
X-Google-Smtp-Source: APXvYqwUQeZO4niaQIliUfDO/bTDu2EtxF2q3U/X8Wy4Miirz3W0LXYoWnUZnbNSCo/cbvWCXJ/p5A==
X-Received: by 2002:a0c:afd4:: with SMTP id t20mr43584794qvc.128.1555018306182;
        Thu, 11 Apr 2019 14:31:46 -0700 (PDT)
Received: from Qians-MBP.fios-router.home (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id e128sm13871914qkd.79.2019.04.11.14.31.45
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 14:31:45 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	osalvador@suse.de,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] mm/hotplug: treat CMA pages as unmovable
Date: Thu, 11 Apr 2019 17:31:24 -0400
Message-Id: <20190411213124.8254-1-cai@lca.pw>
X-Mailer: git-send-email 2.20.1 (Apple Git-117)
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When offlining a memory block that contains reserved CMA areas, it will
set those page blocks migration type as MIGRATE_ISOLATE. Then, onlining
will set them as MIGRATE_MOVABLE. As the results, those page blocks lose
their original types, i.e., MIGRATE_CMA, and then it causes troubles
like accounting for CMA areas becomes inconsist,

 # grep cma /proc/vmstat
 nr_free_cma 205824

 # cat /sys/kernel/debug/cma/cma-kvm_cma/count
 209920

Also, kmemleak still think those memory address are reserved but have
already been used by the buddy allocator after onlining.

Offlined Pages 4096
kmemleak: Cannot insert 0xc000201f7d040008 into the object search tree
(overlaps existing)
Call Trace:
[c00000003dc2faf0] [c000000000884b2c] dump_stack+0xb0/0xf4 (unreliable)
[c00000003dc2fb30] [c000000000424fb4] create_object+0x344/0x380
[c00000003dc2fbf0] [c0000000003d178c] __kmalloc_node+0x3ec/0x860
[c00000003dc2fc90] [c000000000319078] kvmalloc_node+0x58/0x110
[c00000003dc2fcd0] [c000000000484d9c] seq_read+0x41c/0x620
[c00000003dc2fd60] [c0000000004472bc] __vfs_read+0x3c/0x70
[c00000003dc2fd80] [c0000000004473ac] vfs_read+0xbc/0x1a0
[c00000003dc2fdd0] [c00000000044783c] ksys_read+0x7c/0x140
[c00000003dc2fe20] [c00000000000b108] system_call+0x5c/0x70
kmemleak: Kernel memory leak detector disabled
kmemleak: Object 0xc000201cc8000000 (size 13757317120):
kmemleak:   comm "swapper/0", pid 0, jiffies 4294937297
kmemleak:   min_count = -1
kmemleak:   count = 0
kmemleak:   flags = 0x5
kmemleak:   checksum = 0
kmemleak:   backtrace:
     cma_declare_contiguous+0x2a4/0x3b0
     kvm_cma_reserve+0x11c/0x134
     setup_arch+0x300/0x3f8
     start_kernel+0x9c/0x6e8
     start_here_common+0x1c/0x4b0
kmemleak: Automatic memory scanning thread ended

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/page_alloc.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d96ca5bc555b..896db9241fa6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8015,14 +8015,18 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 	 * can still lead to having bootmem allocations in zone_movable.
 	 */
 
-	/*
-	 * CMA allocations (alloc_contig_range) really need to mark isolate
-	 * CMA pageblocks even when they are not movable in fact so consider
-	 * them movable here.
-	 */
-	if (is_migrate_cma(migratetype) &&
-			is_migrate_cma(get_pageblock_migratetype(page)))
-		return false;
+	if (is_migrate_cma(get_pageblock_migratetype(page))) {
+		/*
+		 * CMA allocations (alloc_contig_range) really need to mark
+		 * isolate CMA pageblocks even when they are not movable in fact
+		 * so consider them movable here.
+		 */
+		if (is_migrate_cma(migratetype))
+			return false;
+
+		pr_warn("page: %px is in CMA", page);
+		return true;
+	}
 
 	pfn = page_to_pfn(page);
 	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
-- 
2.20.1 (Apple Git-117)

