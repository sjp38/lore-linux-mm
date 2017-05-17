Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CA7536B0315
	for <linux-mm@kvack.org>; Wed, 17 May 2017 10:12:55 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u12so10618720pgo.4
        for <linux-mm@kvack.org>; Wed, 17 May 2017 07:12:55 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id g4si1801987pln.281.2017.05.17.07.12.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 07:12:54 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id i63so1990997pgd.2
        for <linux-mm@kvack.org>; Wed, 17 May 2017 07:12:54 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 6/6] mm/slub: rename cpu_partial_slab sysfs
Date: Wed, 17 May 2017 22:11:46 +0800
Message-Id: <20170517141146.11063-7-richard.weiyang@gmail.com>
In-Reply-To: <20170517141146.11063-1-richard.weiyang@gmail.com>
References: <20170517141146.11063-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

Apply the sysfs pattern

    xxx_slabs

to CPU_PARTIAL slabs.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/slub.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index eb0eaa0239fd..93ff334b725e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4988,7 +4988,7 @@ static ssize_t partial_slabs_total_objects_show(struct kmem_cache *s, char *buf)
 }
 SLAB_ATTR_RO(partial_slabs_total_objects);
 
-static ssize_t slabs_cpu_partial_show(struct kmem_cache *s, char *buf)
+static ssize_t cpu_partial_slabs_show(struct kmem_cache *s, char *buf)
 {
 	int objects = 0;
 	int pages = 0;
@@ -5019,7 +5019,7 @@ static ssize_t slabs_cpu_partial_show(struct kmem_cache *s, char *buf)
 #endif
 	return len + sprintf(buf + len, "\n");
 }
-SLAB_ATTR_RO(slabs_cpu_partial);
+SLAB_ATTR_RO(cpu_partial_slabs);
 
 static ssize_t reclaim_account_show(struct kmem_cache *s, char *buf)
 {
@@ -5377,7 +5377,7 @@ static struct attribute *slab_attrs[] = {
 	&destroy_by_rcu_attr.attr,
 	&shrink_attr.attr,
 	&reserved_attr.attr,
-	&slabs_cpu_partial_attr.attr,
+	&cpu_partial_slabs_attr.attr,
 #ifdef CONFIG_SLUB_DEBUG
 	&slabs_total_objects_attr.attr,
 	&slabs_attr.attr,
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
