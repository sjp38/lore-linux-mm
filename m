Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0892CC74A36
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 01:25:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A970520872
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 01:25:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IfzouMzA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A970520872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53B6D8E00A4; Wed, 10 Jul 2019 21:25:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4ECE48E0032; Wed, 10 Jul 2019 21:25:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DBF68E00A4; Wed, 10 Jul 2019 21:25:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 013208E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 21:25:58 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id b18so2573810pgg.8
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 18:25:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=g3sPXxwryfyIYGvf6SkhaUfkJre0gRyCx/35axsK1aw=;
        b=SekIJefqqAVx4NR5FWqQ/EyVP3GhZ/er+gV5cA9ghcDtm7YWu/aEYj+OilNL5vwMiX
         5Dkt241Lj9uQN3lpnqdgp6BY/xIm/07ecLGuk+1fE0Gh85OFnckT8Ovqq8ML7NJSuinJ
         Jw0m7ALkKOYR2n2yLjKJ/Is/BF1sjBZCDjyDBLU+65/M5i1p6hO04W+dItT5fGo5M+Uw
         kzO0wmS9PbOMhCmI9OCvAxjPsr4a7Cnc9d9iNvKqn9KoopoJUINet+yonoyhoepRFnZt
         0O6Ggm5xnN2EEpp9OgQ+PUtsuEustMjKvwrbhts2pM+mBV8ZRKQeiIla8xiRMmba9akN
         uJFg==
X-Gm-Message-State: APjAAAW+66myV7cQSYq6cnWWenX08A7j85arJcGqeAwUnPKLxv7Ib46C
	rYHIH9OD8Hj4LU9iTb/rAZPayjv3JY+lqnU4Ga6P5id4m/ziUct07JquWHuRzcDYRh03QJSAlBR
	cXXupnYDKkmF4eBPBdGfQhnsm+GXpGZLDhhtau684Pp/YbhJBmzYyzyHZuD2Hlyc=
X-Received: by 2002:a63:b10f:: with SMTP id r15mr1371075pgf.230.1562808357479;
        Wed, 10 Jul 2019 18:25:57 -0700 (PDT)
X-Received: by 2002:a63:b10f:: with SMTP id r15mr1371012pgf.230.1562808356383;
        Wed, 10 Jul 2019 18:25:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562808356; cv=none;
        d=google.com; s=arc-20160816;
        b=UWc6B0hqtLxRgsg8j9FSISOEcZlqkfZywuph6QTP3uUJZdKRkIh8cjn6R1IUF9aqKY
         C+VmY3xJCYS22n+s3ou4nm/yx4/7NqEsqOwvgVVYowFvOge+cF31LsT6VPnzt6Em54Vy
         la7E9QNxxzCC0DzJEXwg85yANyXXrAEbUHf9jowJN1X9NxTKHKQ+zNVqv3GNpdS3UIpL
         kxUGHxfAvRJa5NDZr+/7rp2QLtrvwXU8EoyYYP9yZeAt520TJ5HlJ7/ao2IrT6xSJiPA
         MukjoceXOW0vZQhMeQwF8NKSoLpMonV/9tS145SC8lEDwQf+zOeUVgIdlMF20NxLEXGF
         vAdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=g3sPXxwryfyIYGvf6SkhaUfkJre0gRyCx/35axsK1aw=;
        b=QScqLPpMQ0acSu+xwyo+I0pANMakKACsfsGoIU5M+7DfBKmHQL1nF5zixqpY+WOOPM
         z3bWqUKOXFHfjydrt006RiteEsINDliahwF9TzPew9jQ2wZ6PBZI5intzw1gXXa93sye
         F3g9VDYoSrIrMy3OU9CcMqw1KMdjjL/eQk7U07zxlHWdtE4sUrgeSKV2PsF5C1aBvopg
         20APUdauL3h9Pw4PagcyWy3LPY+iOu7dyCaqQm8yyUmmy53+25asXQANEsS1JnycF94g
         ch3udHTxQFL8jHrXtWhusl0OwFLLiQy4/XCb1aZpkJYN8Q3coaApsNZiLDX9fpV1ceFo
         STiw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IfzouMzA;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b64sor5197617pjc.24.2019.07.10.18.25.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 18:25:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IfzouMzA;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=g3sPXxwryfyIYGvf6SkhaUfkJre0gRyCx/35axsK1aw=;
        b=IfzouMzAhm1Bmv3cV0b5Uq3+6uTtqI8UlcQ0D+i/m/KoGY5gRYPiFONouv3q6F6VJw
         e95Y5Q2oM7ngJqIupI0m3aYBZRI7ZZg8UzDFHceGUKqRq7jS0Scji1OtCnmG3bfBzc7v
         AabQuJI+4c4DbowNuYo7UlmIdkefwQjycubgMPchpkbU1YADNsz3fex3KI0Fp6ZhLoJE
         w4dxAcdrA5WQqhO9C7LEjeTcKsawIBBjGUvWW7T6ScRemFAlziwvuo2c9r2RlvxdOAwE
         xce5UQ4oUSc2dIG3LL+gg6AqJmty7fKH0qYyHBKer1GHBKCjFS9VNXYkPv9V7MGNdso6
         rVsw==
