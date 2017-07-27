Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3E79D6B02FA
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 08:07:17 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 125so244218430pgi.2
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:07:17 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id v25si11011055pge.684.2017.07.27.05.07.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 05:07:16 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id e3so434830pfc.5
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:07:16 -0700 (PDT)
From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 2/5] mm: slub: constify attribute_group structures.
Date: Thu, 27 Jul 2017 17:36:26 +0530
Message-Id: <1501157186-3749-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

attribute_group are not supposed to change at runtime. All functions
working with attribute_group provided by <linux/sysfs.h> work with
const attribute_group. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 1d3f983..72af363 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5423,7 +5423,7 @@ static void clear_stat(struct kmem_cache *s, enum stat_item si)
 	NULL
 };
 
-static struct attribute_group slab_attr_group = {
+static const struct attribute_group slab_attr_group = {
 	.attrs = slab_attrs,
 };
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
