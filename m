Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7047E6B025F
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 04:56:33 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id f85so20433301pfe.7
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 01:56:33 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id a22si1353915plm.225.2017.10.25.01.56.31
        for <linux-mm@kvack.org>;
        Wed, 25 Oct 2017 01:56:32 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v5 5/9] locking/lockdep: Remove the BROKEN flag from CONFIG_LOCKDEP_CROSSRELEASE and CONFIG_LOCKDEP_COMPLETIONS
Date: Wed, 25 Oct 2017 17:56:01 +0900
Message-Id: <1508921765-15396-6-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1508921765-15396-1-git-send-email-byungchul.park@lge.com>
References: <1508921765-15396-1-git-send-email-byungchul.park@lge.com>
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
