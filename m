Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id E84EF6B025E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 17:26:28 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id na2so32274423lbb.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 14:26:28 -0700 (PDT)
Received: from mail.sigma-star.at (mail.sigma-star.at. [95.130.255.111])
        by mx.google.com with ESMTP id gg9si7639830wjb.19.2016.06.16.14.26.26
        for <linux-mm@kvack.org>;
        Thu, 16 Jun 2016 14:26:26 -0700 (PDT)
From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 2/3] mm: Export migrate_page_move_mapping and migrate_page_copy
Date: Thu, 16 Jun 2016 23:26:14 +0200
Message-Id: <1466112375-1717-3-git-send-email-richard@nod.at>
In-Reply-To: <1466112375-1717-1-git-send-email-richard@nod.at>
References: <1466112375-1717-1-git-send-email-richard@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-mtd@lists.infradead.org, hannes@cmpxchg.org, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, hughd@google.com, vbabka@suse.cz, akpm@linux-foundation.org, adrian.hunter@intel.com, dedekind1@gmail.com, richard@nod.at, hch@infradead.org, linux-fsdevel@vger.kernel.org, boris.brezillon@free-electrons.com, maxime.ripard@free-electrons.com, david@sigma-star.at, david@fromorbit.com, alex@nextthing.co, sasha.levin@oracle.com, iamjoonsoo.kim@lge.com, rvaswani@codeaurora.org, tony.luck@intel.com, shailendra.capricorn@gmail.com

Export these symbols such that UBIFS can implement
->migratepage.

Signed-off-by: Richard Weinberger <richard@nod.at>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 mm/migrate.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/migrate.c b/mm/migrate.c
index 5129143..0fcdd86 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -431,6 +431,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
 
 	return MIGRATEPAGE_SUCCESS;
 }
+EXPORT_SYMBOL(migrate_page_move_mapping);
 
 /*
  * The expected number of remaining references is the same as that
@@ -586,6 +587,7 @@ void migrate_page_copy(struct page *newpage, struct page *page)
 
 	mem_cgroup_migrate(page, newpage);
 }
+EXPORT_SYMBOL(migrate_page_copy);
 
 /************************************************************
  *                    Migration functions
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
