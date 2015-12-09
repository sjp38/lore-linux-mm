Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id AD0066B0258
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 16:42:31 -0500 (EST)
Received: by pfu207 with SMTP id 207so36188948pfu.2
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 13:42:31 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id 17si15089641pfo.238.2015.12.09.13.42.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 13:42:26 -0800 (PST)
Received: by pabur14 with SMTP id ur14so35923186pab.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 13:42:26 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH v5 5/7] s390: mm/gup: add gup trace points
Date: Wed,  9 Dec 2015 13:22:29 -0800
Message-Id: <1449696151-4195-6-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449696151-4195-1-git-send-email-yang.shi@linaro.org>
References: <1449696151-4195-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org

Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-s390@vger.kernel.org
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 arch/s390/mm/gup.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/s390/mm/gup.c b/arch/s390/mm/gup.c
index 12bbf0e..a1d5db7 100644
--- a/arch/s390/mm/gup.c
+++ b/arch/s390/mm/gup.c
@@ -12,6 +12,8 @@
 #include <linux/rwsem.h>
 #include <asm/pgtable.h>
 
+#include <trace/events/gup.h>
+
 /*
  * The performance critical leaf functions are made noinline otherwise gcc
  * inlines everything into a single function which results in too much
@@ -188,6 +190,9 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
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
