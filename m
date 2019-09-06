Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E04EAC43140
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 14:53:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 878FF2082C
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 14:53:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="F08BO7BS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 878FF2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B9096B000A; Fri,  6 Sep 2019 10:53:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2908F6B000C; Fri,  6 Sep 2019 10:53:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A5CD6B000D; Fri,  6 Sep 2019 10:53:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0168.hostedemail.com [216.40.44.168])
	by kanga.kvack.org (Postfix) with ESMTP id EADAD6B000A
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 10:53:37 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 90AA3611D
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 14:53:37 +0000 (UTC)
X-FDA: 75904789674.09.hand82_59baf5824b341
X-HE-Tag: hand82_59baf5824b341
X-Filterd-Recvd-Size: 10559
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 14:53:36 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id q21so4634347pfn.11
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 07:53:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=yrM68/18qPKHZ9DUNXRIzqwwEnWiG4Tl6cc4C1fGcgo=;
        b=F08BO7BSrGrfQeuaby107wTUULESYHMJ7AOaEF+Hn8D5HHpHpYjfiOdTOXZsgN96mb
         zo3cIiADSm7/YUbXVc9ff5E1bg9AZLc6AoFPIq979AlGhTl4bohVyZhnCWM1r7OyEmxr
         pfYSTAppGSDLHI+eetE+RJIow7NJz9/Ud08mUQ9gIInnCxKwk26kzCo4geaCyX5g1BDK
         xCK3WPe0f7vo9mv8eOFY6tuZqetwYK++GD9OnB/3eQP0DzzCjqZwvI27ul+Ek3ZizGoa
         KyluUVUB7KGqWoqEUtKgdn6uonAibcK9ouPqdNAMP17fsIm1YXqbs0JBhQ8MD30VZx/o
         N0Wg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=yrM68/18qPKHZ9DUNXRIzqwwEnWiG4Tl6cc4C1fGcgo=;
        b=ORUfGSjEV1T08dTcVmdmG1Qx6ECASkbClEt7Now02eVXZg5m6YLXw8MaCV02tJofJ4
         40pxfNppzza35dGxCGghJSS2gflODsCHMy35Dr3OTdrQ9Zmuf7puk2n8xoIqvtxpccqx
         /DFRKz0dRWFeyIWgzL0+bKfvrBto14ODCw8PoNJwTVkCZwjF6FVH2uz1CevSpCCf8Ifg
         lYoKK0eiOnM/08wk7raQvbcNvCP1Q9Fs32pA26XhoD/SYaxY4KRgbyQQn4JXb8C1TPEi
         yAZHgVtGhevyDjSwGY7fi+f1Z+rokHyZfxyuneIqCXYqf3VTnjxem1QagvoHw8oqjRjm
         4ZOQ==
X-Gm-Message-State: APjAAAXMxTTli1f+I47gUa8rWOj/UPpE6vAPWsLEvTaWk6N8d4gA30q8
	GbZnE8VkKyqWl51Z505egsM=
X-Google-Smtp-Source: APXvYqyrQkzzi8Sbhj6vhLTR4dGTZW+Kk2AIeDlnJIKM3KMBnXdma+i7svr0tEnpvrl548l+Yy3/6Q==
X-Received: by 2002:a62:e403:: with SMTP id r3mr10963491pfh.251.1567781615299;
        Fri, 06 Sep 2019 07:53:35 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id 67sm5207877pjo.29.2019.09.06.07.53.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Sep 2019 07:53:34 -0700 (PDT)
Subject: [PATCH v8 2/7] mm: Adjust shuffle code to allow for future
 coalescing
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, mst@redhat.com, david@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org,
 mhocko@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
 virtio-dev@lists.oasis-open.org, osalvador@suse.de
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Fri, 06 Sep 2019 07:53:34 -0700
Message-ID: <20190906145333.32552.95238.stgit@localhost.localdomain>
In-Reply-To: <20190906145213.32552.30160.stgit@localhost.localdomain>
References: <20190906145213.32552.30160.stgit@localhost.localdomain>
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

