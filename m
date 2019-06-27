Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 398AFC48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 11:54:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5F9A2086D
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 11:54:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hTcH+5QW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5F9A2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7394A6B0008; Thu, 27 Jun 2019 07:54:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6EA058E0003; Thu, 27 Jun 2019 07:54:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 564598E0002; Thu, 27 Jun 2019 07:54:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 188BF6B0008
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 07:54:33 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s22so1327146plp.5
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 04:54:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BuVEzWKbeZodaY1DtSQ/rLjfKBb5D8VfUouLYJEzuIE=;
        b=uFIxv0IqwMCO1OZ8r5Ex9z/2WLecq39xmJD7eczFS3FCePtS4V+zxL1nHmhN3acL1L
         Z8h65jN23hTtartprlR5tDch4yC50WsIQDr1zbERtOLhR31CelXR2xBVfpY3SCXPy7r3
         paiZ+peVqaS1yBK+8uEA4zJwctKJZFjsDbAlxIX3XKU2KNPiBuBip2LU83oeQvAJ5Ztm
         rfZSJv4QusOsKIdj81FLarHN8L/bPFpP5O4Xyu6pf6GnfrM3mYulLmMOUHj0tcAC9+X+
         czIaLhvPnMavAOVTcnPPMunyQUuCl7HWvb3UpX5qToBORyK6fTg0qWJ0repJKnWPnkAa
         QNtQ==
X-Gm-Message-State: APjAAAVQMMSnW2wnu8irYqyOFEbfwebsqYCqmq/QEhTtdAwIKaFrtFTS
	LZFsrPWBno6BXiobCBPFEkSRC/1Y7Fgxx+mxK9fb2VQHEpFjQQG+Po245Qm6au7nPfv8uudycOr
	osOnWVBC+Wcw3gvaCehO+kYyXXUlzylsjUPvrDQvOpJmYeztwIOG6ksQ5uTn37sw=
X-Received: by 2002:a17:902:d695:: with SMTP id v21mr3956376ply.342.1561636472731;
        Thu, 27 Jun 2019 04:54:32 -0700 (PDT)
X-Received: by 2002:a17:902:d695:: with SMTP id v21mr3956308ply.342.1561636471675;
        Thu, 27 Jun 2019 04:54:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561636471; cv=none;
        d=google.com; s=arc-20160816;
        b=TLZ+/jeGhao173XNI8TsuKiOTnQfnpvuU07PmHMnP+Keh949SebAo0me6sJ63fONNC
         BckiHiKJojMqjt7/zg8GOg731LMDudXpNCq4dB7E/4gfzTFX2kPiqNAohMkg6ddfjd6r
         OEPHBfDwoQjwHRXoyc3l9IoMOCHJfCs7PSI2wdT2xFgKGoD7dZ2EZPGLV+eHkDp3sEM/
         pk5DCC8co1KifDrqelscb5jqmOSShfN3U0xXlztHSzIQsvygZ3+iOqaJbk9k6qIKqyEa
         Aatk3yTnt1AQkOJEVcxFCzbHeu9vGUHlozUF8a9j/RVa9loogl2O4NyyjshLdrSWj5cf
         srQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=BuVEzWKbeZodaY1DtSQ/rLjfKBb5D8VfUouLYJEzuIE=;
        b=ojYpZP/QV8kT0vtWaWGXl4HHe671GvinGo8ZytIk0N+9OaUxHPzN7p6d2XJDjcj7IG
         NgJB3WsRXRtJC5WAin1Zji0GiU4f3q9gLEYgqyt37oY+yJGSQw9PRaDomFlk/3wgG/cD
         o/U6oeeIVjdPJdD4qJm+qi1r+nmmG09QaE1KcutwYWuMX9zHotxQeJN5EIoB2NYblh1m
         QzGEdRYPPC9Chvu6RBFqlPV7dbOKjEWEAD4cFSeA/59/BTRx9Nmd2AfbHVAcPebmeb4Q
         50CezXnC5pk4agVTMJQdxEgRCcnI/Fe6SIS358t4q9KQSClR7yefd/FHa1rNbBofokUE
         VJmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hTcH+5QW;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v75sor6082969pjb.26.2019.06.27.04.54.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 04:54:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hTcH+5QW;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=BuVEzWKbeZodaY1DtSQ/rLjfKBb5D8VfUouLYJEzuIE=;
        b=hTcH+5QWaidgZDsApBE1+6el+QVb/e7UZYRZUJqv8BCAg6tJqcy1Klv7J+bvCVKJ1v
         4eZJjq+1GHxqMNAHoycM4+4aa/RQrZuJ7bVWqIlGCB8jGEfUhjwozEGtd5mog+ZwBP8t
         pCqRrkYzyiFpdq/PaT8I7RqnSFapxOJb1gtGdHhWhndY4pfnYt7WEdLIkn9VeY7VOH0c
         fVzNg6SSSG0/TWiibN9Io1a4pKoaOtzRQbiSLd0XJFf4p5u9B/hT1VunUKQJOijI5DO3
         qnJTJ9o7KqmUlRBnSLVSgr92Pdasj+kssorHTS/qk37w+KifZoO86tBnCP/W/TOu95Rt
         B/Og==
