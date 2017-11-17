Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id D3C706B0038
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 20:49:39 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id s185so514623oif.16
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 17:49:39 -0800 (PST)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id e76si767095oih.461.2017.11.16.17.49.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Nov 2017 17:49:38 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH v3 1/3] mm/mempolicy: remove redundant check in get_nodes
Date: Fri, 17 Nov 2017 09:37:02 +0800
Message-ID: <1510882624-44342-2-git-send-email-xieyisheng1@huawei.com>
In-Reply-To: <1510882624-44342-1-git-send-email-xieyisheng1@huawei.com>
References: <1510882624-44342-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu, ak@linux.intel.com, cl@linux.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, tanxiaojun@huawei.com

We have already checked whether maxnode is a page worth of bits, by:
    maxnode > PAGE_SIZE*BITS_PER_BYTE

So no need to check it once more.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 mm/mempolicy.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 4ce44d3..6e867a8 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1282,8 +1282,6 @@ static int get_nodes(nodemask_t *nodes, const unsigned long __user *nmask,
 	/* When the user specified more nodes than supported just check
 	   if the non supported part is all zero. */
 	if (nlongs > BITS_TO_LONGS(MAX_NUMNODES)) {
-		if (nlongs > PAGE_SIZE/sizeof(long))
-			return -EINVAL;
 		for (k = BITS_TO_LONGS(MAX_NUMNODES); k < nlongs; k++) {
 			unsigned long t;
 			if (get_user(t, nmask + k))
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
