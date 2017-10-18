Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8BF6B025E
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 05:13:38 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u70so3158429pfa.2
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 02:13:38 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id j21si7091843pfh.202.2017.10.18.02.13.36
        for <linux-mm@kvack.org>;
        Wed, 18 Oct 2017 02:13:37 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH 2/2] lockdep: Remove BROKEN flag of LOCKDEP_CROSSRELEASE
Date: Wed, 18 Oct 2017 18:13:26 +0900
Message-Id: <1508318006-2090-2-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1508318006-2090-1-git-send-email-byungchul.park@lge.com>
References: <1508318006-2090-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com

Now the performance regression was fixed, re-enable LOCKDEP_CROSSRELEASE
and LOCKDEP_COMPLETIONS.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 lib/Kconfig.debug | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 5be7bdd..c17cb5d 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1138,8 +1138,8 @@ config PROVE_LOCKING
 	select DEBUG_MUTEXES
 	select DEBUG_RT_MUTEXES if RT_MUTEXES
 	select DEBUG_LOCK_ALLOC
-	select LOCKDEP_CROSSRELEASE if BROKEN
-	select LOCKDEP_COMPLETIONS if BROKEN
+	select LOCKDEP_CROSSRELEASE
+	select LOCKDEP_COMPLETIONS
 	select TRACE_IRQFLAGS
 	default n
 	help
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
