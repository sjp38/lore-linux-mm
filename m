Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 712AC6B05AE
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 04:44:23 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y129so43844607pgy.1
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 01:44:23 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k10si20704136pln.365.2017.08.02.01.44.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 01:44:22 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v728hxhQ100809
	for <linux-mm@kvack.org>; Wed, 2 Aug 2017 04:44:22 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c35p419rh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 02 Aug 2017 04:44:21 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 2 Aug 2017 18:44:19 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v728h2P023396584
	for <linux-mm@kvack.org>; Wed, 2 Aug 2017 18:43:02 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v728h2oo030042
	for <linux-mm@kvack.org>; Wed, 2 Aug 2017 18:43:02 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH] sched/autogroup: Fix error reporting inside autogroup_create()
Date: Wed,  2 Aug 2017 14:13:00 +0530
Message-Id: <20170802084300.29487-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: mingo@kernel.org

Its kzalloc() not kmalloc() which has failed earlier. While here
remove a redundant empty line.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 kernel/sched/autogroup.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/kernel/sched/autogroup.c b/kernel/sched/autogroup.c
index da39489..de6d7f4 100644
--- a/kernel/sched/autogroup.c
+++ b/kernel/sched/autogroup.c
@@ -71,7 +71,6 @@ static inline struct autogroup *autogroup_create(void)
 		goto out_fail;
 
 	tg = sched_create_group(&root_task_group);
-
 	if (IS_ERR(tg))
 		goto out_free;
 
@@ -101,7 +100,7 @@ static inline struct autogroup *autogroup_create(void)
 out_fail:
 	if (printk_ratelimit()) {
 		printk(KERN_WARNING "autogroup_create: %s failure.\n",
-			ag ? "sched_create_group()" : "kmalloc()");
+			ag ? "sched_create_group()" : "kzalloc()");
 	}
 
 	return autogroup_kref_get(&autogroup_default);
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
