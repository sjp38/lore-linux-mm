Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E31EB600374
	for <linux-mm@kvack.org>; Wed,  5 May 2010 07:22:12 -0400 (EDT)
From: Phil Carmody <ext-phil.2.carmody@nokia.com>
Subject: [PATCH 2/2] mm: memcontrol - uninitialised return value
Date: Wed,  5 May 2010 14:21:49 +0300
Message-Id: <1273058509-16625-2-git-send-email-ext-phil.2.carmody@nokia.com>
In-Reply-To: <1273058509-16625-1-git-send-email-ext-phil.2.carmody@nokia.com>
References: <1273058509-16625-1-git-send-email-ext-phil.2.carmody@nokia.com>
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, kamezawa.hiroyu@jp.fujitsu.com
Cc: akpm@linux-foundation.org, kirill@shutemov.name, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: Phil Carmody <ext-phil.2.carmody@nokia.com>

Only an out of memory error will cause ret to be set.

Acked-by: Kirill A. Shutemov <kirill@shutemov.name>
Signed-off-by: Phil Carmody <ext-phil.2.carmody@nokia.com>
---
 mm/memcontrol.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 90e32b2..09af773 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3464,7 +3464,7 @@ static int mem_cgroup_unregister_event(struct cgroup *cgrp, struct cftype *cft,
 	int type = MEMFILE_TYPE(cft->private);
 	u64 usage;
 	int size = 0;
-	int i, j, ret;
+	int i, j, ret = 0;
 
 	mutex_lock(&memcg->thresholds_lock);
 	if (type == _MEM)
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
