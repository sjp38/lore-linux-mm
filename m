Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 2005E6B0073
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 09:45:21 -0500 (EST)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <jfrei@linux.vnet.ibm.com>;
	Tue, 11 Dec 2012 14:45:06 -0000
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qBBEj6BB21168154
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 14:45:07 GMT
Received: from d06av10.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qBBDmuFi028783
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 08:48:57 -0500
From: dingel@linux.vnet.ibm.com
Subject: [PATCH] remove unused code from do_wp_page
Date: Tue, 11 Dec 2012 15:44:50 +0100
Message-Id: <1355237090-52434-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dominik Dingel <dingel@linux.vnet.ibm.com>

From: Dominik Dingel <dingel@linux.vnet.ibm.com>

page_mkwrite is initalized with zero and only set once, from that point exists no way to get to the oom or oom_free_new labels.

Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 mm/memory.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 221fc9f..c322708 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2795,10 +2795,6 @@ oom_free_new:
 	page_cache_release(new_page);
 oom:
 	if (old_page) {
-		if (page_mkwrite) {
-			unlock_page(old_page);
-			page_cache_release(old_page);
-		}
 		page_cache_release(old_page);
 	}
 	return VM_FAULT_OOM;
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
