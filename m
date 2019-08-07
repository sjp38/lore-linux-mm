Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62A2CC32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 22:41:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AF8D21743
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 22:41:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="twb1ChdF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AF8D21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB68B6B0006; Wed,  7 Aug 2019 18:41:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C671B6B0007; Wed,  7 Aug 2019 18:41:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2E0A6B0008; Wed,  7 Aug 2019 18:41:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7D8D46B0006
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 18:41:51 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x10so57700260pfa.23
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 15:41:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=8Up9pojviE1H2/TRQbKOgpo0f8QQ8J9T+rPQMo69VKw=;
        b=AB1U9Ki3Eo2cIz9IPkR7voRpeRayYlnJmyj2+SfbMGEDMyou53cvc9Hwq6TMufHo4e
         A3lxxkeS7D0Zh4oNnZ4q0rkCgEiS4i0PIdwqlOVBBCCTnOlA3sKmtliy5qH6CdMC8umj
         h2tkSl4Esb4/N+at6yV4BxbxUMIOHzYqm4Wbl4IAvY3iWw8yS3W41F8c/ipMu7FA0mi6
         X2S8psarpHHqaxqfCLpPqLvqmXg3+/8/dyKM1xN4DIovk+mtd/JWyf2LmoAR3cGfRM1X
         FtxlZZPig+E4YyJYFAcYsqC7/OInmZwOSv+SgICYc5mz1uf/L8n+mZRFvVcukZZec/tq
         MN9Q==
X-Gm-Message-State: APjAAAWGDfBBNQtP8Sy9VTWnCJDtl0aEGoYh8jdOH/ToHX0krrOrSVbx
	nwMS9Nsw9T5L6QpqN60qdcMJhmvR/ju0tXE3SKvFzOxOzQi0CRE/DZh/haSX3AbFuqFb3q1Ob5O
	VLVRZN5l1R2pSxV2daVcxAO0I6Cuzr9E1l/lyyGk27lfERGkz/igiqFsKZiPdVTCBsg==
X-Received: by 2002:a17:902:bf09:: with SMTP id bi9mr9754639plb.143.1565217711152;
        Wed, 07 Aug 2019 15:41:51 -0700 (PDT)
X-Received: by 2002:a17:902:bf09:: with SMTP id bi9mr9754558plb.143.1565217709640;
        Wed, 07 Aug 2019 15:41:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565217709; cv=none;
        d=google.com; s=arc-20160816;
        b=062vO8CpJR+MHiK03w/akOdKETx1lUCzSywsjpUGK4+v+uE2B6ek7MkwFeB5EI+3VM
         U4FXWQAuRCCh+3sfG5GwphFx1T4NlL+nq9HoRI3+t/RVKT10TIE/a5/4dvN9iMaCHHTp
         1y+O8nmK18o0NsdD3MI8Oh0hT4ojRsJQkm1YV+7e5QhOKh27UW8ox2r5EPSh7+C+FrEv
         WPq5OTBst1Cb1mHBCtco3k9B/94opb5/CM8Z821ZeivMC3hPNmq3z+lQkN1WVFG7bVL6
         egHQXnyNzPHRUW+Iu2Gb3v67sLOHP8TkPqv5/P/WaufEi2GcOxZcAXPd9b6rIxQGpFI9
         AjsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=8Up9pojviE1H2/TRQbKOgpo0f8QQ8J9T+rPQMo69VKw=;
        b=gofj2FCCwAs8T+9eWdAQjpdVQAYcGIzzhh55uRd9O0/VgCh4JIrxGhLlxSCoL38h0C
         11EVObgeYVEPjfHgnz2yn4doC655gmHxr7zFjCHoPQNlHpkxvXRqgTpygHN6dqULlWis
         R+n+4VUD83989081kDS8X+RfOqmGCQDMe10CmQsp/4/jj5x/f8LeErWbA6mM1KQV/vUk
         N5VFA4RHsK8SbMmrMXSDzZRVMnYkHOmPJdkVFjaHAOROEA7TU1WxYJx4Ftyi4LtnGwic
         gtZh62ds4SjBkkPGNLq6WVqRubqKN6lnnkwFeVLoSB3ZV0xfreTwAcbGvvQOG6+W/KQ7
         gaQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=twb1ChdF;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 36sor108674244pla.71.2019.08.07.15.41.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 15:41:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=twb1ChdF;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=8Up9pojviE1H2/TRQbKOgpo0f8QQ8J9T+rPQMo69VKw=;
        b=twb1ChdF9mm5/SvP8D3BdlAipF9NU/SRUc2oKaJaq2HvxfIMq1sDXROsXi9oqZm0Wp
         jwxvuvI9hpXnWvy+Di39xcUS3oboVUe6uSLWAnyivbiG40k/p2yfAQTq5U1XB9QAJZt3
         1AoKB9PxKn2loUBcQvFKMFRptyxW5ZIm+5FJ6S14sqX72LMuspE37gx8GrOlkQSndkQZ
         MnRCOnJlyk/mdsSsQO6mDo8Pi0CFSOG6X8oZ8byIE6bgNx294Sl1XJks2/15qJbJjKKF
         ZgIii5Dh0tn/LFL1v0scJKFSe4n2mOxusG4+qCtQpwoWH3ED5EH2wTWZrJV2k0WwZ2fF
         +pwA==
