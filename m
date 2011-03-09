Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3B6668D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 19:44:53 -0500 (EST)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH 6/6] proc: enable writing to /proc/pid/mem
Date: Tue,  8 Mar 2011 19:42:23 -0500
Message-Id: <1299631343-4499-7-git-send-email-wilsons@start.ca>
In-Reply-To: <1299631343-4499-1-git-send-email-wilsons@start.ca>
References: <1299631343-4499-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Roland McGrath <roland@redhat.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Stephen Wilson <wilsons@start.ca>

With recent changes there is no longer a security hazard with writing to
/proc/pid/mem.  Remove the #ifdef.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
---
 fs/proc/base.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 5ffc927..41d9c46 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -833,10 +833,6 @@ out_no_task:
 	return ret;
 }
 
-#define mem_write NULL
-
-#ifndef mem_write
-/* This is a security hazard */
 static ssize_t mem_write(struct file * file, const char __user *buf,
 			 size_t count, loff_t *ppos)
 {
@@ -894,7 +890,6 @@ out:
 out_no_task:
 	return copied;
 }
-#endif
 
 loff_t mem_lseek(struct file *file, loff_t offset, int orig)
 {
-- 
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
