Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 65247900137
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 12:42:36 -0400 (EDT)
Received: by gwaa20 with SMTP id a20so5918462gwa.14
        for <linux-mm@kvack.org>; Mon, 29 Aug 2011 09:42:34 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 1/3] Correct isolate_mode_t bitwise type
Date: Sun, 13 Nov 2011 01:37:41 +0900
Message-Id: <e139175e938d94c0c977edd05ae07cbad7a72cc5.1321112552.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1321112552.git.minchan.kim@gmail.com>
References: <cover.1321112552.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1321112552.git.minchan.kim@gmail.com>
References: <cover.1321112552.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

[c1e8b0ae8, mm-change-isolate-mode-from-define-to-bitwise-type]
made a mistake on the bitwise type.

This patch corrects it.

CC: Mel Gorman <mgorman@suse.de>
CC: Johannes Weiner <jweiner@redhat.com>
CC: Rik van Riel <riel@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/mmzone.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 1ed4116..188cb2f 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -166,13 +166,13 @@ static inline int is_unevictable_lru(enum lru_list l)
 #define LRU_ALL	     ((1 << NR_LRU_LISTS) - 1)

 /* Isolate inactive pages */
-#define ISOLATE_INACTIVE	((__force fmode_t)0x1)
+#define ISOLATE_INACTIVE	((__force isolate_mode_t)0x1)
 /* Isolate active pages */
-#define ISOLATE_ACTIVE		((__force fmode_t)0x2)
+#define ISOLATE_ACTIVE		((__force isolate_mode_t)0x2)
 /* Isolate clean file */
-#define ISOLATE_CLEAN		((__force fmode_t)0x4)
+#define ISOLATE_CLEAN		((__force isolate_mode_t)0x4)
 /* Isolate unmapped file */
-#define ISOLATE_UNMAPPED	((__force fmode_t)0x8)
+#define ISOLATE_UNMAPPED	((__force isolate_mode_t)0x8)

 /* LRU Isolation modes. */
 typedef unsigned __bitwise__ isolate_mode_t;
--
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
