Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id EB4D0122E5
	for <linux-mm@kvack.org>; Fri,  8 Jun 2007 22:07:43 +0200 (CEST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 11 of 16] the oom schedule timeout isn't needed with the
	VM_is_OOM logic
Message-Id: <c6dfb528f53eaac2188b.1181332989@v2.random>
In-Reply-To: <patchbomb.1181332978@v2.random>
Date: Fri, 08 Jun 2007 22:03:09 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1181332962 -7200
# Node ID c6dfb528f53eaac2188b49f67eed51c1a33ce7cd
# Parent  24250f0be1aa26e5c6e33fd97b9eae125db9fbde
the oom schedule timeout isn't needed with the VM_is_OOM logic

VM_is_OOM whole point is to give a proper time to the TIF_MEMDIE task
in order to exit.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -468,12 +468,5 @@ out:
 	read_unlock(&tasklist_lock);
 	cpuset_unlock();
 
-	/*
-	 * Give "p" a good chance of killing itself before we
-	 * retry to allocate memory unless "p" is current
-	 */
-	if (!test_thread_flag(TIF_MEMDIE))
-		schedule_timeout_uninterruptible(1);
-
 	up(&OOM_lock);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