X-Google-Smtp-Source: APXvYqxhan3s16KjBk3Mp/Tu8jm4OH897OBDSn9aszzMUXfDMo3p8QxfacVymd5q7l8bCkiLo9Om6w==
X-Received: by 2002:a17:90a:9bc5:: with SMTP id b5mr5614905pjw.109.1561636471073;
        Thu, 27 Jun 2019 04:54:31 -0700 (PDT)
Received: from bbox-1.seo.corp.google.com ([2401:fa00:d:0:d988:f0f2:984f:445b])
        by smtp.gmail.com with ESMTPSA id x14sm3241419pfq.158.2019.06.27.04.54.25
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 27 Jun 2019 04:54:29 -0700 (PDT)
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
Subject: [PATCH v3 3/5] mm: account nr_isolated_xxx in [isolate|putback]_lru_page
Date: Thu, 27 Jun 2019 20:54:03 +0900
Message-Id: <20190627115405.255259-4-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
In-Reply-To: <20190627115405.255259-1-minchan@kernel.org>
References: <20190627115405.255259-1-minchan@kernel.org>
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
index 7dde2e3a1963..aec3a2b7e61b 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1473,13 +1473,8 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
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
 	}
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 0f7419938008..7da34e198ec5 100644
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
index 7e08cbf3ba49..3586e8226e4e 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1795,9 +1795,6 @@ static int __soft_offline_page(struct page *page, int flags)
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
index dfab21dc33dc..68577c677b46 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1384,10 +1384,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
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
index 64562809bf3b..03081f3404ca 100644
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
index 572b4bc85d76..5583324c01e7 100644
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
@@ -1181,10 +1179,17 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
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
@@ -1210,15 +1215,6 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
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
@@ -1572,9 +1568,6 @@ static int add_page_for_migration(struct mm_struct *mm, unsigned long addr,
 
 		err = 0;
 		list_add_tail(&head->lru, pagelist);
-		mod_node_page_state(page_pgdat(head),
-			NR_ISOLATED_ANON + page_is_file_cache(head),
-			hpage_nr_pages(head));
 	}
 out_putpage:
 	/*
@@ -1890,8 +1883,6 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
 
 static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 {
-	int page_lru;
-
 	VM_BUG_ON_PAGE(compound_order(page) && !PageTransHuge(page), page);
 
 	/* Avoid migrating to a node that is nearly full */
@@ -1913,10 +1904,6 @@ static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 		return 0;
 	}
 
-	page_lru = page_is_file_cache(page);
-	mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON + page_lru,
-				hpage_nr_pages(page));
-
 	/*
 	 * Isolating the page has taken another reference, so the
 	 * caller's reference can be safely dropped without the page
@@ -1971,8 +1958,6 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
 	if (nr_remaining) {
 		if (!list_empty(&migratepages)) {
 			list_del(&page->lru);
-			dec_node_page_state(page, NR_ISOLATED_ANON +
-					page_is_file_cache(page));
 			putback_lru_page(page);
 		}
 		isolated = 0;
@@ -2002,7 +1987,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	pg_data_t *pgdat = NODE_DATA(node);
 	int isolated = 0;
 	struct page *new_page = NULL;
-	int page_lru = page_is_file_cache(page);
 	unsigned long start = address & HPAGE_PMD_MASK;
 
 	new_page = alloc_pages_node(node,
@@ -2048,8 +2032,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 		/* Retake the callers reference and putback on LRU */
 		get_page(page);
 		putback_lru_page(page);
