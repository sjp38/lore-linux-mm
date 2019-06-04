Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4743C28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:26:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FB5824AF4
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:26:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Y3GVvJag"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FB5824AF4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F03DC6B026D; Tue,  4 Jun 2019 03:26:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB4A26B026E; Tue,  4 Jun 2019 03:26:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2F8F6B0270; Tue,  4 Jun 2019 03:26:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5DA6B026D
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 03:26:24 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id c4so11788598pgm.21
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 00:26:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=f6lqyr2BfengWxFqHdlTowTllezFlrs3heXkz9HMYTU=;
        b=VfmmNwAnjbZjRg72Yc7lw3uDv/ilRcqeJ+L4EWq0je9KHw+DULeIozhUZJCXxQikO+
         1h/OovyVsGe8rY0PoUsDn/hgVwrn9yLjIQqLy6ZYJq56c2fRX/xaHsDFNjWhUKb/UQVt
         C6TjxbUGiIoR9rQGtQ6HngzccWBG06Wb2919boN8QgQ8PfeWOh6D3mDAGberjIE++fDA
         p+DlNVuHAUqMfz5Bbqwqaw7N7ektMPFS2ounulkUPlZhql8Nz9aJYxcUchVvFpVgUANt
         potMzbQcbIlE2i3onxHbpLx+JJsP05HlfhrKyfE+bT+VOXpYpCaCw6G3Iv50Zf8vnRnm
         bUYA==
X-Gm-Message-State: APjAAAVTkX6Lpwx3UmISc8Ta0h0WLv6Kbro4z58rZ55EXl0hO7pV1ePE
	ZSBYoqztN+czVbgMJy9Xmrj3B7hoyYIkE+K88Fpe0A//Z4v8/JZ0XTkrq6Pm6wBCxZfudXSdJ16
	hc+ofOu9zwJAy/d7KNrb8u0JTPBtOuEd3Wt3o7+g+IjJ6Bf1XPWJwoJFWBmaOdgj4bw==
X-Received: by 2002:a63:c750:: with SMTP id v16mr33250635pgg.409.1559633184082;
        Tue, 04 Jun 2019 00:26:24 -0700 (PDT)
X-Received: by 2002:a63:c750:: with SMTP id v16mr33250597pgg.409.1559633183123;
        Tue, 04 Jun 2019 00:26:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559633183; cv=none;
        d=google.com; s=arc-20160816;
        b=xbSGI3us/8NVmrm75q/H5IFcKxD9xfXQnJ6PO4NB8NT8LCau75SO/boHYzfsnxyPsc
         31P2EsCtyXTjm79whsDbMv2QoRsDvin32P97waVe39EvyciOmXA8rDCbUbd3aAgXJCYx
         BNqep1SHLMfmFp85IzaZMjsy72VE/VruYZF/G6Q57KD3cG2LCMQYgDsOOpVveHy0WfIq
         m43yi9OxiJ3DEYSYN6mBzp5D8nEfF07BlYsK2Mq1w3Sf2yMTQIfd1ANi1FRunDJlFZ8/
         zbKouKRgtnJPAWe/15WuvcrZ6D50EMv0hc7+qAD3CSS7s0o9bgrvvxHApkdqYAho5zFp
         cojQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=f6lqyr2BfengWxFqHdlTowTllezFlrs3heXkz9HMYTU=;
        b=bAUoy/OKy+3OVkgMZJqEsBiYiawIn342Tlv4T8vv4gKZBjOIBvIiqyL5Yzp2Z8y7e7
         grv7nONnHRlaqcAzrrhg35OAJqmczA9FWCWwPatfyx/a7PGHMpBw/tPY4/K1IpwtP+rK
         VcDlt02g9ST3nenI7DAeGhjtZ/k4vZAaUlnkTGBpkzHHQjASaPptNfLRF+n4A2mu12Yi
         xsIlQQo/6WH6fc0rIETaKd/gaOqIkS0/E6dwatnK6j21OaSKoF8IHwO/PWJ2MVWm0hI6
         9VVdyRZ9WaS18pNqsZV+XYscrxbWQoqUhrUONOs9WeL+L+mXeg+zPu6IwVxoAnW/5M9B
         M8xA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Y3GVvJag;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o8sor20123181plk.18.2019.06.04.00.26.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 00:26:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Y3GVvJag;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=f6lqyr2BfengWxFqHdlTowTllezFlrs3heXkz9HMYTU=;
        b=Y3GVvJagUgHx3WtvpI5wZzCkScGOTP8c2Nerrvzl4t/n5Dz1P3nmPGl+PV7wJklq1c
         V1xA7pFvEErx/7xHdNbouUEUqqPV/hu3CVLHobmhxoaxGRn2AB9U7zCxGk9mJi79VdBx
         GfF5MhXPSXWHl8g6DQPQ+uOOFdqctuhJlefhLkETVKWtwZVe/0VF+mi6otJLc6bho2Mg
         aErjdSMnuBy1O2NzrVwlChx99ecc6xNXIKSucHlDawiL7t/+5cUlToaDeX9VQtbZmxHz
         4hxW97y7dPSenJJxJndkqHorMn/zL0v87NxXt/v0OyoU7S//2mdIhiRWIY9Tk00ganOt
         VosQ==
