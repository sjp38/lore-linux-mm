Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id B6EBC82F76
	for <linux-mm@kvack.org>; Sun,  1 Nov 2015 02:46:41 -0500 (EST)
Received: by pacfv9 with SMTP id fv9so120445535pac.3
        for <linux-mm@kvack.org>; Sun, 01 Nov 2015 00:46:41 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id ug9si12716293pab.185.2015.11.01.00.46.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Nov 2015 00:46:41 -0700 (PDT)
Received: by padhy1 with SMTP id hy1so109577791pad.0
        for <linux-mm@kvack.org>; Sun, 01 Nov 2015 00:46:41 -0700 (PDT)
From: Jungseok Lee <jungseoklee85@gmail.com>
Subject: [PATCH v6 1/3] percpu: remove PERCPU_ENOUGH_ROOM which is stale definition
Date: Sun,  1 Nov 2015 07:46:15 +0000
Message-Id: <1446363977-23656-2-git-send-email-jungseoklee85@gmail.com>
In-Reply-To: <1446363977-23656-1-git-send-email-jungseoklee85@gmail.com>
References: <1446363977-23656-1-git-send-email-jungseoklee85@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, will.deacon@arm.com, cl@linux.com, tj@kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: james.morse@arm.com, takahiro.akashi@linaro.org, mark.rutland@arm.com, barami97@gmail.com, linux-kernel@vger.kernel.org

As pure cleanup, this patch removes PERCPU_ENOUGH_ROOM which is not
used any more. That is, no code refers to the definition.

Signed-off-by: Jungseok Lee <jungseoklee85@gmail.com>
---
 include/linux/percpu.h | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/include/linux/percpu.h b/include/linux/percpu.h
index caebf2a..4bc6daf 100644
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -18,12 +18,6 @@
 #define PERCPU_MODULE_RESERVE		0
 #endif
 
-#ifndef PERCPU_ENOUGH_ROOM
-#define PERCPU_ENOUGH_ROOM						\
-	(ALIGN(__per_cpu_end - __per_cpu_start, SMP_CACHE_BYTES) +	\
-	 PERCPU_MODULE_RESERVE)
-#endif
-
 /* minimum unit size, also is the maximum supported allocation size */
 #define PCPU_MIN_UNIT_SIZE		PFN_ALIGN(32 << 10)
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
