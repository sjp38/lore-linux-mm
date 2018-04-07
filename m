Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 522CE6B0022
	for <linux-mm@kvack.org>; Sat,  7 Apr 2018 14:47:57 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 3so2871897wrb.5
        for <linux-mm@kvack.org>; Sat, 07 Apr 2018 11:47:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n28sor6764255edn.16.2018.04.07.11.47.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 07 Apr 2018 11:47:56 -0700 (PDT)
From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH 2/3] mm: Replace S_IWUSR with 0200
Date: Sat,  7 Apr 2018 19:47:25 +0100
Message-Id: <20180407184726.8634-2-paulmcquad@gmail.com>
In-Reply-To: <20180407184726.8634-1-paulmcquad@gmail.com>
References: <20180407184726.8634-1-paulmcquad@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmcquad@gmail.com
Cc: konrad.wilk@oracle.com, labbott@redhat.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, guptap@codeaurora.org, vbabka@suse.cz, mgorman@techsingularity.net, hannes@cmpxchg.org, rientjes@google.com, mhocko@suse.com, rppt@linux.vnet.ibm.com, dave@stgolabs.net, hmclauchlan@fb.com, tglx@linutronix.de, pombredanne@nexb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Fix checkpatch warnings about S_IWUSR being less readable than
providing the permissions octal as '0200'.

Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
---
 mm/cma_debug.c  | 4 ++--
 mm/compaction.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/cma_debug.c b/mm/cma_debug.c
index 6494c7a7d257..f0af3f93d1e4 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -172,10 +172,10 @@ static void cma_debugfs_add_one(struct cma *cma, int idx)
 
 	tmp = debugfs_create_dir(name, cma_debugfs_root);
 
-	debugfs_create_file("alloc", S_IWUSR, tmp, cma,
+	debugfs_create_file("alloc", 0200, tmp, cma,
 				&cma_alloc_fops);
 
-	debugfs_create_file("free", S_IWUSR, tmp, cma,
+	debugfs_create_file("free", 0200, tmp, cma,
 				&cma_free_fops);
 
 	debugfs_create_file("base_pfn", 0444, tmp,
diff --git a/mm/compaction.c b/mm/compaction.c
index 88d01a50a015..50d0000a6afd 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1900,7 +1900,7 @@ static ssize_t sysfs_compact_node(struct device *dev,
 
 	return count;
 }
-static DEVICE_ATTR(compact, S_IWUSR, NULL, sysfs_compact_node);
+static DEVICE_ATTR(compact, 0200, NULL, sysfs_compact_node);
 
 int compaction_register_node(struct node *node)
 {
-- 
2.16.2
