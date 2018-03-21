Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 796C36B0285
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:25:32 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id c11so3073736wrf.4
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:25:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 36si133729ede.505.2018.03.21.12.25.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 12:25:31 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2LJIaZA009045
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:25:29 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gut811a5w-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:25:29 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 21 Mar 2018 19:25:27 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 32/32] docs/vm: add index.rst and link MM documentation to top level index
Date: Wed, 21 Mar 2018 21:22:48 +0200
In-Reply-To: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1521660168-14372-33-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/index.rst    |  3 ++-
 Documentation/vm/conf.py   | 10 +++++++++
 Documentation/vm/index.rst | 56 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 68 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/vm/conf.py
 create mode 100644 Documentation/vm/index.rst

diff --git a/Documentation/index.rst b/Documentation/index.rst
index ef5080c..cc4a098 100644
--- a/Documentation/index.rst
+++ b/Documentation/index.rst
@@ -45,7 +45,7 @@ the kernel interface as seen by application developers.
 .. toctree::
    :maxdepth: 2
 
-   userspace-api/index	      
+   userspace-api/index
 
 
 Introduction to kernel development
@@ -88,6 +88,7 @@ needed).
    sound/index
    crypto/index
    filesystems/index
+   vm/index
 
 Architecture-specific documentation
 -----------------------------------
diff --git a/Documentation/vm/conf.py b/Documentation/vm/conf.py
new file mode 100644
index 0000000..3b0b601
--- /dev/null
+++ b/Documentation/vm/conf.py
@@ -0,0 +1,10 @@
+# -*- coding: utf-8; mode: python -*-
+
+project = "Linux Memory Management Documentation"
+
+tags.add("subproject")
+
+latex_documents = [
+    ('index', 'memory-management.tex', project,
+     'The kernel development community', 'manual'),
+]
diff --git a/Documentation/vm/index.rst b/Documentation/vm/index.rst
new file mode 100644
index 0000000..6c45142
--- /dev/null
+++ b/Documentation/vm/index.rst
@@ -0,0 +1,56 @@
+=====================================
+Linux Memory Management Documentation
+=====================================
+
+This is a collection of documents about Linux memory management (mm) subsystem.
+
+User guides for MM features
+===========================
+
+The following documents provide guides for controlling and tuning
+various features of the Linux memory management
+
+.. toctree::
+   :maxdepth: 1
+
+   hugetlbpage
+   idle_page_tracking
+   ksm
+   numa_memory_policy
+   pagemap
+   transhuge
+   soft-dirty
+   swap_numa
+   userfaultfd
+   zswap
+
+Kernel developers MM documentation
+==================================
+
+The below documents describe MM internals with different level of
+details ranging from notes and mailing list responses to elaborate
+descriptions of data structures and algorithms.
+
+.. toctree::
+   :maxdepth: 1
+
+   active_mm
+   balance
+   cleancache
+   frontswap
+   highmem
+   hmm
+   hwpoison
+   hugetlbfs_reserv
+   mmu_notifier
+   numa
+   overcommit-accounting
+   page_migration
+   page_frags
+   page_owner
+   remap_file_pages
+   slub
+   split_page_table_lock
+   unevictable-lru
+   z3fold
+   zsmalloc
-- 
2.7.4
