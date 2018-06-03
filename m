Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 92F526B0005
	for <linux-mm@kvack.org>; Sat,  2 Jun 2018 23:24:14 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id f207-v6so21781836qke.22
        for <linux-mm@kvack.org>; Sat, 02 Jun 2018 20:24:14 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q8-v6si2323942qvo.99.2018.06.02.20.24.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Jun 2018 20:24:13 -0700 (PDT)
From: Baoquan He <bhe@redhat.com>
Subject: [PATCH] slab: Clean up the code comment in slab kmem_cache struct
Date: Sun,  3 Jun 2018 11:24:02 +0800
Message-Id: <20180603032402.27526-1-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, Baoquan He <bhe@redhat.com>

In commit

  3b0efdfa1e7("mm, sl[aou]b: Extract common fields from struct kmem_cache")

The variable 'obj_size' was moved above, however the related code comment
is not updated accordingly. Do it here.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
 include/linux/slab_def.h | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index d9228e4d0320..3485c58cfd1c 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -67,9 +67,10 @@ struct kmem_cache {
 
 	/*
 	 * If debugging is enabled, then the allocator can add additional
-	 * fields and/or padding to every object. size contains the total
-	 * object size including these internal fields, the following two
-	 * variables contain the offset to the user object and its size.
+	 * fields and/or padding to every object. 'size' contains the total
+	 * object size including these internal fields, while 'obj_offset'
+	 * and 'object_size' contain the offset to the user object and its
+	 * size.
 	 */
 	int obj_offset;
 #endif /* CONFIG_DEBUG_SLAB */
-- 
2.13.6
