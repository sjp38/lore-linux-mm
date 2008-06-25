Date: Wed, 25 Jun 2008 19:02:48 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [-mm][PATCH 2/10] fix printk in show_free_areas()
In-Reply-To: <20080625185717.D84C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080625185717.D84C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080625190145.D852.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

=
From: Rik van Riel <riel@redhat.com>

Fix typo in show_free_areas.

Debugged-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1931,7 +1931,7 @@ void show_free_areas(void)
 		}
 	}
 
-	printk("Active_anon:%lu active_file:%lu inactive_anon%lu\n"
+	printk("Active_anon:%lu active_file:%lu inactive_anon:%lu\n"
 		" inactive_file:%lu"
 //TODO:  check/adjust line lengths
 #ifdef CONFIG_UNEVICTABLE_LRU


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
