Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9CD2B6B0069
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 04:56:31 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z80so20425553pff.11
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 01:56:31 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id l124si1695191pfc.134.2017.10.25.01.56.29
        for <linux-mm@kvack.org>;
        Wed, 25 Oct 2017 01:56:30 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v5 2/9] locking/lockdep: Provide empty lockdep_map structure for !CONFIG_LOCKDEP
Date: Wed, 25 Oct 2017 17:55:58 +0900
Message-Id: <1508921765-15396-3-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1508921765-15396-1-git-send-email-byungchul.park@lge.com>
References: <1508921765-15396-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org, axboe@kernel.dk
Cc: johan@kernel.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com

By this patch, the lockdep_map structure takes no space if lockdep is
disabled, making a debug facility's impact on unreleated kernel less.

Thanks to this, we don't need #ifdef to sparate code due to the
lockdep_map structure.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/lockdep.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index bfa8e0b..b6662d0 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -527,6 +527,11 @@ static inline void lockdep_on(void)
  */
 struct lock_class_key { };
 
+/*
+ * The lockdep_map takes no space if lockdep is disabled:
+ */
+struct lockdep_map { };
+
 #define lockdep_depth(tsk)	(0)
 
 #define lockdep_is_held_type(l, r)		(1)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