X-Google-Smtp-Source: APXvYqzJYNarpgUwsZTkESntRvxWWyR0+dg59kN/YLV2Jg+dXU7+K5XQ4gsIwZaf1qs3yMJICG3T8Q==
X-Received: by 2002:a17:902:8f93:: with SMTP id z19mr9988466plo.97.1565217709173;
        Wed, 07 Aug 2019 15:41:49 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id h6sm93055440pfb.20.2019.08.07.15.41.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 15:41:48 -0700 (PDT)
Subject: [PATCH v4 1/6] mm: Adjust shuffle code to allow for future
 coalescing
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Date: Wed, 07 Aug 2019 15:41:47 -0700
Message-ID: <20190807224147.6891.8246.stgit@localhost.localdomain>
In-Reply-To: <20190807224037.6891.53512.stgit@localhost.localdomain>
References: <20190807224037.6891.53512.stgit@localhost.localdomain>
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

This patch is meant to move the head/tail adding logic out of the shuffle
code and into the __free_one_page function since ultimately that is where
it is really needed anyway. By doing this we should be able to reduce the
overhead and can consolidate all of the list addition bits in one spot.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/mmzone.h |   12 --------
 mm/page_alloc.c        |   70 +++++++++++++++++++++++++++---------------------
 mm/shuffle.c           |   24 ----------------
 mm/shuffle.h           |   32 ++++++++++++++++++++++
 4 files changed, 71 insertions(+), 67 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index aa0dd8ca36c8..c6bd8e9bb476 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -116,18 +116,6 @@ static inline void add_to_free_area_tail(struct page *page, struct free_area *ar
 	area->nr_free++;
 }
 
-#ifdef CONFIG_SHUFFLE_PAGE_ALLOCATOR
-/* Used to preserve page allocation order entropy */
-void add_to_free_area_random(struct page *page, struct free_area *area,
-		int migratetype);
-#else
-static inline void add_to_free_area_random(struct page *page,
-		struct free_area *area, int migratetype)
-{
-	add_to_free_area(page, area, migratetype);
-}
-#endif
-
 /* Used for pages which are on another list */
 static inline void move_to_free_area(struct page *page, struct free_area *area,
 			     int migratetype)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index af29c05e23aa..e3cb6e7aa296 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -877,6 +877,36 @@ static inline struct capture_control *task_capc(struct zone *zone)
 #endif /* CONFIG_COMPACTION */
 
 /*
+ * If this is not the largest possible page, check if the buddy
+ * of the next-highest order is free. If it is, it's possible
+ * that pages are being freed that will coalesce soon. In case,
+ * that is happening, add the free page to the tail of the list
+ * so it's less likely to be used soon and more likely to be merged
+ * as a higher order page
+ */
+static inline bool
+buddy_merge_likely(unsigned long pfn, unsigned long buddy_pfn,
+		   struct page *page, unsigned int order)
+{
+	struct page *higher_page, *higher_buddy;
+	unsigned long combined_pfn;
+
+	if (order >= MAX_ORDER - 2)
+		return false;
+
+	if (!pfn_valid_within(buddy_pfn))
+		return false;
+
+	combined_pfn = buddy_pfn & pfn;
+	higher_page = page + (combined_pfn - pfn);
+	buddy_pfn = __find_buddy_pfn(combined_pfn, order + 1);
+	higher_buddy = higher_page + (buddy_pfn - combined_pfn);
+
+	return pfn_valid_within(buddy_pfn) &&
+	       page_is_buddy(higher_page, higher_buddy, order + 1);
+}
+
+/*
  * Freeing function for a buddy system allocator.
  *
  * The concept of a buddy system is to maintain direct-mapped table
@@ -905,11 +935,12 @@ static inline void __free_one_page(struct page *page,
 		struct zone *zone, unsigned int order,
 		int migratetype)
 {
-	unsigned long combined_pfn;
+	struct capture_control *capc = task_capc(zone);
 	unsigned long uninitialized_var(buddy_pfn);
-	struct page *buddy;
+	unsigned long combined_pfn;
+	struct free_area *area;
 	unsigned int max_order;
-	struct capture_control *capc = task_capc(zone);
+	struct page *buddy;
 
 	max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
 
@@ -978,35 +1009,12 @@ static inline void __free_one_page(struct page *page,
 done_merging:
 	set_page_order(page, order);
 
-	/*
-	 * If this is not the largest possible page, check if the buddy
-	 * of the next-highest order is free. If it is, it's possible
-	 * that pages are being freed that will coalesce soon. In case,
-	 * that is happening, add the free page to the tail of the list
-	 * so it's less likely to be used soon and more likely to be merged
-	 * as a higher order page
-	 */
-	if ((order < MAX_ORDER-2) && pfn_valid_within(buddy_pfn)
-			&& !is_shuffle_order(order)) {
-		struct page *higher_page, *higher_buddy;
-		combined_pfn = buddy_pfn & pfn;
-		higher_page = page + (combined_pfn - pfn);
-		buddy_pfn = __find_buddy_pfn(combined_pfn, order + 1);
-		higher_buddy = higher_page + (buddy_pfn - combined_pfn);
-		if (pfn_valid_within(buddy_pfn) &&
-		    page_is_buddy(higher_page, higher_buddy, order + 1)) {
-			add_to_free_area_tail(page, &zone->free_area[order],
-					      migratetype);
-			return;
-		}
-	}
-
-	if (is_shuffle_order(order))
-		add_to_free_area_random(page, &zone->free_area[order],
-				migratetype);
+	area = &zone->free_area[order];
+	if (is_shuffle_order(order) ? shuffle_add_to_tail() :
+	    buddy_merge_likely(pfn, buddy_pfn, page, order))
+		add_to_free_area_tail(page, area, migratetype);
 	else
