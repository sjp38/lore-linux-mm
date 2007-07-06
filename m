Subject: [PATCH] mm: fixup /proc/vmstat output
From: Peter Zijlstra <peterz@infradead.org>
Content-Type: text/plain
Date: Fri, 06 Jul 2007 13:35:34 +0200
Message-Id: <1183721734.7054.102.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Fengguang Wu <wfg@mail.ustc.edu.cn>, Rusty Russell <rusty@rustcorp.com.au>, Christoph Lameter <clameter@sgi.com>, riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Line up the vmstat_text with zone_stat_item

enum zone_stat_item {
	/* First 128 byte cacheline (assuming 64 bit words) */
	NR_FREE_PAGES,
	NR_INACTIVE,
	NR_ACTIVE,

We current have nr_active and nr_inactive reversed.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/vmstat.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/vmstat.c
===================================================================
--- linux-2.6.orig/mm/vmstat.c
+++ linux-2.6/mm/vmstat.c
@@ -700,8 +700,8 @@ const struct seq_operations pagetypeinfo
 static const char * const vmstat_text[] = {
 	/* Zoned VM counters */
 	"nr_free_pages",
-	"nr_active",
 	"nr_inactive",
+	"nr_active",
 	"nr_anon_pages",
 	"nr_mapped",
 	"nr_file_pages",


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