X-Google-Smtp-Source: APXvYqzqFwkFw17oWfgcJRnP/Byrcg8l33w6SlO+CnZNXQp16bR9IEbAVSoS/WbBu98ZS5c2itf2gA==
X-Received: by 2002:a17:902:22e:: with SMTP id 43mr33612048plc.272.1559633182666;
        Tue, 04 Jun 2019 00:26:22 -0700 (PDT)
Received: from mylaptop.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id q17sm25748582pfq.74.2019.06.04.00.26.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 00:26:22 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Mike Rapoport <rppt@linux.ibm.com>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm/gup: remove unnecessary check against CMA in __gup_longterm_locked()
Date: Tue,  4 Jun 2019 15:26:00 +0800
Message-Id: <1559633160-14809-1-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The PF_MEMALLOC_NOCMA is set by memalloc_nocma_save(), which is finally
cast to ~_GFP_MOVABLE.  So __get_user_pages_locked() will get pages from
non CMA area and pin them.  There is no need to
check_and_migrate_cma_pages().

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Keith Busch <keith.busch@intel.com>
Cc: linux-kernel@vger.kernel.org
---
 mm/gup.c | 146 ---------------------------------------------------------------
 1 file changed, 146 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index f173fcb..9d931d1 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1275,149 +1275,6 @@ static bool check_dax_vmas(struct vm_area_struct **vmas, long nr_pages)
 	return false;
 }
 
