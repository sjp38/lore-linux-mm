Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 005336B0110
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 18:39:25 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so8260066pbc.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 15:39:25 -0800 (PST)
Date: Mon, 20 Feb 2012 15:39:01 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 10/10] mm/memcg: per-memcg per-zone lru locking
In-Reply-To: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1202201538070.23274@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Flip the switch from per-zone lru locking to per-memcg per-zone lru locking.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/swap.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- mmotm.orig/include/linux/swap.h	2012-02-18 11:58:09.047525220 -0800
+++ mmotm/include/linux/swap.h	2012-02-18 11:58:15.659525376 -0800
@@ -252,8 +252,8 @@ static inline void lru_cache_add_file(st
 
 static inline spinlock_t *lru_lockptr(struct lruvec *lruvec)
 {
-	/* Still use per-zone lru_lock */
-	return &lruvec->zone->lruvec.lru_lock;
+	/* Now use per-memcg-per-zone lru_lock */
+	return &lruvec->lru_lock;
 }
 
 static inline void lock_lruvec(struct lruvec *lruvec)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
