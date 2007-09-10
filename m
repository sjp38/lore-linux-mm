Date: Mon, 10 Sep 2007 18:56:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [10/35] changes in EFS
Message-Id: <20070910185631.70386ef9.kamezawa.hiroyu@jp.fujitsu.com>
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

Change page->mapping handling in EFS

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


Index: test-2.6.23-rc4-mm1/fs/efs/symlink.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/efs/symlink.c
+++ test-2.6.23-rc4-mm1/fs/efs/symlink.c
@@ -16,7 +16,7 @@ static int efs_symlink_readpage(struct f
 {
 	char *link = kmap(page);
 	struct buffer_head * bh;
-	struct inode * inode = page->mapping->host;
+	struct inode * inode = page_inode(page);
 	efs_block_t size = inode->i_size;
 	int err;
   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
