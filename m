Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3883D6B0010
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:08:17 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id e21so623607qkm.1
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 01:08:17 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f14si895652qke.132.2018.04.18.01.08.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 01:08:16 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3I85ncu010051
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:08:15 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hdwnfkr11-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:08:14 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 18 Apr 2018 09:08:12 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 5/7] docs/admin-guide: introduce basic index for mm documentation
Date: Wed, 18 Apr 2018 11:07:48 +0300
In-Reply-To: <1524038870-413-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1524038870-413-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1524038870-413-6-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@infradead.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/admin-guide/index.rst    |  1 +
 Documentation/admin-guide/mm/index.rst | 19 +++++++++++++++++++
 2 files changed, 20 insertions(+)
 create mode 100644 Documentation/admin-guide/mm/index.rst

diff --git a/Documentation/admin-guide/index.rst b/Documentation/admin-guide/index.rst
index 5bb9161..cac906f 100644
--- a/Documentation/admin-guide/index.rst
+++ b/Documentation/admin-guide/index.rst
@@ -63,6 +63,7 @@ configure specific aspects of kernel behavior to your liking.
    pm/index
    thunderbolt
    LSM/index
+   mm/index
 
 .. only::  subproject and html
 
diff --git a/Documentation/admin-guide/mm/index.rst b/Documentation/admin-guide/mm/index.rst
new file mode 100644
index 0000000..c47c16e
--- /dev/null
+++ b/Documentation/admin-guide/mm/index.rst
@@ -0,0 +1,19 @@
+=================
+Memory Management
+=================
+
+Linux memory management subsystem is responsible, as the name implies,
+for managing the memory in the system. This includes implemnetation of
+virtual memory and demand paging, memory allocation both for kernel
+internal structures and user space programms, mapping of files into
+processes address space and many other cool things.
+
+Linux memory management is a complex system with many configurable
+settings. Most of these settings are available via ``/proc``
+filesystem and can be quired and adjusted using ``sysctl``. These APIs
+are described in Documentation/sysctl/vm.txt and in `man 5 proc`_.
+
+.. _man 5 proc: http://man7.org/linux/man-pages/man5/proc.5.html
+
+Here we document in detail how to interact with various mechanisms in
+the Linux memory management.
-- 
2.7.4