-#ifdef CONFIG_CMA
-static struct page *new_non_cma_page(struct page *page, unsigned long private)
-{
-	/*
-	 * We want to make sure we allocate the new page from the same node
-	 * as the source page.
-	 */
-	int nid = page_to_nid(page);
-	/*
-	 * Trying to allocate a page for migration. Ignore allocation
-	 * failure warnings. We don't force __GFP_THISNODE here because
-	 * this node here is the node where we have CMA reservation and
-	 * in some case these nodes will have really less non movable
-	 * allocation memory.
-	 */
-	gfp_t gfp_mask = GFP_USER | __GFP_NOWARN;
-
-	if (PageHighMem(page))
-		gfp_mask |= __GFP_HIGHMEM;
-
-#ifdef CONFIG_HUGETLB_PAGE
-	if (PageHuge(page)) {
-		struct hstate *h = page_hstate(page);
-		/*
-		 * We don't want to dequeue from the pool because pool pages will
-		 * mostly be from the CMA region.
-		 */
-		return alloc_migrate_huge_page(h, gfp_mask, nid, NULL);
-	}
-#endif
-	if (PageTransHuge(page)) {
-		struct page *thp;
-		/*
-		 * ignore allocation failure warnings
-		 */
-		gfp_t thp_gfpmask = GFP_TRANSHUGE | __GFP_NOWARN;
-
-		/*
-		 * Remove the movable mask so that we don't allocate from
-		 * CMA area again.
-		 */
-		thp_gfpmask &= ~__GFP_MOVABLE;
-		thp = __alloc_pages_node(nid, thp_gfpmask, HPAGE_PMD_ORDER);
-		if (!thp)
-			return NULL;
-		prep_transhuge_page(thp);
-		return thp;
-	}
-
-	return __alloc_pages_node(nid, gfp_mask, 0);
-}
-
-static long check_and_migrate_cma_pages(struct task_struct *tsk,
-					struct mm_struct *mm,
-					unsigned long start,
-					unsigned long nr_pages,
-					struct page **pages,
-					struct vm_area_struct **vmas,
-					unsigned int gup_flags)
-{
-	long i;
-	bool drain_allow = true;
-	bool migrate_allow = true;
-	LIST_HEAD(cma_page_list);
-
-check_again:
-	for (i = 0; i < nr_pages; i++) {
-		/*
-		 * If we get a page from the CMA zone, since we are going to
-		 * be pinning these entries, we might as well move them out
-		 * of the CMA zone if possible.
-		 */
-		if (is_migrate_cma_page(pages[i])) {
-
-			struct page *head = compound_head(pages[i]);
-
-			if (PageHuge(head)) {
-				isolate_huge_page(head, &cma_page_list);
-			} else {
-				if (!PageLRU(head) && drain_allow) {
-					lru_add_drain_all();
-					drain_allow = false;
-				}
-
-				if (!isolate_lru_page(head)) {
-					list_add_tail(&head->lru, &cma_page_list);
-					mod_node_page_state(page_pgdat(head),
-							    NR_ISOLATED_ANON +
-							    page_is_file_cache(head),
-							    hpage_nr_pages(head));
-				}
-			}
-		}
-	}
-
-	if (!list_empty(&cma_page_list)) {
-		/*
-		 * drop the above get_user_pages reference.
-		 */
-		for (i = 0; i < nr_pages; i++)
-			put_page(pages[i]);
-
-		if (migrate_pages(&cma_page_list, new_non_cma_page,
-				  NULL, 0, MIGRATE_SYNC, MR_CONTIG_RANGE)) {
-			/*
-			 * some of the pages failed migration. Do get_user_pages
-			 * without migration.
-			 */
-			migrate_allow = false;
-
-			if (!list_empty(&cma_page_list))
-				putback_movable_pages(&cma_page_list);
-		}
-		/*
-		 * We did migrate all the pages, Try to get the page references
-		 * again migrating any new CMA pages which we failed to isolate
-		 * earlier.
-		 */
-		nr_pages = __get_user_pages_locked(tsk, mm, start, nr_pages,
-						   pages, vmas, NULL,
-						   gup_flags);
-
-		if ((nr_pages > 0) && migrate_allow) {
-			drain_allow = true;
-			goto check_again;
-		}
-	}
-
-	return nr_pages;
-}
-#else
-static long check_and_migrate_cma_pages(struct task_struct *tsk,
-					struct mm_struct *mm,
-					unsigned long start,
-					unsigned long nr_pages,
-					struct page **pages,
-					struct vm_area_struct **vmas,
-					unsigned int gup_flags)
-{
-	return nr_pages;
-}
-#endif
-
 /*
  * __gup_longterm_locked() is a wrapper for __get_user_pages_locked which
  * allows us to process the FOLL_LONGTERM flag.
@@ -1462,9 +1319,6 @@ static long __gup_longterm_locked(struct task_struct *tsk,
 			rc = -EOPNOTSUPP;
 			goto out;
 		}
-
-		rc = check_and_migrate_cma_pages(tsk, mm, start, rc, pages,
-						 vmas_tmp, gup_flags);
 	}
 
 out:
-- 
2.7.5

