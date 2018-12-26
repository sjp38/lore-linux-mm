Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 22AA18E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 14:08:03 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id t13so14707152ioi.3
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 11:08:03 -0800 (PST)
Received: from mta-p5.oit.umn.edu (mta-p5.oit.umn.edu. [134.84.196.205])
        by mx.google.com with ESMTPS id 192si375431its.82.2018.12.26.11.08.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 11:08:02 -0800 (PST)
Received: from localhost (unknown [127.0.0.1])
	by mta-p5.oit.umn.edu (Postfix) with ESMTP id 956E49CF
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 19:08:01 +0000 (UTC)
Received: from mta-p5.oit.umn.edu ([127.0.0.1])
	by localhost (mta-p5.oit.umn.edu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id JZfqyYiBj4sX for <linux-mm@kvack.org>;
	Wed, 26 Dec 2018 13:08:01 -0600 (CST)
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mta-p5.oit.umn.edu (Postfix) with ESMTPS id 5E6A5A00
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 13:08:01 -0600 (CST)
Received: by mail-io1-f70.google.com with SMTP id r65so19857212iod.12
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 11:08:01 -0800 (PST)
From: Aditya Pakki <pakki001@umn.edu>
Subject: [PATCH] mm: compaction.c: Propagate return value upstream
Date: Wed, 26 Dec 2018 13:07:49 -0600
Message-Id: <20181226190750.9820-1-pakki001@umn.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pakki001@umn.edu
Cc: kjlu@umn.edu, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Yang Shi <yang.shi@linux.alibaba.com>, Johannes Weiner <hannes@cmpxchg.org>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In sysctl_extfrag_handler(), proc_dointvec_minmax() can return an
error. The fix propagates the error upstream in case of failure.

Signed-off-by: Aditya Pakki <pakki001@umn.edu>
---
 mm/compaction.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 7c607479de4a..5703b4051796 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1879,9 +1879,8 @@ int sysctl_compaction_handler(struct ctl_table *table, int write,
 int sysctl_extfrag_handler(struct ctl_table *table, int write,
 			void __user *buffer, size_t *length, loff_t *ppos)
 {
+	return
 	proc_dointvec_minmax(table, write, buffer, length, ppos);
-
-	return 0;
 }
 
 #if defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
-- 
2.17.1
