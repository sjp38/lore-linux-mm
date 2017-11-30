Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 168B36B025F
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 17:15:20 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id e70so84714wmc.6
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 14:15:20 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z10si3820855wmz.216.2017.11.30.14.15.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 14:15:17 -0800 (PST)
Date: Thu, 30 Nov 2017 14:15:15 -0800
From: akpm@linux-foundation.org
Subject: [patch 02/15] mm/mempolicy: remove redundant check in get_nodes
Message-ID: <5a2082f3.ZGCBhOC+u3Lpp7vR%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, xieyisheng1@huawei.com, ak@linux.intel.com, cl@linux.com, mingo@kernel.org, n-horiguchi@ah.jp.nec.com, rientjes@google.com, salls@cs.ucsb.edu, tanxiaojun@huawei.com, vbabka@suse.cz

From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: mm/mempolicy: remove redundant check in get_nodes

We have already checked whether maxnode is a page worth of bits, by:
    maxnode > PAGE_SIZE*BITS_PER_BYTE

So no need to check it once more.

Link: http://lkml.kernel.org/r/1510882624-44342-2-git-send-email-xieyisheng1@huawei.com
Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: David Rientjes <rientjes@google.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Chris Salls <salls@cs.ucsb.edu>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: Christopher Lameter <cl@linux.com>
Cc: Tan Xiaojun <tanxiaojun@huawei.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/mempolicy.c |    2 --
 1 file changed, 2 deletions(-)

diff -puN mm/mempolicy.c~mm-mempolicy-remove-redundant-check-in-get_nodes mm/mempolicy.c
--- a/mm/mempolicy.c~mm-mempolicy-remove-redundant-check-in-get_nodes
+++ a/mm/mempolicy.c
@@ -1282,8 +1282,6 @@ static int get_nodes(nodemask_t *nodes,
 	/* When the user specified more nodes than supported just check
 	   if the non supported part is all zero. */
 	if (nlongs > BITS_TO_LONGS(MAX_NUMNODES)) {
-		if (nlongs > PAGE_SIZE/sizeof(long))
-			return -EINVAL;
 		for (k = BITS_TO_LONGS(MAX_NUMNODES); k < nlongs; k++) {
 			unsigned long t;
 			if (get_user(t, nmask + k))
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
