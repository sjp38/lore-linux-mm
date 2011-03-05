Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 258868D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 13:49:32 -0500 (EST)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-03.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 5 Mar 2011 18:49:27 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH] mm: remove inline from scan_swap_map
Date: Sat,  5 Mar 2011 15:49:16 -0300
Message-Id: <1299350956-5614-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Cesar Eduardo Barros <cesarb@cesarb.net>

scan_swap_map is a large function (224 lines), with several loops and a
complex control flow involving several gotos.

Given all that, it is a bit silly that is is marked as inline. The
compiler agrees with me: on a x86-64 compile, it did not inline the
function.

Remove the "inline" and let the compiler decide instead.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 0341c57..8ed42e7 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -212,8 +212,8 @@ static int wait_for_discard(void *word)
 #define SWAPFILE_CLUSTER	256
 #define LATENCY_LIMIT		256
 
-static inline unsigned long scan_swap_map(struct swap_info_struct *si,
-					  unsigned char usage)
+static unsigned long scan_swap_map(struct swap_info_struct *si,
+				   unsigned char usage)
 {
 	unsigned long offset;
 	unsigned long scan_base;
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
