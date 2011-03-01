Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C80CC8D003E
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 18:29:00 -0500 (EST)
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCHv2 02/24] sys_swapon: remove changelog from function comment
Date: Tue,  1 Mar 2011 20:28:26 -0300
Message-Id: <1299022128-6239-3-git-send-email-cesarb@cesarb.net>
In-Reply-To: <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
References: <4D6D7FEA.80800@cesarb.net>
 <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@mgebm.net>
Cc: linux-mm@kvack.org, Cesar Eduardo Barros <cesarb@cesarb.net>

Changelogs belong in the git history instead of in the source code.

Also, "The swapon system call" is redundant with
"SYSCALL_DEFINE2(swapon, ...)".

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 3fe8913..75ee39c 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1844,11 +1844,6 @@ static int __init max_swapfiles_check(void)
 late_initcall(max_swapfiles_check);
 #endif
 
-/*
- * Written 01/25/92 by Simmule Turner, heavily changed by Linus.
- *
- * The swapon system call
- */
 SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 {
 	struct swap_info_struct *p;
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
