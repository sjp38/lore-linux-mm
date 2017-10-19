Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 553536B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 01:55:35 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p87so4982825pfj.21
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 22:55:35 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id e7si2441047plk.63.2017.10.18.22.55.33
        for <linux-mm@kvack.org>;
        Wed, 18 Oct 2017 22:55:33 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v2 2/3] lockdep: Remove BROKEN flag of LOCKDEP_CROSSRELEASE
Date: Thu, 19 Oct 2017 14:55:30 +0900
Message-Id: <1508392531-11284-3-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>
References: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com

Now the performance regression was fixed, re-enable
CONFIG_LOCKDEP_CROSSRELEASE and CONFIG_LOCKDEP_COMPLETIONS.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 lib/Kconfig.debug | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 90ea784..fe8fceb 100644
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
