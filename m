Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id B14BA6B0036
	for <linux-mm@kvack.org>; Sun, 21 Sep 2014 18:05:50 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id w10so3165102pde.28
        for <linux-mm@kvack.org>; Sun, 21 Sep 2014 15:05:50 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id rh5si12091611pbc.189.2014.09.21.15.05.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 21 Sep 2014 15:05:49 -0700 (PDT)
Received: by mail-pa0-f52.google.com with SMTP id hz1so3278851pad.11
        for <linux-mm@kvack.org>; Sun, 21 Sep 2014 15:05:48 -0700 (PDT)
From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] Revert "percpu: free percpu allocation info for uniprocessor system"
Date: Sun, 21 Sep 2014 15:04:53 -0700
Message-Id: <1411337093-683-1-git-send-email-linux@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, Tejun Heo <tj@kernel.org>, Honggang Li <enjoymindful@gmail.com>

This reverts commit 3189eddbcafc ("percpu: free percpu allocation info for
uniprocessor system").

The commit causes a hang with a crisv32 image. This may be an architecture
problem, but at least for now the revert is necessary to be able to boot a
crisv32 image.

Fixes: 3189eddbcafc ("percpu: free percpu allocation info for uniprocessor system")
Cc: Tejun Heo <tj@kernel.org>
Cc: Honggang Li <enjoymindful@gmail.com>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
Resent as non-RFC patch per Tejun's request.

 mm/percpu.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index da997f9..2139e30 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1932,8 +1932,6 @@ void __init setup_per_cpu_areas(void)
 
 	if (pcpu_setup_first_chunk(ai, fc) < 0)
 		panic("Failed to initialize percpu areas.");
-
-	pcpu_free_alloc_info(ai);
 }
 
 #endif	/* CONFIG_SMP */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
