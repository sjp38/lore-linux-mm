Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D09A3C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 22:29:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 732B6206B8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 22:29:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="C34Jr62z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 732B6206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1231B6B0003; Thu,  1 Aug 2019 18:29:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D32F6B0006; Thu,  1 Aug 2019 18:29:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2B666B0008; Thu,  1 Aug 2019 18:29:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id C78B46B0003
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 18:29:22 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id b4so40031451otf.15
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 15:29:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=qiq6gR71/Np4kj7TR/VhXXY9IMafNu+VvX5LVu17sf0=;
        b=JSKZAW/1N6Q6du45ll5KMVLKeJEo0gEUTOFCp41WaB8PjqxvfiRbRYIPtpifh7KwGG
         fNAUkG/HES/v0cbPSRvK9ScxPWlRuO0l2xdvPCLE5BW3Iz2SfXv3nh5MC19VB62ljzJP
         bqGTy2NWa99PBRTZjIn6GGWuLnSjOkzg18Ys4t/pCwLwXaAytLcZNNGQB/s4O4Jg8u5B
         hbJT7K2LTYnYGP30M7FSOeCBl658Nb7Fu/VQ1gTFMx1Q74tZMQGg1BMFecXN4n/HN1h7
         jiuxkfyLkYAWW47lSJbHzqC3jfpQmWKsEaX1TKa5hKwwRs1ChZ/EJAvzU8seGQWrro0D
         G5cQ==
X-Gm-Message-State: APjAAAUKi6qT4oOqmguyKWrtpsV8nOThx7wYZ5a+oQ4Zheoz0l8PGZYH
	2v8Ku8rIfngvLzgjVUxwZB9S+drH3IpRQ1cHPx1nMBp+5lW3nWEK+ozspqPW7iIBqGihqbQ9Tbx
	UPAjHQUqgJidtDw2x3+i/tBTXkzO2IFJhGfPH1H82P5lnvfLJpJMhXsHRhb0r0iYSAA==
X-Received: by 2002:aca:3a55:: with SMTP id h82mr766267oia.49.1564698562486;
        Thu, 01 Aug 2019 15:29:22 -0700 (PDT)
X-Received: by 2002:aca:3a55:: with SMTP id h82mr766245oia.49.1564698561466;
        Thu, 01 Aug 2019 15:29:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564698561; cv=none;
        d=google.com; s=arc-20160816;
        b=NxE4dys21LIHtxYRW3iAMvv0kVbjU9iT129l2tnJAkPtaW8CZ7k5J5K+bhsL5JhoYb
         D+lroOP2BRemTMVpQvasoS7IBJgbKLSwN2LtkBfB4pmQdICHEy1aiPbVln/sWYkLN7Z+
         A9YiTq/xxFLXoYNXWlz8+Gi2Y1dNqCmg9KBsNu5brIONhImE0zsCzCzRvhOk9GFvhDSu
         9yc+1Ap7GpTr21CtwCnBI4oVkDypT2T/yzjWAkBW0J6O/INkY49HMXn8f9xKAOZwH29w
         s8vqOkJJFhY0jKZEJ0s5OgKqxj2DmdM3kIUb8N/irUlTpPZOzjML6Uni7rFXQCFejbbG
         hCyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=qiq6gR71/Np4kj7TR/VhXXY9IMafNu+VvX5LVu17sf0=;
        b=o4gs16ayKjaXpWhZcCHYQg3ElG4UneeictK3XDDa6/o0pHp7LEsI16XxgA/B+il08J
         /x+jOw0j9L+W1PrGrWj0IsuRBU1pRw/YBpmHnoyhkua5mpwu1hlHltjJq7wORRLNrdEF
         vgB4u6EyC8qlHNqIBsc//dDKuCQmya+0ofRQlCNKHCFctUul7050NlGC3ENKfQsBnXR2
         PLurST5rzQeCrXwNTZIGkdxtQvEMVXuNM7ZNV6t5lP0HClXuKn3YFe/Vr1cR6m9LYKw5
         evrC0T2CoOtLdssoJbxQslWbMcnUTCm8lH7rt2FppCXu4iac9VtAPqZI0j2gynKeRNOO
         9Fbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=C34Jr62z;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 92sor37705566ota.30.2019.08.01.15.29.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 15:29:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=C34Jr62z;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=qiq6gR71/Np4kj7TR/VhXXY9IMafNu+VvX5LVu17sf0=;
        b=C34Jr62zLOYAiVtJEvShJTY2kq2zXYedFyQaHgTZuzPDmNRWAeac3UsKAjSgLJmSz6
         vv8kV/zhtNghKj8p5s0+emQhClcoNE/K8ERpifeGolniAy9doAr9lXzvftRAnd2x+Nyl
         3OyFFVdNrA+fRNI7lgSou/I7tjeHtvlx56FL83jP5da2PG9ehzz0UfljkJUFQxWM845d
         QxLvhv6zTLqrwplMKmC64Fd3XrG4lXh+WJMMRectn2bFny8dk/ZCI06isL3qU1wbEahM
         cHYukakNEogSOx0PCMtUalgAVJFaKBSdd1JKpZ7VDo9CrleqHtk/ekW2FsNX5QM0zr9k
         dIJQ==
X-Google-Smtp-Source: APXvYqy0KyNGtP3yK4Et1UQf7VLvShSVVcTiZ13hP+qWWhjr0UfqR1QA5O3PJR1WYOl1STAGfPm/tA==
X-Received: by 2002:a9d:65cb:: with SMTP id z11mr60468452oth.325.1564698561089;
        Thu, 01 Aug 2019 15:29:21 -0700 (PDT)
Received: from localhost.localdomain (50-39-177-61.bvtn.or.frontiernet.net. [50.39.177.61])
        by smtp.gmail.com with ESMTPSA id 9sm22844406oij.25.2019.08.01.15.29.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 15:29:20 -0700 (PDT)
Subject: [PATCH v3 1/6] mm: Adjust shuffle code to allow for future
 coalescing
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Date: Thu, 01 Aug 2019 15:27:07 -0700
Message-ID: <20190801222707.22190.37136.stgit@localhost.localdomain>
In-Reply-To: <20190801222158.22190.96964.stgit@localhost.localdomain>
References: <20190801222158.22190.96964.stgit@localhost.localdomain>
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
index d77d717c620c..738e9c758135 100644
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
index d3bb601c461b..dfed182f200d 100644
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