-		add_to_free_area(page, &zone->free_area[order], migratetype);
-
+		add_to_free_area(page, area, migratetype);
 }
 
 /*
diff --git a/mm/shuffle.c b/mm/shuffle.c
index 3ce12481b1dc..55d592e62526 100644
--- a/mm/shuffle.c
+++ b/mm/shuffle.c
@@ -4,7 +4,6 @@
 #include <linux/mm.h>
 #include <linux/init.h>
 #include <linux/mmzone.h>
-#include <linux/random.h>
 #include <linux/moduleparam.h>
 #include "internal.h"
 #include "shuffle.h"
@@ -182,26 +181,3 @@ void __meminit __shuffle_free_memory(pg_data_t *pgdat)
 	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
 		shuffle_zone(z);
 }
-
-void add_to_free_area_random(struct page *page, struct free_area *area,
-		int migratetype)
-{
-	static u64 rand;
-	static u8 rand_bits;
-
-	/*
-	 * The lack of locking is deliberate. If 2 threads race to
-	 * update the rand state it just adds to the entropy.
-	 */
-	if (rand_bits == 0) {
-		rand_bits = 64;
-		rand = get_random_u64();
-	}
-
-	if (rand & 1)
-		add_to_free_area(page, area, migratetype);
-	else
-		add_to_free_area_tail(page, area, migratetype);
-	rand_bits--;
-	rand >>= 1;
-}
diff --git a/mm/shuffle.h b/mm/shuffle.h
index 777a257a0d2f..add763cc0995 100644
--- a/mm/shuffle.h
+++ b/mm/shuffle.h
@@ -3,6 +3,7 @@
 #ifndef _MM_SHUFFLE_H
 #define _MM_SHUFFLE_H
 #include <linux/jump_label.h>
+#include <linux/random.h>
 
 /*
  * SHUFFLE_ENABLE is called from the command line enabling path, or by
@@ -43,6 +44,32 @@ static inline bool is_shuffle_order(int order)
 		return false;
 	return order >= SHUFFLE_ORDER;
 }
+
+static inline bool shuffle_add_to_tail(void)
+{
+	static u64 rand;
+	static u8 rand_bits;
+	u64 rand_old;
+
+	/*
+	 * The lack of locking is deliberate. If 2 threads race to
+	 * update the rand state it just adds to the entropy.
+	 */
+	if (rand_bits-- == 0) {
+		rand_bits = 64;
+		rand = get_random_u64();
+	}
+
+	/*
+	 * Test highest order bit while shifting our random value. This
+	 * should result in us testing for the carry flag following the
+	 * shift.
+	 */
+	rand_old = rand;
+	rand <<= 1;
+
+	return rand < rand_old;
+}
 #else
 static inline void shuffle_free_memory(pg_data_t *pgdat)
 {
@@ -60,5 +87,10 @@ static inline bool is_shuffle_order(int order)
 {
 	return false;
 }
+
+static inline bool shuffle_add_to_tail(void)
+{
+	return false;
+}
 #endif
 #endif /* _MM_SHUFFLE_H */

