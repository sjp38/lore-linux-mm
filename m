Date: Mon, 10 Sep 2007 19:02:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [14/35] changes in
 freevxfs
Message-Id: <20070910190249.c5da3b58.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: hch@infradead.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Changes page->mapping handling in freevxfs.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 fs/freevxfs/vxfs_immed.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: test-2.6.23-rc4-mm1/fs/freevxfs/vxfs_immed.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/freevxfs/vxfs_immed.c
+++ test-2.6.23-rc4-mm1/fs/freevxfs/vxfs_immed.c
@@ -98,7 +98,7 @@ vxfs_immed_follow_link(struct dentry *dp
 static int
 vxfs_immed_readpage(struct file *fp, struct page *pp)
 {
-	struct vxfs_inode_info	*vip = VXFS_INO(pp->mapping->host);
+	struct vxfs_inode_info	*vip = VXFS_INO(page_inode(pp));
 	u_int64_t	offset = (u_int64_t)pp->index << PAGE_CACHE_SHIFT;
 	caddr_t		kaddr;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
