Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CBC7E6B000C
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:19 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z69-v6so12333916wrb.20
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 10:00:19 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v8-v6si13110091wrm.205.2018.06.18.10.00.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 10:00:18 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5IGwrZY124582
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:17 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2jpfw3299n-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:16 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 18 Jun 2018 18:00:15 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 04/11] docs/mm: bootmem: add kernel-doc description of 'struct bootmem_data'
Date: Mon, 18 Jun 2018 19:59:52 +0300
In-Reply-To: <1529341199-17682-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1529341199-17682-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1529341199-17682-5-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 include/linux/bootmem.h | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 7942a96..1526ba1 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -27,9 +27,20 @@ extern unsigned long max_pfn;
 extern unsigned long long max_possible_pfn;
 
 #ifndef CONFIG_NO_BOOTMEM
-/*
- * node_bootmem_map is a map pointer - the bits represent all physical 
- * memory pages (including holes) on the node.
+/**
+ * struct bootmem_data - per-node information used by the bootmem allocator
+ * @node_min_pfn: the starting physical address of the node's memory
+ * @node_low_pfn: the end physical address of the directly addressable memory
+ * @node_bootmem_map: is a bitmap pointer - the bits represent all physical
+ *		     memory pages (including holes) on the node.
+ * @last_end_off: the offset within the page of the end of the last allocation;
+ *                if 0, the page used is full
+ * @hint_idx: the the PFN of the page used with the last allocation;
+ *	       together with using this with the @last_end_offset field,
+ *	       a test can be made to see if allocations can be merged
+ *	       with the page used for the last allocation rather than
+ *	       using up a full new page.
+ * @list: list entry in the linked list ordered by the memory addresses
  */
 typedef struct bootmem_data {
 	unsigned long node_min_pfn;
-- 
2.7.4
