Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DA9EE9000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 00:22:38 -0400 (EDT)
Received: by vws4 with SMTP id 4so1461103vws.14
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 21:22:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <b7bcce639e9b9bf515431cda79b15d482f889ff2.1303833418.git.minchan.kim@gmail.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
	<b7bcce639e9b9bf515431cda79b15d482f889ff2.1303833418.git.minchan.kim@gmail.com>
Date: Wed, 27 Apr 2011 13:22:37 +0900
Message-ID: <BANLkTincwtuon1nk8C3q6+CFHhQx-ZXVNQ@mail.gmail.com>
Subject: Re: [RFC 8/8] compaction: make compaction use in-order putback
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

I should have add up this piece.
I will resend all after work.

===

diff --git a/mm/compaction.c b/mm/compaction.c
index 95af5bc..59a675c 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c

@@ -327,7 +328,7 @@ static unsigned long isolate_migratepages(struct zone *zone,

                /* Successfully isolated */
                del_page_from_lru_list(zone, page, page_lru(page));
-               list_add(&page->lru, migratelist);
+               list_add(&pages_lru->lru, migratelist);
                cc->nr_migratepages++;
                nr_isolated++;
@@ -525,7 +525,7 @@ static int compact_zone(struct zone *zone, struct
compact_control *cc)
                nr_migrate = cc->nr_migratepages;
                migrate_pages(&cc->migratepages, compaction_alloc,
                                (unsigned long)cc, false,
-                               cc->sync, false);
+                               cc->sync, true);
                count_vm_event(PGMIGRATE);
                update_nr_listpages(cc);
                nr_remaining = cc->nr_migratepages;

==
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
