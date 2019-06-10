Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C5DFC28D16
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 11:13:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25A78206C3
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 11:13:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EI6RzxhR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25A78206C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B28986B026D; Mon, 10 Jun 2019 07:13:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB2ED6B026E; Mon, 10 Jun 2019 07:13:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92C9D6B026F; Mon, 10 Jun 2019 07:13:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 58DE46B026D
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 07:13:23 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y9so5560126plp.12
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 04:13:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VFKFNRtcM5OzHpTShHRkAEmoY5RrXhVcLzC7ftmVEqk=;
        b=sfntlC2iTGNYI8LtawNdoL+7KwUh2MWJoZP08PJDN2XC07z+pmlExdcJ9phhzPiEFn
         8q/4GWLhs0GX8Kx3XDYcvCAf+E2RmWCY4MMIcODWeHKEgIzik+JkKgSIvSGa/GQr5Gwm
         r65TEntiMqVOJfXmehbQJl3m6jMMKh/Ufh7jjzRFe17rfspjQxLepV1joOXE8AdWOt2w
         s9L9n1O7ndrbN7ilfyrW4lcrsonIMIfxtNivyc0cg/k4c3DgL7hU+XTn1EzEk4olOsvR
         94LObNcJprp9qF7ZZpfef1kzspjBq102N/pi2f52EjE2GWb9VxDHmTHSosGd3UzZu27R
         2drA==
X-Gm-Message-State: APjAAAXod5O4Wq2utlignqcLz6ewhPZP8w8pORGcO0yPxTNFrMcyWwpy
	OTJTQZG4KyoRAPS9lMSQivkJ+eCimeVIt7cc2iTquMOdQmtHjRJI0yA+txD+XpK/lQKFLtWSZS4
	bw+fVJfyVYyWAuNrFCmZyBNyWke7Vaaqum5Wmte+0AOr2ci8lhfpWWHplosv2apI=
X-Received: by 2002:a17:90a:a397:: with SMTP id x23mr21256203pjp.118.1560165202984;
        Mon, 10 Jun 2019 04:13:22 -0700 (PDT)
X-Received: by 2002:a17:90a:a397:: with SMTP id x23mr21256106pjp.118.1560165201713;
        Mon, 10 Jun 2019 04:13:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560165201; cv=none;
        d=google.com; s=arc-20160816;
        b=bybCGHKnHZIRGOoFwPcZA7RrpoDyjQL5O+fltlLOVQc8ZwZAyVmm13FP+LU01D3A6i
         3zTpc1ncETMFQ9ktTCZjM2YZFpokud8bD18vgIjoStF7dlQWgfzNjdr6+s56pFlta9mD
         jAbjrSk8zawTELDzbFB2AiWVeP7JXjodrU36ElbSiBmqpoyaMCYarXgHmhA4+58nkY8V
         d+r1BQngCZu0g+2TcD2giyc03/Ll+FK/DTa+LZhjpBUXJ3udFXKlNOX28RDdVKsdgoRd
         mWkRh8vycx8jlV6jjUOLRCNnNFXbJKGbERB9EZ7LlDd30/+ql0KF7qD7c/fJmgTm5ZKg
         Fe4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=VFKFNRtcM5OzHpTShHRkAEmoY5RrXhVcLzC7ftmVEqk=;
        b=vRv4N5Zihr1bBqbMP4ODMpwHZxCVvcvLcPks363oyoAeYUkPM1SovMU+9g1dTQlWxV
         2CD9Su9aqn/DZV+KkAGLtOB6a2LPcwoEaV3lYyZ1kECbxMhEGkiK1yohzz2Y1IQlKrv8
         AY3sQyFRowV4fns6m8M2contrv969YmP8P676aBWa/n4TC4rwLJgDKue1Gieq16ngjD/
         OQ2tWQmSYvxotUhVt4Qy7r1I5McmLarYLeaI3QZCJAJZVFMMsLmkIYnwjbvv7lMWJmU5
         qRukjxtXpRHlJrKDYJq2CJl5ohjueV8/5H0xeaLMo6+aze9WXD9TKqkdD6phyhgQXGgL
         A+3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EI6RzxhR;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q17sor1686217pff.71.2019.06.10.04.13.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Jun 2019 04:13:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EI6RzxhR;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=VFKFNRtcM5OzHpTShHRkAEmoY5RrXhVcLzC7ftmVEqk=;
        b=EI6RzxhRDjHPHn9Vdzmm9+DgK6lW/qfPybb0N3jbnxnKjfl2UkO6C0/CF7Onb6QbbG
         sPMaIT9I6FRBXAdUGVDxEBXrx9LRqMitpcE9Rzp5v4Dq3aBe2e+wJYrx8tw2xhIH3lYc
         SeRsvQw8qtRH8UaI15yD0sHpGfqGPOidtzGyLrm/AT2Fz0qiVlxBdoVz+vayPDmxqA3O
         ZAcwmC3PRQwz9LGXrvgphzPPcjkQioc/xsi+X30c8MIQpDYUsVQp2/GCzI6smnLhZk9s
         uQYnsZwUp62B+o0eYsRAthmqnc/gqQrtkMA/BSA+60c2LRiPuBaee9J2kfRO3/DDnuaf
         3Mqw==
