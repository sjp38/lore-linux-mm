Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8C5456B4D70
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 09:45:56 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id t2so12480646edb.22
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 06:45:56 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id bp5-v6si2577727ejb.40.2018.11.28.06.45.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 06:45:54 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wASEcmJw084749
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 09:45:53 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p1ucr5apy-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 09:45:52 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 28 Nov 2018 14:45:50 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH] docs/core-api: make mm-api.rst more structured
Date: Wed, 28 Nov 2018 16:45:44 +0200
Message-Id: <1543416344-25543-1-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.ibm.com>

The mm-api.rst covers variety of memory management APIs under "More Memory
Management Functions" section. The descriptions included there are in a
random order there are quite a few of them which makes the section too
long.

Regrouping the documentation by subject and splitting the long "More Memory
Management Functions" section into several smaller sections makes the
generated html more usable.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 Documentation/core-api/mm-api.rst | 29 ++++++++++++++++++++---------
 1 file changed, 20 insertions(+), 9 deletions(-)

diff --git a/Documentation/core-api/mm-api.rst b/Documentation/core-api/mm-api.rst
index 5ce1ec1..c81e754 100644
--- a/Documentation/core-api/mm-api.rst
+++ b/Documentation/core-api/mm-api.rst
@@ -49,8 +49,14 @@ The Slab Cache
 .. kernel-doc:: mm/util.c
    :functions: kfree_const kvmalloc_node kvfree
 
-More Memory Management Functions
-================================
+Virtually Contiguous Mappings
+=============================
+
+.. kernel-doc:: mm/vmalloc.c
+   :export:
+
+File Mapping and Page Cache
+===========================
 
 .. kernel-doc:: mm/readahead.c
    :export:
@@ -58,23 +64,28 @@ More Memory Management Functions
 .. kernel-doc:: mm/filemap.c
    :export:
 
-.. kernel-doc:: mm/memory.c
+.. kernel-doc:: mm/page-writeback.c
    :export:
 
-.. kernel-doc:: mm/vmalloc.c
+.. kernel-doc:: mm/truncate.c
    :export:
 
-.. kernel-doc:: mm/page_alloc.c
-   :internal:
+Memory pools
+============
 
 .. kernel-doc:: mm/mempool.c
    :export:
 
+DMA pools
+=========
+
 .. kernel-doc:: mm/dmapool.c
    :export:
 
-.. kernel-doc:: mm/page-writeback.c
-   :export:
+More Memory Management Functions
+================================
 
-.. kernel-doc:: mm/truncate.c
+.. kernel-doc:: mm/memory.c
    :export:
+
+.. kernel-doc:: mm/page_alloc.c
-- 
2.7.4
