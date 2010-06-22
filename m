Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1E0CF6B01C3
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 04:47:21 -0400 (EDT)
Received: by fxm15 with SMTP id 15so2543428fxm.14
        for <linux-mm@kvack.org>; Tue, 22 Jun 2010 01:47:19 -0700 (PDT)
From: Sankar P <sankar.curiosity@gmail.com>
Subject: [PATCH] kmemleak: config-options: Default buffer size for kmemleak
Date: Tue, 22 Jun 2010 14:16:43 +0530
Message-Id: <1277196403-20836-1-git-send-email-sankar.curiosity@gmail.com>
In-Reply-To: <4C20702C.1080405@cs.helsinki.fi>
References: <AANLkTimb7rP0rS0OU8nan5uNEhHx_kEYL99ImZ3c8o0D@mail.gmail.com> <1277189909-16376-1-git-send-email-sankar.curiosity@gmail.com> <4C20702C.1080405@cs.helsinki.fi>
Sender: owner-linux-mm@kvack.org
To: penberg@cs.helsinki.fi
Cc: lethal@linux-sh.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, lrodriguez@atheros.com, catalin.marinas@arm.com, rnagarajan@novell.com, teheo@novell.com, linux-mm@kvack.org, paulmck@linux.vnet.ibm.com, mingo@elte.hu, akpm@linux-foundation.org, Sankar P <sankar.curiosity@gmail.com>
List-ID: <linux-mm.kvack.org>

If we try to find the memory leaks in kernel that is
compiled with 'make defconfig', the default buffer size
of DEBUG_KMEMLEAK_EARLY_LOG_SIZE seem to be inadequate.

Change the buffer size from 400 to 1000,
which is sufficient for most cases.

Signed-off-by: Sankar P <sankar.curiosity@gmail.com>
---

Thanks to Pekka Enberg's comments on my previous mail, I am sending a better patch,
and adding new reviewers as suggested by the get_maintainer script. 

 lib/Kconfig.debug |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index e722e9d..5eb9463 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -382,7 +382,7 @@ config DEBUG_KMEMLEAK_EARLY_LOG_SIZE
 	int "Maximum kmemleak early log entries"
 	depends on DEBUG_KMEMLEAK
 	range 200 40000
-	default 400
+	default 1000
 	help
 	  Kmemleak must track all the memory allocations to avoid
 	  reporting false positives. Since memory may be allocated or
-- 
1.6.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
