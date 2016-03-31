Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id E8ED26B0253
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 17:58:46 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id 191so112459wmq.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 14:58:46 -0700 (PDT)
Received: from mail.sigma-star.at (mail.sigma-star.at. [95.130.255.111])
        by mx.google.com with ESMTP id i185si31767865wmi.55.2016.03.31.14.58.45
        for <linux-mm@kvack.org>;
        Thu, 31 Mar 2016 14:58:46 -0700 (PDT)
From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 1/2] mm: Export migrate_page_move_mapping and migrate_page_copy
Date: Thu, 31 Mar 2016 23:58:32 +0200
Message-Id: <1459461513-31765-2-git-send-email-richard@nod.at>
In-Reply-To: <1459461513-31765-1-git-send-email-richard@nod.at>
References: <1459461513-31765-1-git-send-email-richard@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mtd@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, boris.brezillon@free-electrons.com, maxime.ripard@free-electrons.com, david@sigma-star.at, david@fromorbit.com, dedekind1@gmail.com, alex@nextthing.co, akpm@linux-foundation.org, sasha.levin@oracle.com, iamjoonsoo.kim@lge.com, rvaswani@codeaurora.org, tony.luck@intel.com, shailendra.capricorn@gmail.com, kirill.shutemov@linux.intel.com, hch@infradead.org, hughd@google.com, mgorman@techsingularity.net, vbabka@suse.cz, Richard Weinberger <richard@nod.at>

Export these symbols such that UBIFS can implement
->migratepage.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 mm/migrate.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/migrate.c b/mm/migrate.c
index 6c822a7..6bc1035 100644
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
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
