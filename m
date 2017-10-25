Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1A5C86B0253
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 01:11:41 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id l23so16169166pgc.10
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 22:11:41 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id p82si1414472pfi.86.2017.10.24.22.11.39
        for <linux-mm@kvack.org>;
        Tue, 24 Oct 2017 22:11:39 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v4 3/7] locking/lockdep: Remove the BROKEN flag from CONFIG_LOCKDEP_CROSSRELEASE and CONFIG_LOCKDEP_COMPLETIONS
Date: Wed, 25 Oct 2017 14:11:08 +0900
Message-Id: <1508908272-15757-4-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1508908272-15757-1-git-send-email-byungchul.park@lge.com>
References: <1508908272-15757-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org, axboe@kernel.dk
Cc: johan@kernel.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com

Now that the performance regression is fixed, re-enable
CONFIG_LOCKDEP_CROSSRELEASE=y and CONFIG_LOCKDEP_COMPLETIONS=y.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 lib/Kconfig.debug | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 3db9167..4bef610 100644
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