X-Google-Smtp-Source: APXvYqznXaO571WdAm9exTfgVHNOIPd4HtaYloqp/pMN0riHnBJghIr+LQKqamZeufoNitewUwHvvg==
X-Received: by 2002:a17:90a:ad93:: with SMTP id s19mr1600923pjq.36.1562808355903;
        Wed, 10 Jul 2019 18:25:55 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id b37sm10031974pjc.15.2019.07.10.18.25.50
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 10 Jul 2019 18:25:54 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com,
	hdanton@sina.com,
	lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 3/4] mm: account nr_isolated_xxx in [isolate|putback]_lru_page
Date: Thu, 11 Jul 2019 10:25:27 +0900
Message-Id: <20190711012528.176050-4-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
In-Reply-To: <20190711012528.176050-1-minchan@kernel.org>
References: <20190711012528.176050-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The isolate counting is pecpu counter so it would be not huge gain
to work them by batch. Rather than complicating to make them batch,
let's make it more stright-foward via adding the counting logic
into [isolate|putback]_lru_page API.

* v1
 * fix accounting bug - Hillf

Link: http://lkml.kernel.org/r/20190531165927.GA20067@cmpxchg.org
Acked-by: Michal Hocko <mhocko@suse.com>
Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/compaction.c     |  2 --
 mm/gup.c            |  7 +------
 mm/khugepaged.c     |  3 ---
 mm/memory-failure.c |  3 ---
 mm/memory_hotplug.c |  4 ----
 mm/mempolicy.c      |  6 +-----
 mm/migrate.c        | 37 ++++++++-----------------------------
 mm/vmscan.c         | 22 ++++++++++++++++------
 8 files changed, 26 insertions(+), 58 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9e1b9acb116b..c6591682deda 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -982,8 +982,6 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/* Successfully isolated */
 		del_page_from_lru_list(page, lruvec, page_lru(page));
-		inc_node_page_state(page,
-				NR_ISOLATED_ANON + page_is_file_cache(page));
 
 isolate_success:
 		list_add(&page->lru, &cc->migratepages);
diff --git a/mm/gup.c b/mm/gup.c
index 98f13ab37bac..11d0634ce613 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1475,13 +1475,8 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 					drain_allow = false;
 				}
 
-				if (!isolate_lru_page(head)) {
+				if (!isolate_lru_page(head))
 					list_add_tail(&head->lru, &cma_page_list);
-					mod_node_page_state(page_pgdat(head),
-							    NR_ISOLATED_ANON +
-							    page_is_file_cache(head),
-							    hpage_nr_pages(head));
-				}
 			}
 		}
 
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index eaaa21b23215..a8b517d6df4a 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -503,7 +503,6 @@ void __khugepaged_exit(struct mm_struct *mm)
 
 static void release_pte_page(struct page *page)
 {
-	dec_node_page_state(page, NR_ISOLATED_ANON + page_is_file_cache(page));
 	unlock_page(page);
 	putback_lru_page(page);
 }
@@ -602,8 +601,6 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 			result = SCAN_DEL_PAGE_LRU;
 			goto out;
 		}
-		inc_node_page_state(page,
-				NR_ISOLATED_ANON + page_is_file_cache(page));
 		VM_BUG_ON_PAGE(!PageLocked(page), page);
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 7ef849da8278..9900bb95d774 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1791,9 +1791,6 @@ static int __soft_offline_page(struct page *page, int flags)
 		 * so use !__PageMovable instead for LRU page's mapping
 		 * cannot have PAGE_MAPPING_MOVABLE.
 		 */
