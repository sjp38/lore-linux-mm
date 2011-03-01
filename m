Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3EC958D0045
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 18:29:02 -0500 (EST)
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCHv2 05/24] sys_swapon: simplify error return from swap_info allocation
Date: Tue,  1 Mar 2011 20:28:29 -0300
Message-Id: <1299022128-6239-6-git-send-email-cesarb@cesarb.net>
In-Reply-To: <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
References: <4D6D7FEA.80800@cesarb.net>
 <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@mgebm.net>
Cc: linux-mm@kvack.org, Cesar Eduardo Barros <cesarb@cesarb.net>

At this point in sys_swapon, there is nothing to free. Return directly
instead of jumping to the cleanup block at the end of the function.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 91ca0f0..8969b37 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1918,10 +1918,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		return -EPERM;
 
 	p = alloc_swap_info();
-	if (IS_ERR(p)) {
-		error = PTR_ERR(p);
-		goto out;
-	}
+	if (IS_ERR(p))
+		return PTR_ERR(p);
 
 	name = getname(specialfile);
 	error = PTR_ERR(name);
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
