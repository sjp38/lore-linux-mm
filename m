Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id C420D6B0068
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 21:57:09 -0400 (EDT)
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@shangw.pok.ibm.com>;
	Thu, 12 Jul 2012 21:57:08 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 0A0AE6E804D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 21:56:39 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6D1ucDZ427378
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 21:56:38 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6D1ubLb008507
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 19:56:38 -0600
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH v4 RESEND 2/3] mm/sparse: more check on mem_section number
Date: Fri, 13 Jul 2012 10:01:21 +0800
Message-Id: <1342144882-16856-2-git-send-email-shangw@linux.vnet.ibm.com>
In-Reply-To: <1342144882-16856-1-git-send-email-shangw@linux.vnet.ibm.com>
References: <1342144882-16856-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

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
