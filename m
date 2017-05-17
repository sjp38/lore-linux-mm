Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 60F316B02FA
	for <linux-mm@kvack.org>; Wed, 17 May 2017 10:12:49 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j28so9770833pfk.14
        for <linux-mm@kvack.org>; Wed, 17 May 2017 07:12:49 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id b5si2207942pfc.53.2017.05.17.07.12.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 07:12:48 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id n23so1895742pfb.3
        for <linux-mm@kvack.org>; Wed, 17 May 2017 07:12:48 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 4/6] mm/slub: rename ALL slabs sysfs
Date: Wed, 17 May 2017 22:11:44 +0800
Message-Id: <20170517141146.11063-5-richard.weiyang@gmail.com>
In-Reply-To: <20170517141146.11063-1-richard.weiyang@gmail.com>
References: <20170517141146.11063-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

Apply the sysfs pattern

    xxx_slabs[[_total]_objects]

to ALL slabs.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/slub.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index f2f751e6cb96..443dacbf214e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4970,11 +4970,11 @@ static ssize_t cpu_slabs_total_objects_show(struct kmem_cache *s, char *buf)
 }
 SLAB_ATTR_RO(cpu_slabs_total_objects);
 
-static ssize_t objects_show(struct kmem_cache *s, char *buf)
+static ssize_t slabs_objects_show(struct kmem_cache *s, char *buf)
 {
 	return show_slab_objects(s, buf, SO_ALL|SO_OBJECTS);
 }
-SLAB_ATTR_RO(objects);
+SLAB_ATTR_RO(slabs_objects);
 
 static ssize_t objects_partial_show(struct kmem_cache *s, char *buf)
 {
@@ -5069,11 +5069,11 @@ static ssize_t slabs_show(struct kmem_cache *s, char *buf)
 }
 SLAB_ATTR_RO(slabs);
 
-static ssize_t total_objects_show(struct kmem_cache *s, char *buf)
+static ssize_t slabs_total_objects_show(struct kmem_cache *s, char *buf)
 {
 	return show_slab_objects(s, buf, SO_ALL|SO_TOTAL);
 }
-SLAB_ATTR_RO(total_objects);
+SLAB_ATTR_RO(slabs_total_objects);
 
 static ssize_t sanity_checks_show(struct kmem_cache *s, char *buf)
 {
@@ -5362,7 +5362,7 @@ static struct attribute *slab_attrs[] = {
 	&order_attr.attr,
 	&min_partial_attr.attr,
 	&cpu_partial_attr.attr,
-	&objects_attr.attr,
+	&slabs_objects_attr.attr,
 	&objects_partial_attr.attr,
 	&total_objects_partial_attr.attr,
 	&partial_attr.attr,
@@ -5379,7 +5379,7 @@ static struct attribute *slab_attrs[] = {
 	&reserved_attr.attr,
 	&slabs_cpu_partial_attr.attr,
 #ifdef CONFIG_SLUB_DEBUG
-	&total_objects_attr.attr,
+	&slabs_total_objects_attr.attr,
 	&slabs_attr.attr,
 	&sanity_checks_attr.attr,
 	&trace_attr.attr,
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
