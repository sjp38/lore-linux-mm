Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id B1E316B028E
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:26:33 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id j5-v6so7232417oiw.13
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 04:26:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r3-v6si9674326oig.150.2018.07.25.04.26.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 04:26:32 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6PBOGcl082846
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:26:32 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kep26pcpd-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:26:31 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 25 Jul 2018 12:26:29 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 5/7] docs/core-api: split memory management API to a separate file
Date: Wed, 25 Jul 2018 14:26:08 +0300
In-Reply-To: <1532517970-16409-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1532517970-16409-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1532517970-16409-6-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/core-api/index.rst      |  1 +
 Documentation/core-api/kernel-api.rst | 54 -----------------------------------
 Documentation/core-api/mm-api.rst     | 54 +++++++++++++++++++++++++++++++++++
 3 files changed, 55 insertions(+), 54 deletions(-)
 create mode 100644 Documentation/core-api/mm-api.rst

diff --git a/Documentation/core-api/index.rst b/Documentation/core-api/index.rst
index f5a66b7..b580204 100644
--- a/Documentation/core-api/index.rst
+++ b/Documentation/core-api/index.rst
@@ -27,6 +27,7 @@ Core utilities
    errseq
    printk-formats
    circular-buffers
+   mm-api
    gfp_mask-from-fs-io
 
 Interfaces for kernel debugging
diff --git a/Documentation/core-api/kernel-api.rst b/Documentation/core-api/kernel-api.rst
index 39f1460..3431337 100644
--- a/Documentation/core-api/kernel-api.rst
+++ b/Documentation/core-api/kernel-api.rst
@@ -159,60 +159,6 @@ UUID/GUID
 .. kernel-doc:: lib/uuid.c
    :export:
 
-Memory Management in Linux
-==========================
-
-The Slab Cache
---------------
-
-.. kernel-doc:: include/linux/slab.h
-   :internal:
-
-.. kernel-doc:: mm/slab.c
-   :export:
-
-.. kernel-doc:: mm/util.c
-   :functions: kfree_const kvmalloc_node kvfree get_user_pages_fast
-
-User Space Memory Access
-------------------------
-
-.. kernel-doc:: arch/x86/include/asm/uaccess.h
-   :internal:
-
-.. kernel-doc:: arch/x86/lib/usercopy_32.c
-   :export:
-
-More Memory Management Functions
---------------------------------
-
-.. kernel-doc:: mm/readahead.c
-   :export:
-
-.. kernel-doc:: mm/filemap.c
-   :export:
-
-.. kernel-doc:: mm/memory.c
-   :export:
-
-.. kernel-doc:: mm/vmalloc.c
-   :export:
-
-.. kernel-doc:: mm/page_alloc.c
-   :internal:
-
-.. kernel-doc:: mm/mempool.c
-   :export:
-
-.. kernel-doc:: mm/dmapool.c
-   :export:
-
-.. kernel-doc:: mm/page-writeback.c
-   :export:
-
-.. kernel-doc:: mm/truncate.c
-   :export:
-
 Kernel IPC facilities
 =====================
 
diff --git a/Documentation/core-api/mm-api.rst b/Documentation/core-api/mm-api.rst
new file mode 100644
index 0000000..65a8ef09
--- /dev/null
+++ b/Documentation/core-api/mm-api.rst
@@ -0,0 +1,54 @@
+======================
+Memory Management APIs
+======================
+
+User Space Memory Access
+========================
+
+.. kernel-doc:: arch/x86/include/asm/uaccess.h
+   :internal:
+
+.. kernel-doc:: arch/x86/lib/usercopy_32.c
+   :export:
+
+The Slab Cache
+==============
+
+.. kernel-doc:: include/linux/slab.h
+   :internal:
+
+.. kernel-doc:: mm/slab.c
+   :export:
+
+.. kernel-doc:: mm/util.c
+   :functions: kfree_const kvmalloc_node kvfree get_user_pages_fast
+
+More Memory Management Functions
+================================
+
+.. kernel-doc:: mm/readahead.c
+   :export:
+
+.. kernel-doc:: mm/filemap.c
+   :export:
+
+.. kernel-doc:: mm/memory.c
+   :export:
+
+.. kernel-doc:: mm/vmalloc.c
+   :export:
+
+.. kernel-doc:: mm/page_alloc.c
+   :internal:
+
+.. kernel-doc:: mm/mempool.c
+   :export:
+
+.. kernel-doc:: mm/dmapool.c
+   :export:
+
+.. kernel-doc:: mm/page-writeback.c
+   :export:
+
+.. kernel-doc:: mm/truncate.c
+   :export:
-- 
2.7.4
