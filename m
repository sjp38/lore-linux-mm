Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 886DD6B0266
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 08:22:28 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id u74-v6so1214879oie.16
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 05:22:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t2-v6si828275oib.16.2018.07.26.05.22.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 05:22:27 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6QCJHMC133517
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 08:22:26 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kfe1k8jf0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 08:22:26 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 26 Jul 2018 13:22:24 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2 7/7] docs/core-api: mm-api: add section about GFP flags
Date: Thu, 26 Jul 2018 15:22:02 +0300
In-Reply-To: <1532607722-17079-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1532607722-17079-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1532607722-17079-8-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/core-api/mm-api.rst | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/Documentation/core-api/mm-api.rst b/Documentation/core-api/mm-api.rst
index b5913aa..3d2a7ec 100644
--- a/Documentation/core-api/mm-api.rst
+++ b/Documentation/core-api/mm-api.rst
@@ -14,6 +14,28 @@ User Space Memory Access
 .. kernel-doc:: mm/util.c
    :functions: get_user_pages_fast
 
+Memory Allocation Controls
+==========================
+
+Linux provides a variety of APIs for memory allocation from direct
+calls to page allocator through slab caches and vmalloc to allocators
+of compressed memory. Although these allocators have different
+semantics and are used in different circumstances, they all share the
+GFP (get free page) flags that control behavior of each allocation
+request.
+
+.. kernel-doc:: include/linux/gfp.h
+   :doc: Page mobility and placement hints
+
+.. kernel-doc:: include/linux/gfp.h
+   :doc: Watermark modifiers
+
+.. kernel-doc:: include/linux/gfp.h
+   :doc: Reclaim modifiers
+
+.. kernel-doc:: include/linux/gfp.h
+   :doc: Common combinations
+
 The Slab Cache
 ==============
 
-- 
2.7.4
