Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id CE70C6B008A
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 06:54:19 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id wd18so13312502obb.14
        for <linux-mm@kvack.org>; Wed, 06 Jun 2012 03:54:19 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 02/11] mm: frontswap: trivial coding convention issues
Date: Wed,  6 Jun 2012 12:55:06 +0200
Message-Id: <1338980115-2394-2-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
References: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad.wilk@oracle.com, dan.magenheimer@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/frontswap.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index 07c0eee..844d6a6 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -127,8 +127,9 @@ int __frontswap_put_page(struct page *page)
 		frontswap_clear(sis, offset);
 		atomic_dec(&sis->frontswap_pages);
 		frontswap_failed_puts++;
-	} else
+	} else {
 		frontswap_failed_puts++;
+	}
 	if (frontswap_writethrough_enabled)
 		/* report failure so swap also writes to swap device */
 		ret = -1;
@@ -229,9 +230,9 @@ void frontswap_shrink(unsigned long target_pages)
 	for (type = swap_list.head; type >= 0; type = si->next) {
 		si = swap_info[type];
 		si_frontswap_pages = atomic_read(&si->frontswap_pages);
-		if (total_pages_to_unuse < si_frontswap_pages)
+		if (total_pages_to_unuse < si_frontswap_pages) {
 			pages = pages_to_unuse = total_pages_to_unuse;
-		else {
+		} else {
 			pages = si_frontswap_pages;
 			pages_to_unuse = 0; /* unuse all */
 		}
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
