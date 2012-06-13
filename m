Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 5F8786B0083
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 07:33:01 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 13 Jun 2012 11:12:18 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5DBWoS553018830
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 21:32:51 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5DBWnZa002180
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 21:32:50 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V9 10/15] hugetlb/cgroup: Add the cgroup pointer to page lru
In-Reply-To: <1339583254-895-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1339583254-895-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339583254-895-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Date: Wed, 13 Jun 2012 17:02:47 +0530
Message-ID: <8762avo3a8.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org


Need this patch for hugetlb cgroup disabled. I will send an updated patch in
reply.

diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
index e9e6d74..bc30413 100644
--- a/include/linux/hugetlb_cgroup.h
+++ b/include/linux/hugetlb_cgroup.h
@@ -18,14 +18,14 @@
 #include <linux/res_counter.h>
 
 struct hugetlb_cgroup;
-
-#ifdef CONFIG_CGROUP_HUGETLB_RES_CTLR
 /*
  * Minimum page order trackable by hugetlb cgroup.
  * At least 3 pages are necessary for all the tracking information.
  */
 #define HUGETLB_CGROUP_MIN_ORDER	2
 
+#ifdef CONFIG_CGROUP_HUGETLB_RES_CTLR
+
 static inline struct hugetlb_cgroup *hugetlb_cgroup_from_page(struct page *page)
 {
 	VM_BUG_ON(!PageHuge(page));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
