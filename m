Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8665C6B025E
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 06:23:20 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id r18so5408137pgu.9
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 03:23:20 -0700 (PDT)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id 33si4219492plk.751.2017.10.27.03.23.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Oct 2017 03:23:19 -0700 (PDT)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH RFC v2 2/4] mm/mempolicy: remove redundant check in get_nodes
Date: Fri, 27 Oct 2017 18:14:23 +0800
Message-ID: <1509099265-30868-3-git-send-email-xieyisheng1@huawei.com>
In-Reply-To: <1509099265-30868-1-git-send-email-xieyisheng1@huawei.com>
References: <1509099265-30868-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tanxiaojun@huawei.com, linux-api@vger.kernel.org

We have already checked whether maxnode is a page worth of bits, by:
    maxnode > PAGE_SIZE*BITS_PER_BYTE

So no need to check it once more.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 mm/mempolicy.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 613e9d0..3b51bb3 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1280,8 +1280,6 @@ static int get_nodes(nodemask_t *nodes, const unsigned long __user *nmask,
 	/* When the user specified more nodes than supported just check
 	   if the non supported part is all zero. */
 	if (nlongs > BITS_TO_LONGS(MAX_NUMNODES)) {
-		if (nlongs > PAGE_SIZE/sizeof(long))
-			return -EINVAL;
 		for (k = BITS_TO_LONGS(MAX_NUMNODES); k < nlongs; k++) {
 			unsigned long t;
 			if (get_user(t, nmask + k))
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
