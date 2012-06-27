Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id E1F4A6B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 13:29:08 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Wed, 27 Jun 2012 11:29:07 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 7321B19D834F
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 16:36:38 +0000 (WET)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5RGaPDo167042
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 10:36:26 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5RGaFaV001564
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 10:36:15 -0600
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH v2 3/3] mm/sparse: more check on mem_section number
Date: Thu, 28 Jun 2012 00:36:08 +0800
Message-Id: <1340814968-2948-3-git-send-email-shangw@linux.vnet.ibm.com>
In-Reply-To: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com>
References: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.cz, dave@linux.vnet.ibm.com, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

Function __section_nr() was implemented to retrieve the corresponding
memory section number according to its descriptor. It's possible that
the specified memory section descriptor isn't existing in the global
array. So here to add more check on that and report error for wrong
case.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
Reviewed-by: Dave Hansen <dave@linux.vnet.ibm.com>
---
 mm/sparse.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/sparse.c b/mm/sparse.c
index a803599..8b8250e 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -149,6 +149,8 @@ int __section_nr(struct mem_section* ms)
 		     break;
 	}
 
+	VM_BUG_ON(root_nr >= NR_SECTION_ROOTS);
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
