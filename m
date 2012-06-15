Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 325D96B0075
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 08:41:45 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 15 Jun 2012 18:11:42 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5FCfR483867028
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 18:11:27 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5FIB0WM024818
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 23:41:02 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V3 1/4] hugeltb: Mark hugelb_max_hstate __read_mostly
Date: Fri, 15 Jun 2012 18:11:19 +0530
Message-Id: <1339764082-1611-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1339764082-1611-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1339764082-1611-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We set this value only during boot.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/hugetlb.h |    2 +-
 mm/hugetlb.c            |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 9650bb1..0f0877e 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -23,7 +23,7 @@ struct hugepage_subpool {
 };
 
 extern spinlock_t hugetlb_lock;
-extern int hugetlb_max_hstate;
+extern int hugetlb_max_hstate __read_mostly;
 #define for_each_hstate(h) \
 	for ((h) = hstates; (h) < &hstates[hugetlb_max_hstate]; (h)++)
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a5a30bf..c57740b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -37,7 +37,7 @@ const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
 static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
 
-int hugetlb_max_hstate;
+int hugetlb_max_hstate __read_mostly;
 unsigned int default_hstate_idx;
 struct hstate hstates[HUGE_MAX_HSTATE];
 
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
