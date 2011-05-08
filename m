Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1540B6B0022
	for <linux-mm@kvack.org>; Sun,  8 May 2011 17:18:48 -0400 (EDT)
Received: by ewy9 with SMTP id 9so2020586ewy.14
        for <linux-mm@kvack.org>; Sun, 08 May 2011 14:18:46 -0700 (PDT)
Date: Mon, 9 May 2011 00:18:34 +0300
From: Maxin B John <maxin.john@gmail.com>
Subject: [PATCH] mm: memory: remove unreachable code
Message-ID: <20110508211834.GA4410@maxin>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, riel@redhat.com, walken@google.com, aarcange@redhat.com, hughd@google.com, linux-mm@kvack.org

Remove the unreachable code found in mm/memory.c

Signed-off-by: Maxin B. John <maxin.john@gmail.com>
---
diff --git a/mm/memory.c b/mm/memory.c
index 27f4253..d3b30af 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3695,7 +3695,6 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 			if (ret <= 0)
 #endif
 				break;
-			bytes = ret;
 		} else {
 			bytes = len;
 			offset = addr & (PAGE_SIZE-1);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
