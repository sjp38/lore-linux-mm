Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 62C116B0290
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:47 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 2 May 2013 20:01:46 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 439B56E8054
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:40 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4301h3U326842
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:43 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4301g8V012958
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:43 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 27/31] mm/memory_hotplug: VM_BUG if nid is too large.
Date: Thu,  2 May 2013 17:00:59 -0700
Message-Id: <1367539263-19999-28-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/memory_hotplug.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 8e6658d..320d914 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1071,6 +1071,8 @@ int __mem_online_node(int nid)
 	pg_data_t *pgdat;
 	int ret;
 
+	VM_BUG_ON(nid >= nr_node_ids);
+
 	pgdat = hotadd_new_pgdat(nid, 0);
 	if (!pgdat)
 		return -ENOMEM;
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
