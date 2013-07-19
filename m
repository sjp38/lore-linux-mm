Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id B2C536B0031
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 03:29:10 -0400 (EDT)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MQ600MGNA4BZTP0@mailout2.samsung.com> for linux-mm@kvack.org;
 Fri, 19 Jul 2013 16:29:09 +0900 (KST)
From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH] mm: replace strict_strtoul() with kstrtoul()
Date: Fri, 19 Jul 2013 16:29:07 +0900
Message-id: <001e01ce8451$a7840e70$f68c2b50$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Jingoo Han <jg1.han@samsung.com>

The usage of strict_strtoul() is not preferred, because
strict_strtoul() is obsolete. Thus, kstrtoul() should be
used.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 mm/huge_memory.c |    8 ++++----
 mm/hugetlb.c     |    4 ++--
 mm/kmemleak.c    |    2 +-
 mm/ksm.c         |    6 +++---
 mm/slub.c        |    8 ++++----
 5 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index ed26ccb..f6a75af0 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -422,7 +422,7 @@ static ssize_t scan_sleep_millisecs_store(struct kobject *kobj,
 	unsigned long msecs;
 	int err;
 
-	err = strict_strtoul(buf, 10, &msecs);
+	err = kstrtoul(buf, 10, &msecs);
 	if (err || msecs > UINT_MAX)
 		return -EINVAL;
 
@@ -449,7 +449,7 @@ static ssize_t alloc_sleep_millisecs_store(struct kobject *kobj,
 	unsigned long msecs;
 	int err;
 
-	err = strict_strtoul(buf, 10, &msecs);
+	err = kstrtoul(buf, 10, &msecs);
 	if (err || msecs > UINT_MAX)
 		return -EINVAL;
 
@@ -475,7 +475,7 @@ static ssize_t pages_to_scan_store(struct kobject *kobj,
 	int err;
 	unsigned long pages;
 
-	err = strict_strtoul(buf, 10, &pages);
+	err = kstrtoul(buf, 10, &pages);
 	if (err || !pages || pages > UINT_MAX)
 		return -EINVAL;
 
@@ -543,7 +543,7 @@ static ssize_t khugepaged_max_ptes_none_store(struct kobject *kobj,
 	int err;
 	unsigned long max_ptes_none;
 
-	err = strict_strtoul(buf, 10, &max_ptes_none);
+	err = kstrtoul(buf, 10, &max_ptes_none);
 	if (err || max_ptes_none > HPAGE_PMD_NR-1)
 		return -EINVAL;
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 83aff0a..f9263ec 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1526,7 +1526,7 @@ static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
 	struct hstate *h;
 	NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);
 
-	err = strict_strtoul(buf, 10, &count);
+	err = kstrtoul(buf, 10, &count);
 	if (err)
 		goto out;
 
@@ -1617,7 +1617,7 @@ static ssize_t nr_overcommit_hugepages_store(struct kobject *kobj,
 	if (h->order >= MAX_ORDER)
 		return -EINVAL;
 
-	err = strict_strtoul(buf, 10, &input);
+	err = kstrtoul(buf, 10, &input);
 	if (err)
 		return err;
 
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index c8d7f31..e126b0e 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1639,7 +1639,7 @@ static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
 	else if (strncmp(buf, "scan=", 5) == 0) {
 		unsigned long secs;
 
-		ret = strict_strtoul(buf + 5, 0, &secs);
+		ret = kstrtoul(buf + 5, 0, &secs);
 		if (ret < 0)
 			goto out;
 		stop_scan_thread();
diff --git a/mm/ksm.c b/mm/ksm.c
index b6afe0c..0bea2b2 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2194,7 +2194,7 @@ static ssize_t sleep_millisecs_store(struct kobject *kobj,
 	unsigned long msecs;
 	int err;
 
-	err = strict_strtoul(buf, 10, &msecs);
+	err = kstrtoul(buf, 10, &msecs);
 	if (err || msecs > UINT_MAX)
 		return -EINVAL;
 
@@ -2217,7 +2217,7 @@ static ssize_t pages_to_scan_store(struct kobject *kobj,
 	int err;
 	unsigned long nr_pages;
 
-	err = strict_strtoul(buf, 10, &nr_pages);
+	err = kstrtoul(buf, 10, &nr_pages);
 	if (err || nr_pages > UINT_MAX)
 		return -EINVAL;
 
@@ -2239,7 +2239,7 @@ static ssize_t run_store(struct kobject *kobj, struct kobj_attribute *attr,
 	int err;
 	unsigned long flags;
 
-	err = strict_strtoul(buf, 10, &flags);
+	err = kstrtoul(buf, 10, &flags);
 	if (err || flags > UINT_MAX)
 		return -EINVAL;
 	if (flags > KSM_RUN_UNMERGE)
diff --git a/mm/slub.c b/mm/slub.c
index 59eb122..c54b1a1 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4438,7 +4438,7 @@ static ssize_t order_store(struct kmem_cache *s,
 	unsigned long order;
 	int err;
 
-	err = strict_strtoul(buf, 10, &order);
+	err = kstrtoul(buf, 10, &order);
 	if (err)
 		return err;
 
@@ -4466,7 +4466,7 @@ static ssize_t min_partial_store(struct kmem_cache *s, const char *buf,
 	unsigned long min;
 	int err;
 
-	err = strict_strtoul(buf, 10, &min);
+	err = kstrtoul(buf, 10, &min);
 	if (err)
 		return err;
 
@@ -4486,7 +4486,7 @@ static ssize_t cpu_partial_store(struct kmem_cache *s, const char *buf,
 	unsigned long objects;
 	int err;
 
-	err = strict_strtoul(buf, 10, &objects);
+	err = kstrtoul(buf, 10, &objects);
 	if (err)
 		return err;
 	if (objects && !kmem_cache_has_cpu_partial(s))
@@ -4802,7 +4802,7 @@ static ssize_t remote_node_defrag_ratio_store(struct kmem_cache *s,
 	unsigned long ratio;
 	int err;
 
-	err = strict_strtoul(buf, 10, &ratio);
+	err = kstrtoul(buf, 10, &ratio);
 	if (err)
 		return err;
 
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
