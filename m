Date: Wed, 14 Jul 2004 23:05:59 +0900 (JST)
Message-Id: <20040714.230559.94845836.taka@valinux.co.jp>
Subject: [BUG][PATCH] memory hotremoval for linux-2.6.7 [12/16]
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20040714.224138.95803956.taka@valinux.co.jp>
References: <20040714.224138.95803956.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--- linux-2.6.7/mm/hugetlb.c.save	Wed Jul  7 18:34:06 2032
+++ linux-2.6.7/mm/hugetlb.c	Wed Jul  7 18:35:10 2032
@@ -149,8 +149,8 @@ static int try_to_free_low(unsigned long
 {
 	int i;
 	for (i = 0; i < MAX_NUMNODES; ++i) {
-		struct page *page;
-		list_for_each_entry(page, &hugepage_freelists[i], lru) {
+		struct page *page, *page1;
+		list_for_each_entry_safe(page, page1, &hugepage_freelists[i], lru) {
 			if (PageHighMem(page))
 				continue;
 			list_del(&page->lru);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
