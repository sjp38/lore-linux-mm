Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id EDC296B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 05:17:55 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id un15so2876pbc.27
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 02:17:55 -0700 (PDT)
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com. [202.81.31.146])
        by mx.google.com with ESMTPS id td4si25370060pac.62.2014.06.24.02.17.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 02:17:55 -0700 (PDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <lilei@linux.vnet.ibm.com>;
	Tue, 24 Jun 2014 19:17:50 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 298BD357804F
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 19:17:49 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5O8tUKS9503118
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 18:55:32 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s5O9HkiN032338
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 19:17:46 +1000
From: Lei Li <lilei@linux.vnet.ibm.com>
Subject: [PATCH] Documentation: remove remove_from_page_cache note
Date: Tue, 24 Jun 2014 17:17:42 +0800
Message-Id: <1403601462-32167-1-git-send-email-lilei@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lei Li <lilei@linux.vnet.ibm.com>

Remove this note as remove_from_page_cache has been renamed to
delete_from_page_cache since Commit 702cfbf9 ("mm: goodbye
remove_from_page_cache()"), and it doesn't serve any useful
purpose.

Signed-off-by: Lei Li <lilei@linux.vnet.ibm.com>
---
 Documentation/cgroups/memcg_test.txt | 2 --
 1 file changed, 2 deletions(-)

diff --git a/Documentation/cgroups/memcg_test.txt b/Documentation/cgroups/memcg_test.txt
index 8870b02..67c11a3 100644
--- a/Documentation/cgroups/memcg_test.txt
+++ b/Documentation/cgroups/memcg_test.txt
@@ -82,8 +82,6 @@ Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
 	- add_to_page_cache_locked().
 
 	The logic is very clear. (About migration, see below)
-	Note: __remove_from_page_cache() is called by remove_from_page_cache()
-	and __remove_mapping().
 
 6. Shmem(tmpfs) Page Cache
 	The best way to understand shmem's page state transition is to read
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
