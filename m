Date: Mon, 10 Sep 2007 19:13:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [20/35] changes in
 ISOFS
Message-Id: <20070910191351.e9aafb20.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Changes page->mapping handling in ISOFS

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 fs/isofs/rock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: test-2.6.23-rc4-mm1/fs/isofs/rock.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/isofs/rock.c
+++ test-2.6.23-rc4-mm1/fs/isofs/rock.c
@@ -640,7 +640,7 @@ int parse_rock_ridge_inode(struct iso_di
  */
 static int rock_ridge_symlink_readpage(struct file *file, struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct iso_inode_info *ei = ISOFS_I(inode);
 	char *link = kmap(page);
 	unsigned long bufsize = ISOFS_BUFFER_SIZE(inode);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