-		mod_node_page_state(page_pgdat(page),
-			 NR_ISOLATED_ANON + page_lru, -HPAGE_PMD_NR);
 
 		goto out_unlock;
 	}
@@ -2099,9 +2081,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	count_vm_events(PGMIGRATE_SUCCESS, HPAGE_PMD_NR);
 	count_vm_numa_events(NUMA_PAGE_MIGRATE, HPAGE_PMD_NR);
 
-	mod_node_page_state(page_pgdat(page),
-			NR_ISOLATED_ANON + page_lru,
-			-HPAGE_PMD_NR);
 	return isolated;
 
 out_fail:
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 49e9ee4d771d..223ce5da08f0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1014,6 +1014,9 @@ int remove_mapping(struct address_space *mapping, struct page *page)
 void putback_lru_page(struct page *page)
 {
 	lru_cache_add(page);
+	mod_node_page_state(page_pgdat(page),
+				NR_ISOLATED_ANON + page_is_file_cache(page),
+				-hpage_nr_pages(page));
 	put_page(page);		/* drop ref from isolate */
 }
 
@@ -1479,6 +1482,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 */
 		nr_reclaimed += nr_pages;
 
+		mod_node_page_state(pgdat, NR_ISOLATED_ANON +
+						page_is_file_cache(page),
+						-nr_pages);
 		/*
 		 * Is there need to periodically free_page_list? It would
 		 * appear not as the counts should be low
@@ -1554,7 +1560,6 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 	ret = shrink_page_list(&clean_pages, zone->zone_pgdat, &sc,
 			TTU_IGNORE_ACCESS, &dummy_stat, true);
 	list_splice(&clean_pages, page_list);
-	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, -ret);
 	return ret;
 }
 
@@ -1630,6 +1635,9 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
 		 */
 		ClearPageLRU(page);
 		ret = 0;
+		__mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON +
+						page_is_file_cache(page),
+						hpage_nr_pages(page));
 	}
 
 	return ret;
@@ -1761,6 +1769,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan,
 				    total_scan, skipped, nr_taken, mode, lru);
 	update_lru_sizes(lruvec, lru, nr_zone_taken);
+
 	return nr_taken;
 }
 
@@ -1809,6 +1818,9 @@ int isolate_lru_page(struct page *page)
 			ClearPageLRU(page);
 			del_page_from_lru_list(page, lruvec, lru);
 			ret = 0;
+			mod_node_page_state(pgdat, NR_ISOLATED_ANON +
+						page_is_file_cache(page),
+						hpage_nr_pages(page));
 		}
 		spin_unlock_irq(&pgdat->lru_lock);
 	}
@@ -1900,6 +1912,9 @@ static unsigned noinline_for_stack move_pages_to_lru(struct lruvec *lruvec,
 		update_lru_size(lruvec, lru, page_zonenum(page), nr_pages);
 		list_move(&page->lru, &lruvec->lists[lru]);
 
+		__mod_node_page_state(pgdat, NR_ISOLATED_ANON +
+						page_is_file_cache(page),
+						-hpage_nr_pages(page));
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
 			__ClearPageActive(page);
@@ -1977,7 +1992,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
 				     &nr_scanned, sc, lru);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	item = current_is_kswapd() ? PGSCAN_KSWAPD : PGSCAN_DIRECT;
@@ -2003,8 +2017,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	move_pages_to_lru(lruvec, &page_list);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
-
 	spin_unlock_irq(&pgdat->lru_lock);
 
 	mem_cgroup_uncharge_list(&page_list);
@@ -2063,7 +2075,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold,
 				     &nr_scanned, sc, lru);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	__count_vm_events(PGREFILL, nr_scanned);
@@ -2132,7 +2143,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	__count_vm_events(PGDEACTIVATE, nr_deactivate);
 	__count_memcg_events(lruvec_memcg(lruvec), PGDEACTIVATE, nr_deactivate);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&pgdat->lru_lock);
 
 	mem_cgroup_uncharge_list(&l_active);
-- 
2.22.0.410.gd8fdbe21b5-goog

