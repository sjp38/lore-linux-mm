Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 689386B0068
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 05:29:42 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Mon, 2 Jul 2012 03:29:41 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q629TJrp266508
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 03:29:19 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q629TI2I029644
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 03:29:18 -0600
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH v3 3/3] mm/sparse: more check on mem_section number
Date: Mon,  2 Jul 2012 17:28:57 +0800
Message-Id: <1341221337-4826-3-git-send-email-shangw@linux.vnet.ibm.com>
In-Reply-To: <1341221337-4826-1-git-send-email-shangw@linux.vnet.ibm.com>
References: <1341221337-4826-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dave@linux.vnet.ibm.com, mhocko@suse.cz, rientjes@google.com, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

Function __section_nr() was implemented to retrieve the corresponding
memory section number according to its descriptor. It's possible that
the specified memory section descriptor isn't existing in the global
array. So here to add more check on that and report error for wrong
case.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 mm/sparse.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/sparse.c b/mm/sparse.c
index a6984d9..f2525fd 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -147,6 +147,8 @@ int __section_nr(struct mem_section* ms)
 		     break;
 	}
 
+	VM_BUG_ON(root_nr == NR_SECTION_ROOTS);
+
 	return (root_nr * SECTIONS_PER_ROOT) + (ms - root);
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
