Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB9F0C282CB
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 18:16:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A8A52175B
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 18:16:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HBVmbsGO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A8A52175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDCE78E0052; Mon,  4 Feb 2019 13:16:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8C6D8E001C; Mon,  4 Feb 2019 13:16:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA3828E0052; Mon,  4 Feb 2019 13:16:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 86D3A8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 13:16:01 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id f69so505702pff.5
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 10:16:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=BH3kUGOLH4rXiV4UZ/yFSk8Kv2EdG9WZAShG2rqLHTM=;
        b=LQh9yU4//BZr9AVCcEDPO6wBBstLYo7YQivfNeZe214fIJo4pmTFr7YnQ68E0XWpwE
         S4uY3g4DYPzpU/ITRsbVs5ek/XzFR7CvtmFtMzBm4W3EgfZ4YSsZu47qxPvnCKJa4D6R
         lU1oBhyDGMk+NIIYPRTWq/XAf7l/mU6tbBzcew/YPyQQfKWx7TflIV2Bd2LL1fvBT5g/
         uNeZXXL7D43VAMEEZ/t+CbKZiMz+CbQDEP6e5+lnB7+Hw3f+OiQK3vG30Qfdm4NYZP7l
         o9BtchhuZg0KmQwzqyvDrpprLfhRjG7ITIfL5vYuQnv4tVDrfryLtoHjbv2z8N1bs78W
         G59g==
X-Gm-Message-State: AHQUAuYbecBhJRYSlc0EoIqNBvr/yW3ysf4LyNhAkSKllEVrGuFGtE+i
	gw97FBibNDWWA7i6vdqTlLJXl4YFZkHVAMmQer3+boiJr0vs188+4a+ROJ2rw6vCOfk1QlPAc/l
	DRlzICFZpqUtdDlrDcPUSottFwDRuuKjYgJOkXeS/mv9LGGfOlt3AvUNai7QsjuylyjFhmO72Lg
	l/A+lquxmpDcluvIixy0xskgaFfOZrQB5USIWFzXh2Y8eLYqFy3rOsxTryEemmyxBWQjoCLlLuT
	wVgNqqkwpNJRe+swz58qDNgSWp76KfBhdtDUgcNTsIDUVQx/WhCHq5STIaFyRrxAA4XmVGQIFET
	qLv5z7N+c95cRc/1bCTVyXZ18bTbBwNV+zgae0hKE+aHNurGTOlUnHxMMrwl+zEU/CM2hA8kx55
	1
X-Received: by 2002:a65:4904:: with SMTP id p4mr618141pgs.384.1549304161153;
        Mon, 04 Feb 2019 10:16:01 -0800 (PST)
X-Received: by 2002:a65:4904:: with SMTP id p4mr618085pgs.384.1549304160377;
        Mon, 04 Feb 2019 10:16:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549304160; cv=none;
        d=google.com; s=arc-20160816;
        b=wYAeOhW00YO05OfQjYZw1XCPpniXjqzeEnv2LtHxsjkef6uM+6WG/zTWHa0CLGT8ei
         YRm8xFdkLyk/nXSXHQn1GZZ4xBc9rKkv4mhAAXSUOaj+5qdo/xKeXFr8QzfmhS9qyz94
         twA39oGC342ETzraN08ElV1msNZ4eo0KyeUn7E/Um+Ias1tg/6dEN4cfyfoAExV+Q0AU
         PUlmzwCCDuDpHxdvt+FP4/J7gfYBJLAWy1acG9vrDoU+qdSqqFVcxTBK6VN/fryt6O+5
         nsbLbbHCDdOfVRszYuUmV86SYmeN2bMuShO1BSJpmQBeoaiXTmmlJd8Ag8nifBBPlxW2
         njRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=BH3kUGOLH4rXiV4UZ/yFSk8Kv2EdG9WZAShG2rqLHTM=;
        b=XmZDpC2zd9DofX4XVr+jUuHiHdJVnhjGl3gj+1uBz0fshZcTswXUgnoCNbA4io34/9
         yYT18niLx1ybEU8NDAkHc2cC6OrmXi2/6ycozjy9D++TOc6ux+q2F2KLhlOGL0WuPubh
         uwphpwPt31hu8L0CyYDe5sX+VSZJaOcJDG50+vr2hgrS9GOYK1SQOxVSXTK9u9dogjVy
         L/IDh8X1uBRaZxbe4jwlr17sXBwF6Y0jWawRAm2egQzZG1MXJ9nSfvvE5EqeaINLwF78
         ybr4ZhHEy559mAG86f5282LAPWGcXXJOU/c1nTUJwz9Ou0IBeWH+Ce9E5doIZCCyT2an
         IFKA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HBVmbsGO;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z1sor1476409pfl.9.2019.02.04.10.16.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Feb 2019 10:16:00 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HBVmbsGO;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=BH3kUGOLH4rXiV4UZ/yFSk8Kv2EdG9WZAShG2rqLHTM=;
        b=HBVmbsGODWcw1Zzq6loJb9qa/nqzCqIjc1caWDwzjyVMZ0cmFJhvTchZVI2WOq0SGD
         K4mHhjv+oZT7Dk4YHXIh0FzSfuUvWLrG1BGCDIpuHv+axbdWqQYThhkdY5vAh6CubTRI
         6G4HgTpmqZTTI1aEb1ZK3zYjOIvHQ9+xhErmeERXv3lpM/Hbv04CdXW8ILjza6RN2IJa
         q+7M7+iRHnlW3ZY88/DcYz7Uy5sz23/8oKf6rqSooCtg8X23HxZJlCOC3paGvl4fG0eN
         amSuhIznkGkG7AuuxMuc46cqDxIP0uc2r4qUVRoHCp5Qyz4dV046yyikJ4zcIEwnzJH3
         XWKA==
