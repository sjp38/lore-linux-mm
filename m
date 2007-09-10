Date: Mon, 10 Sep 2007 19:15:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [21/35] changes in JBD
Message-Id: <20070910191506.75a78deb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: sct@redhat.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Changes page->mapping handling in JBD

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 fs/jbd/journal.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: test-2.6.23-rc4-mm1/fs/jbd/journal.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/jbd/journal.c
+++ test-2.6.23-rc4-mm1/fs/jbd/journal.c
@@ -1822,7 +1822,7 @@ repeat:
 		jh = bh2jh(bh);
 	} else {
 		if (!(atomic_read(&bh->b_count) > 0 ||
-				(bh->b_page && bh->b_page->mapping))) {
+				(bh->b_page && page_mapping_cache(bh->b_page)))) {
 			printk(KERN_EMERG "%s: bh->b_count=%d\n",
 				__FUNCTION__, atomic_read(&bh->b_count));
 			printk(KERN_EMERG "%s: bh->b_page=%p\n",
@@ -1830,7 +1830,7 @@ repeat:
 			if (bh->b_page)
 				printk(KERN_EMERG "%s: "
 						"bh->b_page->mapping=%p\n",
-					__FUNCTION__, bh->b_page->mapping);
+				 __FUNCTION__, page_mapping_cache(bh->b_page));
 		}
 
 		if (!new_jh) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
