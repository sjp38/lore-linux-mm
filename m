Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0DDA66B0270
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 13:33:07 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b9-v6so1081106edn.18
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 10:33:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l22-v6si1579170eda.370.2018.07.26.10.33.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 10:33:05 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6QHTde6130100
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 13:33:04 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2kfjrb83jf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 13:33:03 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 26 Jul 2018 18:33:02 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v3 5/7] docs/core-api: split memory management API to a separate file
Date: Thu, 26 Jul 2018 20:32:38 +0300
In-Reply-To: <1532626360-16650-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1532626360-16650-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1532626360-16650-6-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

This is basically copy-paste of the memory management section from
kernel-api.rst with some minor adjustments:

* The "User Space Memory Access" is moved to the beginning
* The get_user_pages_fast reference is now a part of "User Space Memory
  Access"
* And, of course, headings are adjusted with section being promoted to
  chapters

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/core-api/index.rst      |  1 +
 Documentation/core-api/kernel-api.rst | 54 ---------------------------------
 Documentation/core-api/mm-api.rst     | 57 +++++++++++++++++++++++++++++++++++
 3 files changed, 58 insertions(+), 54 deletions(-)
 create mode 100644 Documentation/core-api/mm-api.rst

diff --git a/Documentation/core-api/index.rst b/Documentation/core-api/index.rst
index 989c97c..cdc2020 100644
--- a/Documentation/core-api/index.rst
+++ b/Documentation/core-api/index.rst
@@ -27,6 +27,7 @@ Core utilities
    errseq
    printk-formats
    circular-buffers
+   mm-api
    gfp_mask-from-fs-io
    timekeeping
 
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
index 0000000..b5913aa
--- /dev/null
+++ b/Documentation/core-api/mm-api.rst
@@ -0,0 +1,57 @@
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
+.. kernel-doc:: mm/util.c
+   :functions: get_user_pages_fast
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
+   :functions: kfree_const kvmalloc_node kvfree
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
