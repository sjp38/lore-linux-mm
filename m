Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id ED3456B02C8
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 11:54:11 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Sat, 23 Jun 2012 11:54:11 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 6960238C8052
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 11:53:03 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5NFr3DG176366
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 11:53:03 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5NFr2YL012622
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 12:53:03 -0300
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH 5/5] mm/sparse: return 0 if root mem_section exists
Date: Sat, 23 Jun 2012 23:52:56 +0800
Message-Id: <1340466776-4976-5-git-send-email-shangw@linux.vnet.ibm.com>
In-Reply-To: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
References: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

Function sparse_index_init() is used to setup memory section descriptors
dynamically. zero should be returned while mem_section[root] already has
been allocated.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 mm/sparse.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index a8b99d3..e845a48 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -109,8 +109,12 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
 	struct mem_section *section;
 	int ret = 0;
 
+	/*
+	 * If the corresponding mem_section descriptor
+	 * has been created, we needn't bother
+	 */
 	if (mem_section[root])
-		return -EEXIST;
+		return ret;
 
 	section = sparse_index_alloc(nid);
 	if (!section)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