Move the head/tail adding logic out of the shuffle code and into the
__free_one_page function since ultimately that is where it is really
needed anyway. By doing this we should be able to reduce the overhead
and can consolidate all of the list addition bits in one spot.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/mmzone.h |   12 --------
 mm/page_alloc.c        |   70 +++++++++++++++++++++++++++---------------------
 mm/shuffle.c           |    9 +-----
 mm/shuffle.h           |   12 ++++++++
 4 files changed, 53 insertions(+), 50 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index bda20282746b..125f300981c6 100644
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
index c5d62f1c2851..4e4356ba66c7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -878,6 +878,36 @@ static inline struct capture_control *task_capc(struct zone *zone)
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
@@ -906,11 +936,12 @@ static inline void __free_one_page(struct page *page,
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
 
@@ -979,35 +1010,12 @@ static inline void __free_one_page(struct page *page,
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
+	if (is_shuffle_order(order) ? shuffle_pick_tail() :
+	    buddy_merge_likely(pfn, buddy_pfn, page, order))
+		add_to_free_area_tail(page, area, migratetype);
 	else
-		add_to_free_area(page, &zone->free_area[order], migratetype);
-
+		add_to_free_area(page, area, migratetype);
 }
 
 /*
diff --git a/mm/shuffle.c b/mm/shuffle.c
index 9ba542ecf335..345cb4347455 100644
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
@@ -190,8 +189,7 @@ struct batched_bit_entropy {
 
 static DEFINE_PER_CPU(struct batched_bit_entropy, batched_entropy_bool);
 
-void add_to_free_area_random(struct page *page, struct free_area *area,
-		int migratetype)
+bool __shuffle_pick_tail(void)
 {
 	struct batched_bit_entropy *batch;
 	unsigned long entropy;
@@ -213,8 +211,5 @@ void add_to_free_area_random(struct page *page, struct free_area *area,
 	batch->position = position;
 	entropy = batch->entropy_bool;
 
-	if (1ul & (entropy >> position))
-		add_to_free_area(page, area, migratetype);
-	else
-		add_to_free_area_tail(page, area, migratetype);
+	return 1ul & (entropy >> position);
 }
diff --git a/mm/shuffle.h b/mm/shuffle.h
index 777a257a0d2f..0723eb97f22f 100644
--- a/mm/shuffle.h
+++ b/mm/shuffle.h
@@ -3,6 +3,7 @@
 #ifndef _MM_SHUFFLE_H
 #define _MM_SHUFFLE_H
 #include <linux/jump_label.h>
+#include <linux/random.h>
 
 /*
  * SHUFFLE_ENABLE is called from the command line enabling path, or by
@@ -22,6 +23,7 @@ enum mm_shuffle_ctl {
 DECLARE_STATIC_KEY_FALSE(page_alloc_shuffle_key);
 extern void page_alloc_shuffle(enum mm_shuffle_ctl ctl);
 extern void __shuffle_free_memory(pg_data_t *pgdat);
+extern bool __shuffle_pick_tail(void);
 static inline void shuffle_free_memory(pg_data_t *pgdat)
 {
 	if (!static_branch_unlikely(&page_alloc_shuffle_key))
@@ -43,6 +45,11 @@ static inline bool is_shuffle_order(int order)
 		return false;
 	return order >= SHUFFLE_ORDER;
 }
+
+static inline bool shuffle_pick_tail(void)
+{
+	return __shuffle_pick_tail();
+}
 #else
 static inline void shuffle_free_memory(pg_data_t *pgdat)
 {
@@ -60,5 +67,10 @@ static inline bool is_shuffle_order(int order)
 {
 	return false;
 }
+
+static inline bool shuffle_pick_tail(void)
+{
+	return false;
+}
 #endif
 #endif /* _MM_SHUFFLE_H */


