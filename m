Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B0C098E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 11:15:20 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id r9so5550101pfb.13
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 08:15:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s16sor50451952pfi.69.2019.01.09.08.15.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 08:15:19 -0800 (PST)
Date: Wed, 9 Jan 2019 21:49:17 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH] include/linux/hmm.h: Convert to use vm_fault_t
Message-ID: <20190109161916.GA23410@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: jglisse@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@infradead.org, dan.j.williams@intel.com

convert to use vm_fault_t type as return type for
fault handler.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 include/linux/hmm.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 66f9ebb..7c5ace3 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -468,7 +468,7 @@ struct hmm_devmem_ops {
 	 * Note that mmap semaphore is held in read mode at least when this
 	 * callback occurs, hence the vma is valid upon callback entry.
 	 */
-	int (*fault)(struct hmm_devmem *devmem,
+	vm_fault_t (*fault)(struct hmm_devmem *devmem,
 		     struct vm_area_struct *vma,
 		     unsigned long addr,
 		     const struct page *page,
-- 
1.9.1