X-Google-Smtp-Source: AHgI3IatDmHCVIQvkPjf403DPZXddCGM1dtT3pI76p0hmmxOMfvPU6zQrFp/JIlwwbmQbdyNZzEbOA==
X-Received: by 2002:a62:37c3:: with SMTP id e186mr635900pfa.251.1549304159979;
        Mon, 04 Feb 2019 10:15:59 -0800 (PST)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id d129sm991541pfc.31.2019.02.04.10.15.59
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 10:15:59 -0800 (PST)
Subject: [RFC PATCH 4/4] mm: Add merge page notifier
From: Alexander Duyck <alexander.duyck@gmail.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org
Cc: rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com, x86@kernel.org,
 mingo@redhat.com, bp@alien8.de, hpa@zytor.com, pbonzini@redhat.com,
 tglx@linutronix.de, akpm@linux-foundation.org
Date: Mon, 04 Feb 2019 10:15:58 -0800
Message-ID: <20190204181558.12095.83484.stgit@localhost.localdomain>
In-Reply-To: <20190204181118.12095.38300.stgit@localhost.localdomain>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

Because the implementation was limiting itself to only providing hints on
pages huge TLB order sized or larger we introduced the possibility for free
pages to slip past us because they are freed as something less then
huge TLB in size and aggregated with buddies later.

To address that I am adding a new call arch_merge_page which is called
after __free_one_page has merged a pair of pages to create a higher order
page. By doing this I am able to fill the gap and provide full coverage for
all of the pages huge TLB order or larger.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 arch/x86/include/asm/page.h |   12 ++++++++++++
 arch/x86/kernel/kvm.c       |   28 ++++++++++++++++++++++++++++
 include/linux/gfp.h         |    4 ++++
 mm/page_alloc.c             |    2 ++
 4 files changed, 46 insertions(+)

diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
index 4487ad7a3385..9540a97c9997 100644
--- a/arch/x86/include/asm/page.h
+++ b/arch/x86/include/asm/page.h
@@ -29,6 +29,18 @@ static inline void arch_free_page(struct page *page, unsigned int order)
 	if (static_branch_unlikely(&pv_free_page_hint_enabled))
 		__arch_free_page(page, order);
 }
+
+struct zone;
+
+#define HAVE_ARCH_MERGE_PAGE
+void __arch_merge_page(struct zone *zone, struct page *page,
+		       unsigned int order);
+static inline void arch_merge_page(struct zone *zone, struct page *page,
+				   unsigned int order)
+{
+	if (static_branch_unlikely(&pv_free_page_hint_enabled))
+		__arch_merge_page(zone, page, order);
+}
 #endif
 
 #include <linux/range.h>
diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
index 09c91641c36c..957bb4f427bb 100644
--- a/arch/x86/kernel/kvm.c
+++ b/arch/x86/kernel/kvm.c
@@ -785,6 +785,34 @@ void __arch_free_page(struct page *page, unsigned int order)
 		       PAGE_SIZE << order);
 }
 
+void __arch_merge_page(struct zone *zone, struct page *page,
+		       unsigned int order)
+{
+	/*
+	 * The merging logic has merged a set of buddies up to the
+	 * KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER. Since that is the case, take
+	 * advantage of this moment to notify the hypervisor of the free
+	 * memory.
+	 */
+	if (order != KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER)
+		return;
+
+	/*
+	 * Drop zone lock while processing the hypercall. This
+	 * should be safe as the page has not yet been added
+	 * to the buddy list as of yet and all the pages that
+	 * were merged have had their buddy/guard flags cleared
+	 * and their order reset to 0.
+	 */
+	spin_unlock(&zone->lock);
+
+	kvm_hypercall2(KVM_HC_UNUSED_PAGE_HINT, page_to_phys(page),
+		       PAGE_SIZE << order);
+
+	/* reacquire lock and resume freeing memory */
+	spin_lock(&zone->lock);
+}
+
 #ifdef CONFIG_PARAVIRT_SPINLOCKS
 
 /* Kick a cpu by its apicid. Used to wake up a halted vcpu */
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index fdab7de7490d..4746d5560193 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -459,6 +459,10 @@ static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
 #ifndef HAVE_ARCH_FREE_PAGE
 static inline void arch_free_page(struct page *page, int order) { }
 #endif
+#ifndef HAVE_ARCH_MERGE_PAGE
+static inline void
+arch_merge_page(struct zone *zone, struct page *page, int order) { }
+#endif
 #ifndef HAVE_ARCH_ALLOC_PAGE
 static inline void arch_alloc_page(struct page *page, int order) { }
 #endif
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c954f8c1fbc4..7a1309b0b7c5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -913,6 +913,8 @@ static inline void __free_one_page(struct page *page,
 		page = page + (combined_pfn - pfn);
 		pfn = combined_pfn;
 		order++;
+
+		arch_merge_page(zone, page, order);
 	}
 	if (max_order < MAX_ORDER) {
 		/* If we are here, it means order is >= pageblock_order.

