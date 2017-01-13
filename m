Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 31DAD6B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 10:17:32 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 127so125038682pfg.5
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 07:17:32 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id l36si13013927plg.145.2017.01.13.07.17.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 07:17:31 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id b22so8781914pfd.3
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 07:17:31 -0800 (PST)
From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] writeback: use rb_entry()
Date: Fri, 13 Jan 2017 23:17:12 +0800
Message-Id: <671275de093d93ddc7c6f77ddc0d357149691a39.1484306840.git.geliangtang@gmail.com>
In-Reply-To: <5b23d0cb523f4719673a462ab1569ae99084337e.1483685419.git.geliangtang@gmail.com>
References: <5b23d0cb523f4719673a462ab1569ae99084337e.1483685419.git.geliangtang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Jens Axboe <axboe@fb.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Geliang Tang <geliangtang@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

To make the code clearer, use rb_entry() instead of container_of() to
deal with rbtree.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 mm/backing-dev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 3bfed5ab..ffb77a1 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -410,8 +410,8 @@ wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
 
 	while (*node != NULL) {
 		parent = *node;
-		congested = container_of(parent, struct bdi_writeback_congested,
-					 rb_node);
+		congested = rb_entry(parent, struct bdi_writeback_congested,
+				     rb_node);
 		if (congested->blkcg_id < blkcg_id)
 			node = &parent->rb_left;
 		else if (congested->blkcg_id > blkcg_id)
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
