Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id C27598E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 06:47:43 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id w28so16136425qkj.22
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 03:47:43 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x46si1488442qth.369.2019.01.14.03.47.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 03:47:42 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x0EBixN5142774
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 06:47:42 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2q0pskr34f-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 06:47:41 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 14 Jan 2019 11:47:40 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH] docs/core-api: memory-allocation: add mention of kmem_cache_create_userspace
Date: Mon, 14 Jan 2019 13:47:34 +0200
Message-Id: <1547466454-29457-1-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.ibm.com>

Mention that when a part of a slab cache might be exported to the
userspace, the cache should be created using kmem_cache_create_usercopy()

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 Documentation/core-api/memory-allocation.rst | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/Documentation/core-api/memory-allocation.rst b/Documentation/core-api/memory-allocation.rst
index 8954a88..51a200d 100644
--- a/Documentation/core-api/memory-allocation.rst
+++ b/Documentation/core-api/memory-allocation.rst
@@ -113,9 +113,11 @@ see :c:func:`kvmalloc_node` reference documentation. Note that
 
 If you need to allocate many identical objects you can use the slab
 cache allocator. The cache should be set up with
-:c:func:`kmem_cache_create` before it can be used. Afterwards
-:c:func:`kmem_cache_alloc` and its convenience wrappers can allocate
-memory from that cache.
+:c:func:`kmem_cache_create` or :c:func:`kmem_cache_create_usercopy`
+before it can be used. The second function should be used if a part of
+the cache might be copied to the userspace.  After the cache is
+created :c:func:`kmem_cache_alloc` and its convenience wrappers can
+allocate memory from that cache.
 
 When the allocated memory is no longer needed it must be freed. You
 can use :c:func:`kvfree` for the memory allocated with `kmalloc`,
-- 
2.7.4
