Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id E818F6B0035
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 05:11:36 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so5625467pab.15
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 02:11:36 -0700 (PDT)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [122.248.162.2])
        by mx.google.com with ESMTPS id ew3si20993803pac.229.2014.06.23.02.11.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 02:11:36 -0700 (PDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <lilei@linux.vnet.ibm.com>;
	Mon, 23 Jun 2014 14:41:32 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id C23081258054
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 14:40:59 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5N9CbQK44630040
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 14:42:38 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s5N9BQw0009158
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 14:41:26 +0530
From: Lei Li <lilei@linux.vnet.ibm.com>
Subject: [PATCH] Documentation: Update remove_from_page_cache with delete_from_page_cache
Date: Mon, 23 Jun 2014 17:11:19 +0800
Message-Id: <1403514679-24632-1-git-send-email-lilei@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org.linux-kernel@vger.kernel.org.cgroups"@vger.kernel.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, tj@kernel.org, akpm@linux-foundation.org, Lei Li <lilei@linux.vnet.ibm.com>

remove_from_page_cache has been renamed to delete_from_page_cache
since Commit 702cfbf9 ("mm: goodbye remove_from_page_cache()"), adapt
to it in Memcg documentation.

Signed-off-by: Lei Li <lilei@linux.vnet.ibm.com>
---
 Documentation/cgroups/memcg_test.txt | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/cgroups/memcg_test.txt b/Documentation/cgroups/memcg_test.txt
index 80ac454..b2d6ccc 100644
--- a/Documentation/cgroups/memcg_test.txt
+++ b/Documentation/cgroups/memcg_test.txt
@@ -171,10 +171,10 @@ Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
 	- add_to_page_cache_locked().
 
 	uncharged at
-	- __remove_from_page_cache().
+	- __delete_from_page_cache().
 
 	The logic is very clear. (About migration, see below)
-	Note: __remove_from_page_cache() is called by remove_from_page_cache()
+	Note: __delete_from_page_cache() is called by delete_from_page_cache()
 	and __remove_mapping().
 
 6. Shmem(tmpfs) Page Cache
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
