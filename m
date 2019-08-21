Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD5E7C3A5A2
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 14:59:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 867DE22DA7
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 14:59:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ou5ImC3G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 867DE22DA7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 314446B02D1; Wed, 21 Aug 2019 10:59:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C4F76B02D2; Wed, 21 Aug 2019 10:59:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18EC26B02D3; Wed, 21 Aug 2019 10:59:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0053.hostedemail.com [216.40.44.53])
	by kanga.kvack.org (Postfix) with ESMTP id EBFBD6B02D1
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 10:59:34 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 984398248AC0
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:59:34 +0000 (UTC)
X-FDA: 75846743868.12.hose66_538526b97385f
X-HE-Tag: hose66_538526b97385f
X-Filterd-Recvd-Size: 11511
Received: from mail-pl1-f196.google.com (mail-pl1-f196.google.com [209.85.214.196])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:59:33 +0000 (UTC)
Received: by mail-pl1-f196.google.com with SMTP id 4so1460551pld.10
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 07:59:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Yi6WYldnJwTaPPOKzplfbrsRDAV4yzenPtD5HnKNjwo=;
        b=Ou5ImC3GBWLUA3lNlDGYzW9zKH8bQG7N1Zr3BtiSZJohqsohONH6X8mExc+KJ/Wbue
         JryEZFiOIykwXbFlgvve2CenotVcXC5co1SiZwHIGlY6VYCP8LFv1zsgoukWazWwKNBx
         DvmoP8VqsS6bis4uhMzRkKePCNfq3OM/fKWUqd64uXIagRBnrmhwc6FzZ4dCCf2TQNXp
         4XlVqehLeqJ1un7OQRGKikDZ9SUXcWtBw4ihdq7lQRuKkGnW7x6KsoSWFhon5u5ceish
         uBtE9Q5g7RDqh+NJjEXtBmIB0Pez4RdMSb0Ek25uxyFFLRnu8xOdonioV6KQUC4ug/eS
         Stjw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=Yi6WYldnJwTaPPOKzplfbrsRDAV4yzenPtD5HnKNjwo=;
        b=GzEz/AzggsQ2Isxm5lGCC25gl/E1QE4yBKagm6Xc/ratV7gsXqDD7kiuImsZK7SqAy
         O5LMQxx1/i310nmpVhzBSX53HCYXmef4AoFnNe7Nt5+m0c0SLY4LqZNqCVrFuSKQ53Td
         55udQp9e4tTdnfI6shbgCqzZLOIFTp59sXexF5QLXNkySPbPoISp2FOIKXs9nU8w1VeF
         2ku2mvbaUGmgDapJXeypy9oeE6buRHC+uPLKN7VojAstKs38naSSqThoWshO9APqD0ed
         euvj3rZltztmU7jgqI8H09FOg83ZXtOsuUhbtvcAhIc4KVmLr6iP61Zc9lWhMbeYdtWX
         2few==
X-Gm-Message-State: APjAAAXz6Ia80xADltgAFq3E81rtuiy9405Hkf142kOLkXrRzwNjxr+G
	gARuC45v5pt346IVtg24EC0=
X-Google-Smtp-Source: APXvYqz5V42dlogvFa4VorG9G5jfX3kPnSUuUtoaDltscBozsmGw0roKd7pCjPB8WcWJHylzLnxqAg==
X-Received: by 2002:a17:902:6a88:: with SMTP id n8mr34233623plk.70.1566399572654;
        Wed, 21 Aug 2019 07:59:32 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id n10sm21949644pgv.67.2019.08.21.07.59.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Aug 2019 07:59:32 -0700 (PDT)
Subject: [PATCH v6 1/6] mm: Adjust shuffle code to allow for future
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
Date: Wed, 21 Aug 2019 07:59:31 -0700
Message-ID: <20190821145931.20926.97386.stgit@localhost.localdomain>
In-Reply-To: <20190821145806.20926.22448.stgit@localhost.localdomain>
References: <20190821145806.20926.22448.stgit@localhost.localdomain>
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

While changing out the code I also opted to go for a bit more thread safe
approach to getting the boolean value. This way we can avoid possible cache
line bouncing of the batched entropy between CPUs.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/mmzone.h |   12 --------
 mm/page_alloc.c        |   70 +++++++++++++++++++++++++++---------------------
 mm/shuffle.c           |   40 ++++++++++++++++-----------
 mm/shuffle.h           |   12 ++++++++
 4 files changed, 75 insertions(+), 59 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 8b5f758942a2..62bfb5a280ce 100644
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
index 5b799e11fba3..3f8d5afe61fa 100644
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
index 3ce12481b1dc..345cb4347455 100644
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
@@ -183,25 +182,34 @@ void __meminit __shuffle_free_memory(pg_data_t *pgdat)
 		shuffle_zone(z);
 }
 
-void add_to_free_area_random(struct page *page, struct free_area *area,
-		int migratetype)
+struct batched_bit_entropy {
+	unsigned long entropy_bool;
+	int position;
+};
+
+static DEFINE_PER_CPU(struct batched_bit_entropy, batched_entropy_bool);
+
+bool __shuffle_pick_tail(void)
 {
-	static u64 rand;
-	static u8 rand_bits;
+	struct batched_bit_entropy *batch;
+	unsigned long entropy;
+	int position;
 
 	/*
-	 * The lack of locking is deliberate. If 2 threads race to
-	 * update the rand state it just adds to the entropy.
+	 * We shouldn't need to disable IRQs as the only caller is
+	 * __free_one_page and it should only be called with the zone lock
+	 * held and either from IRQ context or with local IRQs disabled.
 	 */
-	if (rand_bits == 0) {
-		rand_bits = 64;
-		rand = get_random_u64();
+	batch = raw_cpu_ptr(&batched_entropy_bool);
+	position = batch->position;
+
+	if (--position < 0) {
+		batch->entropy_bool = get_random_long();
+		position = BITS_PER_LONG - 1;
 	}
 
-	if (rand & 1)
-		add_to_free_area(page, area, migratetype);
-	else
-		add_to_free_area_tail(page, area, migratetype);
-	rand_bits--;
-	rand >>= 1;
+	batch->position = position;
+	entropy = batch->entropy_bool;
+
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


