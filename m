Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id ACC1A6B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 02:32:48 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id eu11so1577927pac.33
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 23:32:48 -0700 (PDT)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id rc6si4725205pab.107.2014.06.18.23.32.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Jun 2014 23:32:47 -0700 (PDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <lilei@linux.vnet.ibm.com>;
	Thu, 19 Jun 2014 12:02:44 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 01D54394005A
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 12:02:40 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5J6XYvZ6684814
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 12:03:35 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s5J6WU1j032703
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 12:02:30 +0530
From: Lei Li <lilei@linux.vnet.ibm.com>
Subject: [PATCH] Documentation: Update remove_from_page_cache with delete_from_page_cache
Date: Thu, 19 Jun 2014 14:32:25 +0800
Message-Id: <1403159545-8029-1-git-send-email-lilei@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, Lei Li <lilei@linux.vnet.ibm.com>

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