-		if (!__PageMovable(page))
-			inc_node_page_state(page, NR_ISOLATED_ANON +
-						page_is_file_cache(page));
 		list_add(&page->lru, &pagelist);
 		ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
 					MIGRATE_SYNC, MR_MEMORY_FAILURE);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b9ba5b85f9f7..15bad2043b41 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1383,10 +1383,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			ret = isolate_movable_page(page, ISOLATE_UNEVICTABLE);
 		if (!ret) { /* Success */
 			list_add_tail(&page->lru, &source);
-			if (!__PageMovable(page))
-				inc_node_page_state(page, NR_ISOLATED_ANON +
-						    page_is_file_cache(page));
-
 		} else {
 			pr_warn("failed to isolate pfn %lx\n", pfn);
 			dump_page(page, "isolation failed");
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 4acc2d14bc77..a5685eee6d1d 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -994,12 +994,8 @@ static int migrate_page_add(struct page *page, struct list_head *pagelist,
 	 * Avoid migrating a page that is shared with others.
 	 */
 	if ((flags & MPOL_MF_MOVE_ALL) || page_mapcount(head) == 1) {
-		if (!isolate_lru_page(head)) {
+		if (!isolate_lru_page(head))
 			list_add_tail(&head->lru, pagelist);
-			mod_node_page_state(page_pgdat(head),
-				NR_ISOLATED_ANON + page_is_file_cache(head),
-				hpage_nr_pages(head));
-		}
 	}
 
 	return 0;
diff --git a/mm/migrate.c b/mm/migrate.c
index 8992741f10aa..f54f449a99f5 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -190,8 +190,6 @@ void putback_movable_pages(struct list_head *l)
 			unlock_page(page);
 			put_page(page);
 		} else {
-			mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON +
-					page_is_file_cache(page), -hpage_nr_pages(page));
 			putback_lru_page(page);
 		}
 	}
@@ -1175,10 +1173,17 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		return -ENOMEM;
 
 	if (page_count(page) == 1) {
+		bool is_lru = !__PageMovable(page);
+
 		/* page was freed from under us. So we are done. */
 		ClearPageActive(page);
 		ClearPageUnevictable(page);
-		if (unlikely(__PageMovable(page))) {
+		if (likely(is_lru))
+			mod_node_page_state(page_pgdat(page),
+						NR_ISOLATED_ANON +
+						page_is_file_cache(page),
+						-hpage_nr_pages(page));
+		else {
 			lock_page(page);
 			if (!PageMovable(page))
 				__ClearPageIsolated(page);
@@ -1204,15 +1209,6 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		 * restored.
 		 */
 		list_del(&page->lru);
-
-		/*
-		 * Compaction can migrate also non-LRU pages which are
-		 * not accounted to NR_ISOLATED_*. They can be recognized
-		 * as __PageMovable
-		 */
-		if (likely(!__PageMovable(page)))
-			mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON +
-					page_is_file_cache(page), -hpage_nr_pages(page));
 	}
 
 	/*
@@ -1566,9 +1562,6 @@ static int add_page_for_migration(struct mm_struct *mm, unsigned long addr,
 
 		err = 0;
 		list_add_tail(&head->lru, pagelist);
-		mod_node_page_state(page_pgdat(head),
-			NR_ISOLATED_ANON + page_is_file_cache(head),
-			hpage_nr_pages(head));
 	}
 out_putpage:
 	/*
@@ -1884,8 +1877,6 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
 
 static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 {
-	int page_lru;
-
 	VM_BUG_ON_PAGE(compound_order(page) && !PageTransHuge(page), page);
 
 	/* Avoid migrating to a node that is nearly full */
@@ -1907,10 +1898,6 @@ static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 		return 0;
 	}
 
-	page_lru = page_is_file_cache(page);
-	mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON + page_lru,
-				hpage_nr_pages(page));
-
 	/*
 	 * Isolating the page has taken another reference, so the
 	 * caller's reference can be safely dropped without the page
@@ -1965,8 +1952,6 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
 	if (nr_remaining) {
 		if (!list_empty(&migratepages)) {
 			list_del(&page->lru);
-			dec_node_page_state(page, NR_ISOLATED_ANON +
-					page_is_file_cache(page));
 			putback_lru_page(page);
 		}
 		isolated = 0;
@@ -1996,7 +1981,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	pg_data_t *pgdat = NODE_DATA(node);
 	int isolated = 0;
 	struct page *new_page = NULL;
-	int page_lru = page_is_file_cache(page);
 	unsigned long start = address & HPAGE_PMD_MASK;
 
 	new_page = alloc_pages_node(node,
@@ -2042,8 +2026,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 		/* Retake the callers reference and putback on LRU */
 		get_page(page);
 		putback_lru_page(page);
