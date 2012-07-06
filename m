Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 1E9B56B0075
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 23:10:00 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Thu, 5 Jul 2012 21:09:59 -0600
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 4AE30C90068
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 23:09:45 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6639iAG1835510
	for <linux-mm@kvack.org>; Thu, 5 Jul 2012 23:09:44 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6639iPM010153
	for <linux-mm@kvack.org>; Thu, 5 Jul 2012 23:09:44 -0400
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH v4 2/3] mm/sparse: more check on mem_section number
Date: Fri,  6 Jul 2012 11:09:37 +0800
Message-Id: <1341544178-7245-2-git-send-email-shangw@linux.vnet.ibm.com>
In-Reply-To: <1341544178-7245-1-git-send-email-shangw@linux.vnet.ibm.com>
References: <1341544178-7245-1-git-send-email-shangw@linux.vnet.ibm.com>
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
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/sparse.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/sparse.c b/mm/sparse.c
index 781fa04..8b8edfb 100644
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
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
