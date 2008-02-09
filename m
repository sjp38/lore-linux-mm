Received: by py-out-1112.google.com with SMTP id f47so4291042pye.20
        for <linux-mm@kvack.org>; Sat, 09 Feb 2008 07:25:32 -0800 (PST)
Message-ID: <2f11576a0802090725w6437bcc5vde2392c794095f6b@mail.gmail.com>
Date: Sun, 10 Feb 2008 00:25:31 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 5/8][for -mm] mem_notify v6: add new mem_notify field to /proc/zoneinfo
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-fsdevel@vger.kernel.org, Pavel Machek <pavel@ucw.cz>, Al Boldi <a1426z@gawab.com>, Jon Masters <jonathan@jonmasters.org>, Zan Lynx <zlynx@acm.org>
List-ID: <linux-mm.kvack.org>

show new member of zone struct by /proc/zoneinfo.

ChangeLog:
	v5: change display order to at last.


Signed-off-by: Marcelo Tosatti <marcelo@kvack.org>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/vmstat.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

Index: b/mm/vmstat.c
===================================================================
--- a/mm/vmstat.c	2008-01-23 22:06:05.000000000 +0900
+++ b/mm/vmstat.c	2008-01-23 22:08:00.000000000 +0900
@@ -795,10 +795,12 @@ static void zoneinfo_show_print(struct s
 	seq_printf(m,
 		   "\n  all_unreclaimable: %u"
 		   "\n  prev_priority:     %i"
-		   "\n  start_pfn:         %lu",
-			   zone_is_all_unreclaimable(zone),
+		   "\n  start_pfn:         %lu"
+		   "\n  mem_notify_status: %i",
+		   zone_is_all_unreclaimable(zone),
 		   zone->prev_priority,
-		   zone->zone_start_pfn);
+		   zone->zone_start_pfn,
+		   zone->mem_notify_status);
 	seq_putc(m, '\n');
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
