Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78508C5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 08:19:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25E26218A3
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 08:19:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25E26218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F59D6B0003; Wed,  3 Jul 2019 04:19:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A6B98E0003; Wed,  3 Jul 2019 04:19:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BB138E0001; Wed,  3 Jul 2019 04:19:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 233406B0003
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 04:19:35 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id m16so862376otq.13
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 01:19:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=HH0ePnYzMmDQP/lIcsWqWfZFxhs0lGImao2l20srJLg=;
        b=WBu8i3SwPpsRnJT4lz+IvPUUomZz+DSGA8zOwGr6SgSLLTZHO6Yjuzs1zfAh1mNt38
         0c8xXn8sBf46l0HTW2BmTj/hfs8Q9WasNCFPDcCVq1WrTp0U5b2YOZNZuryMqprvD+mR
         O7kDtXc9vvgdL9MYeWgG1LWGwkX6NEWBw32SXOkA+fsSM3KlZctiiKDIdS9UEwIhjEgp
         kPQE/RUpFRPx3MEsg1R3IJLdzRs87WfYxLD2GsEC11Q2sI3Rm8MrraeZPXmsCbGC6eYy
         StlJc/AHA2MJMjl39ODd78sPD9O/MTXUUMSm8y2HrlIhPcExW+fOw0AXepS228/spZKU
         qtHw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of wangkefeng.wang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=wangkefeng.wang@huawei.com
X-Gm-Message-State: APjAAAXju8HvQ4qi3vjeCAWEOxgz/8oH4eBVaiSJMrrx4h2YmhS6LAgv
	pg5hNsyUD7xaD2MVitc6mGeBJpenumJwNV+qY0Zfl+xbRFdnRvU/UB5tdVvr7ZnljJygWeMjzxN
	JgFhIIilwMn59OmyDpHCPp8MUKWgsOECHj5x268bwz7QeTRRFa2dPstrydekzqir7gA==
X-Received: by 2002:a05:6808:87:: with SMTP id s7mr5759057oic.88.1562141974645;
        Wed, 03 Jul 2019 01:19:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaDlx8ACCoAEg8kSMYWXxmVj2p3YYj3wmGgsAq7Ga2xHZDehNLhCzhf1HgDphubTu7VdhI
X-Received: by 2002:a05:6808:87:: with SMTP id s7mr5759010oic.88.1562141973314;
        Wed, 03 Jul 2019 01:19:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562141973; cv=none;
        d=google.com; s=arc-20160816;
        b=eDqm6jHwTPPYBmsfn+kcUqGyJFqrSMNwVyLGNKgHPwtARVdvL//r+J2+QnfIvGohbX
         CQez09AqemSHbHfmuUV+QS89+GY1s4zRumgBmccQRwHA17TOzGnqjS7+TNgiZV4saJXT
         QG1y/JJCDdBuXA8yo+4sI0h3S1xBArAXip0ueUl8BvCrxubjuXoVtT894SiANo1pnL2k
         ZcWa9kvVRd7SUxIiiMMQDP+8joIju6KqAPnXehEnPJIDzP+8j+qExvtlp61KddoBbE4s
         pndOegnQH/BPKYeFmza88oVxzpym9V0/J6BYIPXt4gFTI7FRTbB7iVxhnOveHcpNtiXc
         vveg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=HH0ePnYzMmDQP/lIcsWqWfZFxhs0lGImao2l20srJLg=;
        b=VKJwfPETlwUlC6A+7n1XLPnRuYRWUGN1fin5zpauWLzQJLFtrIHHJvYDaI4Cs/hKKP
         BULGjuBLTzlaLBVdx8X3Jt2o9Co4Z0vwL/lSmIBJYaV3GyoJSsEj1eFaZRun1lnMWLFa
         0dJqrke8I3MgkZIvFvqvJWxoDMaAcKyg0GVLYTyGSdm/60/WC3htAqPOMl1exU7Hh8Au
         6iK1wqeHpvLvEPv+ta3Agx9JAtXsKkfFusY+NC4Wa1NlEw3RalmN5PSJG+mjP0nZWKx+
         zHbdCYfP37qrwIeB4wz6LwglzL0TomnLJgv5O7uc1wmLYRlJjaF7qIQDFkjiFVME9BVe
         VB/w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of wangkefeng.wang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=wangkefeng.wang@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id z36si1530853ota.112.2019.07.03.01.19.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 01:19:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of wangkefeng.wang@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of wangkefeng.wang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=wangkefeng.wang@huawei.com
Received: from DGGEMS410-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id BDC86B05E55C4D96440A;
	Wed,  3 Jul 2019 16:19:29 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS410-HUB.china.huawei.com (10.3.19.210) with Microsoft SMTP Server id
 14.3.439.0; Wed, 3 Jul 2019 16:19:24 +0800
