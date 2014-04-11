Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 020486B0036
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 08:52:28 -0400 (EDT)
Received: by mail-la0-f53.google.com with SMTP id b8so3488916lan.12
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 05:52:26 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id y6si5532842lal.5.2014.04.11.05.52.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Apr 2014 05:52:25 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm] slab: document kmalloc_order
Date: Fri, 11 Apr 2014 16:52:16 +0400
Message-ID: <1397220736-13840-1-git-send-email-vdavydov@parallels.com>
In-Reply-To: <20140410163831.c76596b0f8d0bef39a42c63f@linux-foundation.org>
References: <20140410163831.c76596b0f8d0bef39a42c63f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux-foundation.org, penberg@kernel.org, gthelen@google.com, hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slab_common.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index cab4c49b3e8c..3ffd2e76b5d2 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -573,6 +573,11 @@ void __init create_kmalloc_caches(unsigned long flags)
 }
 #endif /* !CONFIG_SLOB */
 
+/*
+ * To avoid unnecessary overhead, we pass through large allocation requests
+ * directly to the page allocator. We use __GFP_COMP, because we will need to
+ * know the allocation order to free the pages properly in kfree.
+ */
 void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
 {
 	void *ret;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
