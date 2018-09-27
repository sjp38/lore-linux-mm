Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4C6D98E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 13:11:00 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d22-v6so3499983pfn.3
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 10:11:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k20-v6sor537999pgb.17.2018.09.27.10.10.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 10:10:59 -0700 (PDT)
Date: Thu, 27 Sep 2018 22:44:12 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH] mm/filemap.c: Use vmf_error()
Message-ID: <20180927171411.GA23331@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, akpm@linux-foundation.org, jack@suse.cz, mgorman@techsingularity.net, ak@linux.intel.com, jlayton@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

These codes can be replaced with new inline vmf_error().

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 mm/filemap.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 52517f2..7d04d7c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2581,9 +2581,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 	 * system is low on memory, or a problem occurs while trying
 	 * to schedule I/O.
 	 */
-	if (error == -ENOMEM)
-		return VM_FAULT_OOM;
-	return VM_FAULT_SIGBUS;
+	return vmf_error(error);
 
 page_not_uptodate:
 	/*
-- 
1.9.1
