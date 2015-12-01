Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id F00D86B0258
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 18:26:09 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so20543603pab.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 15:26:09 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id 8si253279pfj.98.2015.12.01.15.26.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 15:26:04 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so20541562pab.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 15:26:04 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH 5/7] s390: mm/gup: add gup trace points
Date: Tue,  1 Dec 2015 15:06:15 -0800
Message-Id: <1449011177-30686-6-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449011177-30686-1-git-send-email-yang.shi@linaro.org>
References: <1449011177-30686-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org

Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-s390@vger.kernel.org
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 arch/s390/mm/gup.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/arch/s390/mm/gup.c b/arch/s390/mm/gup.c
index 12bbf0e..ac25e28 100644
--- a/arch/s390/mm/gup.c
+++ b/arch/s390/mm/gup.c
@@ -10,6 +10,10 @@
 #include <linux/vmstat.h>
 #include <linux/pagemap.h>
 #include <linux/rwsem.h>
+
+#define CREATE_TRACE_POINTS
+#include <trace/events/gup.h>
+
 #include <asm/pgtable.h>
 
 /*
@@ -188,6 +192,9 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	end = start + len;
 	if ((end <= start) || (end > TASK_SIZE))
 		return 0;
+
+	trace_gup_get_user_pages_fast(start, nr_pages, write, pages);
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
