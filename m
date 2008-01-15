Date: Tue, 15 Jan 2008 10:03:23 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH 5/5] /proc/zoneinfo enhancement
In-Reply-To: <20080115092828.116F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080115092828.116F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080115100233.117E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

show new member of zone struct by /proc/zoneinfo.

Signed-off-by: Marcelo Tosatti <marcelo@kvack.org>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/vmstat.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: linux-2.6.24-rc6-mm1-memnotify/mm/vmstat.c
===================================================================
--- linux-2.6.24-rc6-mm1-memnotify.orig/mm/vmstat.c	2008-01-13 16:42:54.000000000 +0900
+++ linux-2.6.24-rc6-mm1-memnotify/mm/vmstat.c	2008-01-13 17:07:43.000000000 +0900
@@ -795,9 +795,11 @@ static void zoneinfo_show_print(struct s
 	seq_printf(m,
 		   "\n  all_unreclaimable: %u"
 		   "\n  prev_priority:     %i"
+		   "\n  mem_notify_status: %i"
 		   "\n  start_pfn:         %lu",
-			   zone_is_all_unreclaimable(zone),
+		   zone_is_all_unreclaimable(zone),
 		   zone->prev_priority,
+		   zone->mem_notify_status,
 		   zone->zone_start_pfn);
 	seq_putc(m, '\n');
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
