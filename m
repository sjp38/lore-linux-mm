Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D650E6B0273
	for <linux-mm@kvack.org>; Fri,  4 May 2018 14:33:30 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x23so10461698pfm.7
        for <linux-mm@kvack.org>; Fri, 04 May 2018 11:33:30 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w5-v6si13435862pgt.68.2018.05.04.11.33.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 04 May 2018 11:33:28 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 16/17] slub: Remove 'reserved' file from sysfs
Date: Fri,  4 May 2018 11:33:17 -0700
Message-Id: <20180504183318.14415-17-willy@infradead.org>
In-Reply-To: <20180504183318.14415-1-willy@infradead.org>
References: <20180504183318.14415-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Christoph doubts anyone was using the 'reserved' file in sysfs, so
remove it.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/slub.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 33a811168fa9..4d77fd8450fa 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5094,12 +5094,6 @@ static ssize_t destroy_by_rcu_show(struct kmem_cache *s, char *buf)
 }
 SLAB_ATTR_RO(destroy_by_rcu);
 
-static ssize_t reserved_show(struct kmem_cache *s, char *buf)
-{
-	return sprintf(buf, "0\n");
-}
-SLAB_ATTR_RO(reserved);
-
 #ifdef CONFIG_SLUB_DEBUG
 static ssize_t slabs_show(struct kmem_cache *s, char *buf)
 {
@@ -5412,7 +5406,6 @@ static struct attribute *slab_attrs[] = {
 	&reclaim_account_attr.attr,
 	&destroy_by_rcu_attr.attr,
 	&shrink_attr.attr,
-	&reserved_attr.attr,
 	&slabs_cpu_partial_attr.attr,
 #ifdef CONFIG_SLUB_DEBUG
 	&total_objects_attr.attr,
-- 
2.17.0
