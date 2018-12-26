Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 892F38E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 14:43:09 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id k133so20618249ite.4
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 11:43:09 -0800 (PST)
Received: from mta-p5.oit.umn.edu (mta-p5.oit.umn.edu. [134.84.196.205])
        by mx.google.com with ESMTPS id q23si19798666jak.80.2018.12.26.11.43.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 11:43:08 -0800 (PST)
Received: from localhost (unknown [127.0.0.1])
	by mta-p5.oit.umn.edu (Postfix) with ESMTP id DF8A4C4D
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 19:43:07 +0000 (UTC)
Received: from mta-p5.oit.umn.edu ([127.0.0.1])
	by localhost (mta-p5.oit.umn.edu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id m2tCTIzEzPwx for <linux-mm@kvack.org>;
	Wed, 26 Dec 2018 13:43:07 -0600 (CST)
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mta-p5.oit.umn.edu (Postfix) with ESMTPS id B8171C41
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 13:43:07 -0600 (CST)
Received: by mail-io1-f72.google.com with SMTP id r7so433351iom.22
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 11:43:07 -0800 (PST)
From: Aditya Pakki <pakki001@umn.edu>
Subject: [PATCH] mm: compaction.c: Propagate return value upstream
Date: Wed, 26 Dec 2018 13:42:56 -0600
Message-Id: <20181226194257.11038-1-pakki001@umn.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pakki001@umn.edu
Cc: kjlu@umn.edu, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Yang Shi <yang.shi@linux.alibaba.com>, Johannes Weiner <hannes@cmpxchg.org>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In sysctl_extfrag_handler(), proc_dointvec_minmax() can return an
error. The fix propagates the error upstream in case of failure.

Signed-off-by: Aditya Pakki <pakki001@umn.edu>
---
 mm/compaction.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 7c607479de4a..d108974d0867 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1879,9 +1879,7 @@ int sysctl_compaction_handler(struct ctl_table *table, int write,
 int sysctl_extfrag_handler(struct ctl_table *table, int write,
 			void __user *buffer, size_t *length, loff_t *ppos)
 {
-	proc_dointvec_minmax(table, write, buffer, length, ppos);
-
-	return 0;
+	return proc_dointvec_minmax(table, write, buffer, length, ppos);
 }
 
 #if defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
-- 
2.17.1
