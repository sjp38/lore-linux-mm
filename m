Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 5C3956B00A9
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 04:18:16 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so504670pbb.14
        for <linux-mm@kvack.org>; Tue, 11 Sep 2012 01:18:15 -0700 (PDT)
From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/1] mm/hugetlb.c: Remove duplicate inclusion of header file
Date: Tue, 11 Sep 2012 13:45:12 +0530
Message-Id: <1347351312-25126-1-git-send-email-sachin.kamat@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sachin.kamat@linaro.org, Andrew Morton <akpm@linux-foundation.org>

linux/hugetlb_cgroup.h was included twice.

Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 mm/hugetlb.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c1c695c..9795e8a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -30,7 +30,6 @@
 #include <linux/hugetlb.h>
 #include <linux/hugetlb_cgroup.h>
 #include <linux/node.h>
-#include <linux/hugetlb_cgroup.h>
 #include "internal.h"
 
 const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
