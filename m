Date: Thu, 19 Jun 2008 18:17:03 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [-mm][PATCH 4/5]  fix incorrect Mlocked field of /proc/meminfo.
In-Reply-To: <20080619172241.E7FC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080619172241.E7FC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080619181543.E80B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Mlocked field of /proc/meminfo display silly number.
because trivial mistake exist in meminfo_read_proc().

Signed-off-by: Hugh Dickins <hugh@veritas.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 fs/proc/proc_misc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: b/fs/proc/proc_misc.c
===================================================================
--- a/fs/proc/proc_misc.c
+++ b/fs/proc/proc_misc.c
@@ -216,7 +216,7 @@ static int meminfo_read_proc(char *page,
 		K(pages[LRU_INACTIVE_FILE]),
 #ifdef CONFIG_UNEVICTABLE_LRU
 		K(pages[LRU_UNEVICTABLE]),
-		K(pages[NR_MLOCK]),
+		K(global_page_state(NR_MLOCK)),
 #endif
 #ifdef CONFIG_HIGHMEM
 		K(i.totalhigh),


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