X-Google-Smtp-Source: APXvYqxqXUdffPMelN2Ct953o2KwbeGvuUDzve1AuLhaglMZdPW1Us8IlwYZJMvPNIVqfquLo+piPA==
X-Received: by 2002:aa7:8555:: with SMTP id y21mr17189332pfn.104.1560165201273;
        Mon, 10 Jun 2019 04:13:21 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id h14sm9224633pgj.8.2019.06.10.04.13.15
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 04:13:20 -0700 (PDT)
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
	Brian Geffon <bgeffon@google.com>,
	jannh@google.com,
	oleg@redhat.com,
	christian@brauner.io,
	oleksandr@redhat.com,
	hdanton@sina.com,
	lizeb@google.com,
	Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 3/5] mm: account nr_isolated_xxx in [isolate|putback]_lru_page
Date: Mon, 10 Jun 2019 20:12:50 +0900
Message-Id: <20190610111252.239156-4-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.rc2.383.gf4fbbf30c2-goog
In-Reply-To: <20190610111252.239156-1-minchan@kernel.org>
References: <20190610111252.239156-1-minchan@kernel.org>
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
index 63ac50e48072..2d9a9bc358c7 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1360,13 +1360,8 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
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
index a335f7c1fac4..3359df994fb4 100644
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
index b9cc36a284f9..430946cf9c8a 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1796,9 +1796,6 @@ static int __soft_offline_page(struct page *page, int flags)
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
index a88c5f334e5a..a41bea24d0c9 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1390,10 +1390,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
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
index fdcb73536319..89bb25fe7553 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -948,12 +948,8 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
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
 }
 
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
index 0973a46a0472..56df55e8afcd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -999,6 +999,9 @@ int remove_mapping(struct address_space *mapping, struct page *page)
 void putback_lru_page(struct page *page)
 {
 	lru_cache_add(page);
+	mod_node_page_state(page_pgdat(page),
+				NR_ISOLATED_ANON + page_is_file_cache(page),
+				-hpage_nr_pages(page));
 	put_page(page);		/* drop ref from isolate */
 }
 
@@ -1464,6 +1467,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 */
 		nr_reclaimed += nr_pages;
 
+		mod_node_page_state(pgdat, NR_ISOLATED_ANON +
+						page_is_file_cache(page),
+						-nr_pages);
 		/*
 		 * Is there need to periodically free_page_list? It would
 		 * appear not as the counts should be low
@@ -1539,7 +1545,6 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 	ret = shrink_page_list(&clean_pages, zone->zone_pgdat, &sc,
 			TTU_IGNORE_ACCESS, &dummy_stat, true);
 	list_splice(&clean_pages, page_list);
-	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, -ret);
 	return ret;
 }
 
@@ -1615,6 +1620,9 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
 		 */
 		ClearPageLRU(page);
 		ret = 0;
+		__mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON +
+						page_is_file_cache(page),
+						hpage_nr_pages(page));
 	}
 
 	return ret;
@@ -1746,6 +1754,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan,
 				    total_scan, skipped, nr_taken, mode, lru);
 	update_lru_sizes(lruvec, lru, nr_zone_taken);
+
 	return nr_taken;
 }
 
@@ -1794,6 +1803,9 @@ int isolate_lru_page(struct page *page)
 			ClearPageLRU(page);
 			del_page_from_lru_list(page, lruvec, lru);
 			ret = 0;
+			mod_node_page_state(pgdat, NR_ISOLATED_ANON +
+						page_is_file_cache(page),
+						hpage_nr_pages(page));
 		}
 		spin_unlock_irq(&pgdat->lru_lock);
 	}
@@ -1885,6 +1897,9 @@ static unsigned noinline_for_stack move_pages_to_lru(struct lruvec *lruvec,
 		update_lru_size(lruvec, lru, page_zonenum(page), nr_pages);
 		list_move(&page->lru, &lruvec->lists[lru]);
 
+		__mod_node_page_state(pgdat, NR_ISOLATED_ANON +
+						page_is_file_cache(page),
+						-hpage_nr_pages(page));
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
 			__ClearPageActive(page);
@@ -1962,7 +1977,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
 				     &nr_scanned, sc, lru);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	item = current_is_kswapd() ? PGSCAN_KSWAPD : PGSCAN_DIRECT;
@@ -1988,8 +2002,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	move_pages_to_lru(lruvec, &page_list);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
-
 	spin_unlock_irq(&pgdat->lru_lock);
 
 	mem_cgroup_uncharge_list(&page_list);
@@ -2048,7 +2060,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold,
 				     &nr_scanned, sc, lru);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	__count_vm_events(PGREFILL, nr_scanned);
@@ -2117,7 +2128,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	__count_vm_events(PGDEACTIVATE, nr_deactivate);
 	__count_memcg_events(lruvec_memcg(lruvec), PGDEACTIVATE, nr_deactivate);
 
-	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&pgdat->lru_lock);
 
 	mem_cgroup_uncharge_list(&l_active);
-- 
2.22.0.rc2.383.gf4fbbf30c2-goog

