Date: Mon, 10 Sep 2007 19:32:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [32/35] changes in
 UDFFS
Message-Id: <20070910193204.952dc9d9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: bfennema@falcon.csc.calpoly.edu, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Changes page->mapping handling in UDFFS

Signed-off-by: KAMEZAWA hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/udf/file.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: test-2.6.23-rc4-mm1/fs/udf/file.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/udf/file.c
+++ test-2.6.23-rc4-mm1/fs/udf/file.c
@@ -43,7 +43,7 @@
 
 static int udf_adinicb_readpage(struct file *file, struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	char *kaddr;
 
 	BUG_ON(!PageLocked(page));
@@ -61,7 +61,7 @@ static int udf_adinicb_readpage(struct f
 
 static int udf_adinicb_writepage(struct page *page, struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	char *kaddr;
 
 	BUG_ON(!PageLocked(page));
Index: test-2.6.23-rc4-mm1/fs/udf/symlink.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/udf/symlink.c
+++ test-2.6.23-rc4-mm1/fs/udf/symlink.c
@@ -73,7 +73,7 @@ static void udf_pc_to_char(struct super_
 
 static int udf_symlink_filler(struct file *file, struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct buffer_head *bh = NULL;
 	char *symlink;
 	int err = -EIO;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
