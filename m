Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 72EBA6B7C46
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 16:13:18 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id p9so1369696pfj.3
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 13:13:18 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m5si1162988pfm.149.2018.12.06.13.13.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 13:13:17 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB6LArM3022650
	for <linux-mm@kvack.org>; Thu, 6 Dec 2018 16:13:16 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p79kx567q-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Dec 2018 16:13:16 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 6 Dec 2018 21:13:13 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 1/2] slab: make kmem_cache_create{_usercopy} description proper kernel-doc
Date: Thu,  6 Dec 2018 23:13:00 +0200
In-Reply-To: <1544130781-13443-1-git-send-email-rppt@linux.ibm.com>
References: <1544130781-13443-1-git-send-email-rppt@linux.ibm.com>
Message-Id: <1544130781-13443-2-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>

Add the description for kmem_cache_create, fixup the return value paragraph
and make both kmem_cache_create and add the second '*' to the comment
opening.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 mm/slab_common.c | 35 +++++++++++++++++++++++++++++++----
 1 file changed, 31 insertions(+), 4 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 7eb8dc1..dbf63d6 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -406,8 +406,9 @@ static struct kmem_cache *create_cache(const char *name,
 	goto out;
 }
 
-/*
- * kmem_cache_create_usercopy - Create a cache.
+/**
+ * kmem_cache_create_usercopy - Create a cache with a region suitable
+ * for copying to userspace
  * @name: A string which is used in /proc/slabinfo to identify this cache.
  * @size: The size of objects to be created in this cache.
  * @align: The required alignment for the objects.
@@ -416,7 +417,6 @@ static struct kmem_cache *create_cache(const char *name,
  * @usersize: Usercopy region size
  * @ctor: A constructor for the objects.
  *
- * Returns a ptr to the cache on success, NULL on failure.
  * Cannot be called within a interrupt, but can be interrupted.
  * The @ctor is run when new pages are allocated by the cache.
  *
@@ -425,12 +425,14 @@ static struct kmem_cache *create_cache(const char *name,
  * %SLAB_POISON - Poison the slab with a known test pattern (a5a5a5a5)
  * to catch references to uninitialised memory.
  *
- * %SLAB_RED_ZONE - Insert `Red' zones around the allocated memory to check
+ * %SLAB_RED_ZONE - Insert `Red` zones around the allocated memory to check
  * for buffer overruns.
  *
  * %SLAB_HWCACHE_ALIGN - Align the objects in this cache to a hardware
  * cacheline.  This can be beneficial if you're counting cycles as closely
  * as davem.
+ *
+ * Return: a pointer to the cache on success, NULL on failure.
  */
 struct kmem_cache *
 kmem_cache_create_usercopy(const char *name,
@@ -514,6 +516,31 @@ kmem_cache_create_usercopy(const char *name,
 }
 EXPORT_SYMBOL(kmem_cache_create_usercopy);
 
+/**
+ * kmem_cache_create - Create a cache.
+ * @name: A string which is used in /proc/slabinfo to identify this cache.
+ * @size: The size of objects to be created in this cache.
+ * @align: The required alignment for the objects.
+ * @flags: SLAB flags
+ * @ctor: A constructor for the objects.
+ *
+ * Cannot be called within a interrupt, but can be interrupted.
+ * The @ctor is run when new pages are allocated by the cache.
+ *
+ * The flags are
+ *
+ * %SLAB_POISON - Poison the slab with a known test pattern (a5a5a5a5)
+ * to catch references to uninitialised memory.
+ *
+ * %SLAB_RED_ZONE - Insert `Red` zones around the allocated memory to check
+ * for buffer overruns.
+ *
+ * %SLAB_HWCACHE_ALIGN - Align the objects in this cache to a hardware
+ * cacheline.  This can be beneficial if you're counting cycles as closely
+ * as davem.
+ *
+ * Return: a pointer to the cache on success, NULL on failure.
+ */
 struct kmem_cache *
 kmem_cache_create(const char *name, unsigned int size, unsigned int align,
 		slab_flags_t flags, void (*ctor)(void *))
-- 
2.7.4
