Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 37DCD6B0068
	for <linux-mm@kvack.org>; Sun, 22 Jul 2012 22:31:50 -0400 (EDT)
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Sun, 22 Jul 2012 22:31:49 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 3151338C8046
	for <linux-mm@kvack.org>; Sun, 22 Jul 2012 22:31:47 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6N2Vl2D65011824
	for <linux-mm@kvack.org>; Sun, 22 Jul 2012 22:31:47 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6N2VkNv012005
	for <linux-mm@kvack.org>; Sun, 22 Jul 2012 23:31:46 -0300
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH RESEND v4 2/3] mm/sparse: more check on mem_section number
Date: Mon, 23 Jul 2012 10:31:41 +0800
Message-Id: <1343010702-28720-2-git-send-email-shangw@linux.vnet.ibm.com>
In-Reply-To: <1343010702-28720-1-git-send-email-shangw@linux.vnet.ibm.com>
References: <1343010702-28720-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.cz, rientjes@google.com, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

Function __section_nr() was implemented to retrieve the corresponding
memory section number according to its descriptor. It's possible that
the specified memory section descriptor isn't existing in the global
array. So here to add more check on that and report error for wrong
case.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/sparse.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index d882e88..51950de 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -130,6 +130,8 @@ int __section_nr(struct mem_section* ms)
 		     break;
 	}
 
+	VM_BUG_ON(root_nr == NR_SECTION_ROOTS);
+
 	return (root_nr * SECTIONS_PER_ROOT) + (ms - root);
 }
 
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
