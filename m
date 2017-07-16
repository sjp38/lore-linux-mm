Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 78D2E6B0595
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 22:24:37 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e19so10013765pfb.13
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 19:24:37 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id s74si9562036pfa.388.2017.07.15.19.24.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 19:24:36 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH 02/10] percpu: change the format for percpu_stats output
Date: Sat, 15 Jul 2017 22:23:07 -0400
Message-ID: <20170716022315.19892-3-dennisz@fb.com>
In-Reply-To: <20170716022315.19892-1-dennisz@fb.com>
References: <20170716022315.19892-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

This makes the debugfs output for percpu_stats a little easier
to read by changing the spacing of the output to be consistent.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu-stats.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/percpu-stats.c b/mm/percpu-stats.c
index 0d81044..fa0f5de 100644
--- a/mm/percpu-stats.c
+++ b/mm/percpu-stats.c
@@ -18,7 +18,7 @@
 #include "percpu-internal.h"
 
 #define P(X, Y) \
-	seq_printf(m, "  %-24s: %8lld\n", X, (long long int)Y)
+	seq_printf(m, "  %-20s: %12lld\n", X, (long long int)Y)
 
 struct percpu_stats pcpu_stats;
 struct pcpu_alloc_info pcpu_stats_ai;
@@ -134,7 +134,7 @@ static int percpu_stats_show(struct seq_file *m, void *v)
 	}
 
 #define PL(X) \
-	seq_printf(m, "  %-24s: %8lld\n", #X, (long long int)pcpu_stats_ai.X)
+	seq_printf(m, "  %-20s: %12lld\n", #X, (long long int)pcpu_stats_ai.X)
 
 	seq_printf(m,
 			"Percpu Memory Statistics\n"
@@ -151,7 +151,7 @@ static int percpu_stats_show(struct seq_file *m, void *v)
 #undef PL
 
 #define PU(X) \
-	seq_printf(m, "  %-18s: %14llu\n", #X, (unsigned long long)pcpu_stats.X)
+	seq_printf(m, "  %-20s: %12llu\n", #X, (unsigned long long)pcpu_stats.X)
 
 	seq_printf(m,
 			"Global Stats:\n"
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
