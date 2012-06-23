Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id D3AF46B02C7
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 11:54:11 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Sat, 23 Jun 2012 11:54:10 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 841BA38C801C
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 11:53:02 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5NFr2rA207084
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 11:53:02 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5NFr1n2015020
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 09:53:01 -0600
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH 4/5] mm/sparse: more check on mem_section number
Date: Sat, 23 Jun 2012 23:52:55 +0800
Message-Id: <1340466776-4976-4-git-send-email-shangw@linux.vnet.ibm.com>
In-Reply-To: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
References: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

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
index bae8f2d..a8b99d3 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -160,6 +160,8 @@ int __section_nr(struct mem_section* ms)
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
