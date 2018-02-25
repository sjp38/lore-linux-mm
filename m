Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6BFE66B0007
	for <linux-mm@kvack.org>; Sun, 25 Feb 2018 14:00:08 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id o8so11134229qtg.6
        for <linux-mm@kvack.org>; Sun, 25 Feb 2018 11:00:08 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l65si6465286qkf.332.2018.02.25.11.00.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Feb 2018 11:00:07 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1PIvqli102298
	for <linux-mm@kvack.org>; Sun, 25 Feb 2018 14:00:06 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gbpfc8r1c-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 25 Feb 2018 14:00:06 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sun, 25 Feb 2018 19:00:03 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 1/3] mm/nommu: remove description of alloc_vm_area
Date: Sun, 25 Feb 2018 20:59:49 +0200
In-Reply-To: <1519585191-10180-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1519585191-10180-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1519585191-10180-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, linux-doc <linux-doc@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

The alloc_mm_area in nommu is a stub, but it's description states it
allocates kernel address space.
Remove the description to make the code and the documentation agree.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/nommu.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index ebb6e618dade..4f1cabd07e81 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -457,18 +457,6 @@ void __weak vmalloc_sync_all(void)
 {
 }
 
-/**
- *	alloc_vm_area - allocate a range of kernel address space
- *	@size:		size of the area
- *
- *	Returns:	NULL on failure, vm_struct on success
- *
- *	This function reserves a range of kernel address space, and
- *	allocates pagetables to map that range.  No actual mappings
- *	are created.  If the kernel address space is not shared
- *	between processes, it syncs the pagetable across all
- *	processes.
- */
 struct vm_struct *alloc_vm_area(size_t size, pte_t **ptes)
 {
 	BUG();
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
