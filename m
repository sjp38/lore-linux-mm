Date: Mon, 10 Sep 2007 19:04:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [15/35] changes in
 FUSE
Message-Id: <20070910190459.89e3081b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: miklos@szeredi.hu, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Changes page->mapping handling in FUSE

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/fuse/file.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: test-2.6.23-rc4-mm1/fs/fuse/file.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/fuse/file.c
+++ test-2.6.23-rc4-mm1/fs/fuse/file.c
@@ -310,7 +310,7 @@ static size_t fuse_send_read(struct fuse
 
 static int fuse_readpage(struct file *file, struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct fuse_conn *fc = get_fuse_conn(inode);
 	struct fuse_req *req;
 	int err;
@@ -342,7 +342,7 @@ static void fuse_readpages_end(struct fu
 {
 	int i;
 
-	fuse_invalidate_attr(req->pages[0]->mapping->host); /* atime changed */
+	fuse_invalidate_attr(page_inode(req->pages[0])); /* atime changed */
 
 	for (i = 0; i < req->num_pages; i++) {
 		struct page *page = req->pages[i];

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