-		mod_node_page_state(page_pgdat(page),
-			 NR_ISOLATED_ANON + page_lru, -HPAGE_PMD_NR);
 
 		goto out_unlock;
 	}
@@ -2093,9 +2075,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	count_vm_events(PGMIGRATE_SUCCESS, HPAGE_PMD_NR);
 	count_vm_numa_events(NUMA_PAGE_MIGRATE, HPAGE_PMD_NR);
 
-	mod_node_page_state(page_pgdat(page),
-			NR_ISOLATED_ANON + page_lru,
-			-HPAGE_PMD_NR);
 	return isolated;
 
 out_fail:
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b4fa04d10ba6..ca192b792d4f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1016,6 +1016,9 @@ int remove_mapping(struct address_space *mapping, struct page *page)
 void putback_lru_page(struct page *page)
 {
 	lru_cache_add(page);
+	mod_node_page_state(page_pgdat(page),
+				NR_ISOLATED_ANON + page_is_file_cache(page),
+				-hpage_nr_pages(page));
 	put_page(page);		/* drop ref from isolate */
 }
 
@@ -1481,6 +1484,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 */
 		nr_reclaimed += nr_pages;
 
+		mod_node_page_state(pgdat, NR_ISOLATED_ANON +
+						page_is_file_cache(page),
+						-nr_pages);
 		/*
 		 * Is there need to periodically free_page_list? It would
 		 * appear not as the counts should be low
@@ -1556,7 +1562,6 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 	ret = shrink_page_list(&clean_pages, zone->zone_pgdat, &sc,
 			TTU_IGNORE_ACCESS, &dummy_stat, true);
 	list_splice(&clean_pages, page_list);
-	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, -ret);
 	return ret;
 }
 
@@ -1632,6 +1637,9 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
 		 */
 		ClearPageLRU(page);
 		ret = 0;
+		__mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON +
+						page_is_file_cache(page),
+						hpage_nr_pages(page));
 	}
 
 	return ret;
@@ -1763,6 +1771,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan,
 				    total_scan, skipped, nr_taken, mode, lru);
 	update_lru_sizes(lruvec, lru, nr_zone_taken);
+
 	return nr_taken;
 }
 
@@ -1811,6 +1820,9 @@ int isolate_lru_page(struct page *page)
 			ClearPageLRU(page);
 			del_page_from_lru_list(page, lruvec, lru);
 			ret = 0;
+			mod_node_page_state(pgdat, NR_ISOLATED_ANON +
+						page_is_file_cache(page),
+						hpage_nr_pages(page));
 		}
 		spin_unlock_irq(&pgdat->lru_lock);
 	}
@@ -1902,6 +1914,9 @@ static unsigned noinline_for_stack move_pages_to_lru(struct lruvec *lruvec,
 		update_lru_size(lruvec, lru, page_zonenum(page), nr_pages);
 		list_move(&page->lru, &lruvec->lists[lru]);
 
+		__mod_node_page_state(pgdat, NR_ISOLATED_ANON +
+						page_is_file_cache(page),
+						-hpage_nr_pages(page));
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
 			__ClearPageActive(page);
@@ -1979,7 +1994,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
 				     &nr_scanned, sc, lru);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	item = current_is_kswapd() ? PGSCAN_KSWAPD : PGSCAN_DIRECT;
@@ -2005,8 +2019,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	move_pages_to_lru(lruvec, &page_list);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
-
 	spin_unlock_irq(&pgdat->lru_lock);
 
 	mem_cgroup_uncharge_list(&page_list);
@@ -2065,7 +2077,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold,
 				     &nr_scanned, sc, lru);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	__count_vm_events(PGREFILL, nr_scanned);
@@ -2134,7 +2145,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	__count_vm_events(PGDEACTIVATE, nr_deactivate);
 	__count_memcg_events(lruvec_memcg(lruvec), PGDEACTIVATE, nr_deactivate);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&pgdat->lru_lock);
 
 	mem_cgroup_uncharge_list(&l_active);
-- 
2.22.0.410.gd8fdbe21b5-goog