From: Kefeng Wang <wangkefeng.wang@huawei.com>
To: Dennis Zhou <dennis@kernel.org>, Tejun Heo <tj@kernel.org>, "Christoph
 Lameter" <cl@linux.com>
CC: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>, Kefeng Wang
	<wangkefeng.wang@huawei.com>
Subject: [PATCH] percpu: Make pcpu_setup_first_chunk() void function
Date: Wed, 3 Jul 2019 16:25:52 +0800
Message-ID: <20190703082552.69951-1-wangkefeng.wang@huawei.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-Originating-IP: [10.175.113.25]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

pcpu_setup_first_chunk() will panic or BUG_ON if the are some
error and doesn't return any error, hence it can be defined to
return void.

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---
 arch/ia64/mm/contig.c    |  5 +----
 arch/ia64/mm/discontig.c |  5 +----
 include/linux/percpu.h   |  2 +-
 mm/percpu.c              | 17 ++++++-----------
 4 files changed, 9 insertions(+), 20 deletions(-)

diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index d29fb6b9fa33..db09a693f094 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -134,10 +134,7 @@ setup_per_cpu_areas(void)
 	ai->atom_size		= PAGE_SIZE;
 	ai->alloc_size		= PERCPU_PAGE_SIZE;
 
-	rc = pcpu_setup_first_chunk(ai, __per_cpu_start + __per_cpu_offset[0]);
-	if (rc)
-		panic("failed to setup percpu area (err=%d)", rc);
-
+	pcpu_setup_first_chunk(ai, __per_cpu_start + __per_cpu_offset[0]);
 	pcpu_free_alloc_info(ai);
 }
 #else
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 05490dd073e6..004dee231874 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -245,10 +245,7 @@ void __init setup_per_cpu_areas(void)
 		gi->cpu_map		= &cpu_map[unit];
 	}
 
-	rc = pcpu_setup_first_chunk(ai, base);
-	if (rc)
-		panic("failed to setup percpu area (err=%d)", rc);
-
+	pcpu_setup_first_chunk(ai, base);
 	pcpu_free_alloc_info(ai);
 }
 #endif
diff --git a/include/linux/percpu.h b/include/linux/percpu.h
index 9909dc0e273a..5e76af742c80 100644
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -105,7 +105,7 @@ extern struct pcpu_alloc_info * __init pcpu_alloc_alloc_info(int nr_groups,
 							     int nr_units);
 extern void __init pcpu_free_alloc_info(struct pcpu_alloc_info *ai);
 
-extern int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
+extern void __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 					 void *base_addr);
 
 #ifdef CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK
diff --git a/mm/percpu.c b/mm/percpu.c
index 9821241fdede..ad32c3d11ca7 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -2267,12 +2267,9 @@ static void pcpu_dump_alloc_info(const char *lvl,
  * share the same vm, but use offset regions in the area allocation map.
  * The chunk serving the dynamic region is circulated in the chunk slots
  * and available for dynamic allocation like any other chunk.
- *
- * RETURNS:
- * 0 on success, -errno on failure.
  */
-int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
-				  void *base_addr)
+void __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
+				   void *base_addr)
 {
 	size_t size_sum = ai->static_size + ai->reserved_size + ai->dyn_size;
 	size_t static_size, dyn_size;
@@ -2457,7 +2454,6 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 
 	/* we're done */
 	pcpu_base_addr = base_addr;
-	return 0;
 }
 
 #ifdef CONFIG_SMP
@@ -2710,7 +2706,7 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 	struct pcpu_alloc_info *ai;
 	size_t size_sum, areas_size;
 	unsigned long max_distance;
-	int group, i, highest_group, rc;
+	int group, i, highest_group, rc = 0;
 
 	ai = pcpu_build_alloc_info(reserved_size, dyn_size, atom_size,
 				   cpu_distance_fn);
@@ -2795,7 +2791,7 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 		PFN_DOWN(size_sum), ai->static_size, ai->reserved_size,
 		ai->dyn_size, ai->unit_size);
 
-	rc = pcpu_setup_first_chunk(ai, base);
+	pcpu_setup_first_chunk(ai, base);
 	goto out_free;
 
 out_free_areas:
@@ -2920,7 +2916,7 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
 		unit_pages, psize_str, ai->static_size,
 		ai->reserved_size, ai->dyn_size);
 
-	rc = pcpu_setup_first_chunk(ai, vm.addr);
+	pcpu_setup_first_chunk(ai, vm.addr);
 	goto out_free_ar;
 
 enomem:
@@ -3014,8 +3010,7 @@ void __init setup_per_cpu_areas(void)
 	ai->groups[0].nr_units = 1;
 	ai->groups[0].cpu_map[0] = 0;
 
-	if (pcpu_setup_first_chunk(ai, fc) < 0)
-		panic("Failed to initialize percpu areas.");
+	pcpu_setup_first_chunk(ai, fc);
 	pcpu_free_alloc_info(ai);
 }
 
-- 
2.20.1

