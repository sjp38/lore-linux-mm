Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 76CBC6B005A
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 02:10:51 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/7] zsmalloc: s/firstpage/page in new copy map funcs
Date: Wed,  8 Aug 2012 15:12:14 +0900
Message-Id: <1344406340-14128-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1344406340-14128-1-git-send-email-minchan@kernel.org>
References: <1344406340-14128-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>

From: Seth Jennings <sjenning@linux.vnet.ibm.com>

firstpage already has precedent and meaning the first page
of a zspage.  In the case of the copy mapping functions,
it is the first of a pair of pages needing to be mapped.

This patch just renames the firstpage argument to "page" to
avoid confusion.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zsmalloc/zsmalloc-main.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 8b0bcb6..3c83c65 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -470,15 +470,15 @@ static struct page *find_get_zspage(struct size_class *class)
 	return page;
 }
 
-static void zs_copy_map_object(char *buf, struct page *firstpage,
+static void zs_copy_map_object(char *buf, struct page *page,
 				int off, int size)
 {
 	struct page *pages[2];
 	int sizes[2];
 	void *addr;
 
-	pages[0] = firstpage;
-	pages[1] = get_next_page(firstpage);
+	pages[0] = page;
+	pages[1] = get_next_page(page);
 	BUG_ON(!pages[1]);
 
 	sizes[0] = PAGE_SIZE - off;
@@ -493,15 +493,15 @@ static void zs_copy_map_object(char *buf, struct page *firstpage,
 	kunmap_atomic(addr);
 }
 
-static void zs_copy_unmap_object(char *buf, struct page *firstpage,
+static void zs_copy_unmap_object(char *buf, struct page *page,
 				int off, int size)
 {
 	struct page *pages[2];
 	int sizes[2];
 	void *addr;
 
-	pages[0] = firstpage;
-	pages[1] = get_next_page(firstpage);
+	pages[0] = page;
+	pages[1] = get_next_page(page);
 	BUG_ON(!pages[1]);
 
 	sizes[0] = PAGE_SIZE - off;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
