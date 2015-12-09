Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 222736B0260
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 12:49:29 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so32971948pac.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 09:49:28 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id qy7si13977760pab.169.2015.12.09.09.49.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 09:49:23 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so33170795pac.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 09:49:23 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH v4 5/7] s390: mm/gup: add gup trace points
Date: Wed,  9 Dec 2015 09:29:22 -0800
Message-Id: <1449682164-9933-6-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449682164-9933-1-git-send-email-yang.shi@linaro.org>
References: <1449682164-9933-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org

Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-s390@vger.kernel.org
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 arch/s390/mm/gup.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/s390/mm/gup.c b/arch/s390/mm/gup.c
index 12bbf0e..0ff7e92 100644
--- a/arch/s390/mm/gup.c
+++ b/arch/s390/mm/gup.c
@@ -12,6 +12,9 @@
 #include <linux/rwsem.h>
 #include <asm/pgtable.h>
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/gup.h>
+
 /*
  * The performance critical leaf functions are made noinline otherwise gcc
  * inlines everything into a single function which results in too much
@@ -188,6 +191,9 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	end = start + len;
 	if ((end <= start) || (end > TASK_SIZE))
 		return 0;
+
+	trace_gup_get_user_pages_fast(start, nr_pages);
+
 	/*
 	 * local_irq_save() doesn't prevent pagetable teardown, but does
 	 * prevent the pagetables from being freed on s390.
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
