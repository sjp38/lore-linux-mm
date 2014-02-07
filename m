Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id B776A6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 07:01:59 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so3104146pab.3
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 04:01:59 -0800 (PST)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id va10si4825782pbc.128.2014.02.07.04.01.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 04:01:58 -0800 (PST)
Received: by mail-pd0-f182.google.com with SMTP id v10so3089915pde.27
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 04:01:57 -0800 (PST)
Date: Fri, 7 Feb 2014 17:31:52 +0530
From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 1/9] mm: Mark function as static in compaction.c
Message-ID: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, josh@joshtriplett.org

Mark function as static in compaction.c because it is not used outside
this file.

This eliminates the following warning from mm/compaction.c:
mm/compaction.c:1190:9: warning: no previous prototype for a??sysfs_compact_nodea?? [-Wmissing-prototypes

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 mm/compaction.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 805165b..a21f540 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1187,7 +1187,7 @@ int sysctl_extfrag_handler(struct ctl_table *table, int write,
 }
 
 #if defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
-ssize_t sysfs_compact_node(struct device *dev,
+static ssize_t sysfs_compact_node(struct device *dev,
 			struct device_attribute *attr,
 			const char *buf, size_t count)
 {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
