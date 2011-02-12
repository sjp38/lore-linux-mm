Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9AAE18D003B
	for <linux-mm@kvack.org>; Sat, 12 Feb 2011 13:49:46 -0500 (EST)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-01.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 12 Feb 2011 18:49:42 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 02/24] sys_swapon: remove changelog from function comment
Date: Sat, 12 Feb 2011 16:49:03 -0200
Message-Id: <1297536565-8059-2-git-send-email-cesarb@cesarb.net>
In-Reply-To: <4D56D5F9.8000609@cesarb.net>
References: <4D56D5F9.8000609@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Cesar Eduardo Barros <cesarb@cesarb.net>

Changelogs belong in the git history instead of in the source code.

Also, "The swapon system call" is redundant with
"SYSCALL_DEFINE2(swapon, ...)".

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 69a1f90..0fcbdca 100644
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
