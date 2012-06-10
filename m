Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 1E2BF6B006C
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 06:50:05 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jm19so3841564bkc.14
        for <linux-mm@kvack.org>; Sun, 10 Jun 2012 03:50:04 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v3 02/10] mm: frontswap: trivial coding convention issues
Date: Sun, 10 Jun 2012 12:51:00 +0200
Message-Id: <1339325468-30614-3-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com>
References: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, konrad.wilk@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/frontswap.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index 557e8af4..7ec53d5 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -148,8 +148,9 @@ int __frontswap_store(struct page *page)
 		frontswap_clear(sis, offset);
 		atomic_dec(&sis->frontswap_pages);
 		inc_frontswap_failed_stores();
-	} else
+	} else {
 		inc_frontswap_failed_stores();
+	}
 	if (frontswap_writethrough_enabled)
 		/* report failure so swap also writes to swap device */
 		ret = -1;
@@ -250,9 +251,9 @@ void frontswap_shrink(unsigned long target_pages)
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
