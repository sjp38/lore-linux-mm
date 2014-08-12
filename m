Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 53D7A6B0037
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 09:36:30 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so13152462pab.29
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 06:36:29 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id pg6si6621515pbc.176.2014.08.12.06.36.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 12 Aug 2014 06:36:29 -0700 (PDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so13031058pad.13
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 06:36:29 -0700 (PDT)
From: Honggang Li <enjoymindful@gmail.com>
Subject: [PATCH] Free percpu allocation info for uniprocessor system
Date: Tue, 12 Aug 2014 21:36:15 +0800
Message-Id: <1407850575-18794-2-git-send-email-enjoymindful@gmail.com>
In-Reply-To: <1407850575-18794-1-git-send-email-enjoymindful@gmail.com>
References: <1407850575-18794-1-git-send-email-enjoymindful@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, cl@linux-foundation.org, linux-mm@kvack.org, user-mode-linux-devel@lists.sourceforge.net
Cc: linux-kernel@vger.kernel.org, Honggang Li <enjoymindful@gmail.com>

Currently, only SMP system free the percpu allocation info.
Uniprocessor system should free it too. For example, one x86 UML
virtual machine with 256MB memory, UML kernel wastes one page memory.

Signed-off-by: Honggang Li <enjoymindful@gmail.com>
---
 mm/percpu.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/percpu.c b/mm/percpu.c
index 2139e30..da997f9 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1932,6 +1932,8 @@ void __init setup_per_cpu_areas(void)
 
 	if (pcpu_setup_first_chunk(ai, fc) < 0)
 		panic("Failed to initialize percpu areas.");
+
+	pcpu_free_alloc_info(ai);
 }
 
 #endif	/* CONFIG_SMP */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
