Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B3AD56B0311
	for <linux-mm@kvack.org>; Wed, 17 May 2017 10:12:52 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e16so9777500pfj.15
        for <linux-mm@kvack.org>; Wed, 17 May 2017 07:12:52 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id k24si2210691pfa.55.2017.05.17.07.12.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 07:12:51 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id h64so1987132pge.3
        for <linux-mm@kvack.org>; Wed, 17 May 2017 07:12:51 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 5/6] mm/slub: rename partial_slabs sysfs
Date: Wed, 17 May 2017 22:11:45 +0800
Message-Id: <20170517141146.11063-6-richard.weiyang@gmail.com>
In-Reply-To: <20170517141146.11063-1-richard.weiyang@gmail.com>
References: <20170517141146.11063-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

Apply the sysfs pattern

    xxx_slabs[[_total]_objects]

to PARTIAL slabs.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/slub.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 443dacbf214e..eb0eaa0239fd 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4946,11 +4946,11 @@ static ssize_t aliases_show(struct kmem_cache *s, char *buf)
 }
 SLAB_ATTR_RO(aliases);
 
-static ssize_t partial_show(struct kmem_cache *s, char *buf)
+static ssize_t partial_slabs_show(struct kmem_cache *s, char *buf)
 {
 	return show_slab_objects(s, buf, SO_PARTIAL);
 }
-SLAB_ATTR_RO(partial);
+SLAB_ATTR_RO(partial_slabs);
 
 static ssize_t cpu_slabs_show(struct kmem_cache *s, char *buf)
 {
@@ -4976,17 +4976,17 @@ static ssize_t slabs_objects_show(struct kmem_cache *s, char *buf)
 }
 SLAB_ATTR_RO(slabs_objects);
 
-static ssize_t objects_partial_show(struct kmem_cache *s, char *buf)
+static ssize_t partial_slabs_objects_show(struct kmem_cache *s, char *buf)
 {
 	return show_slab_objects(s, buf, SO_PARTIAL|SO_OBJECTS);
 }
-SLAB_ATTR_RO(objects_partial);
+SLAB_ATTR_RO(partial_slabs_objects);
 
-static ssize_t total_objects_partial_show(struct kmem_cache *s, char *buf)
+static ssize_t partial_slabs_total_objects_show(struct kmem_cache *s, char *buf)
 {
 	return show_slab_objects(s, buf, SO_PARTIAL|SO_TOTAL);
 }
-SLAB_ATTR_RO(total_objects_partial);
+SLAB_ATTR_RO(partial_slabs_total_objects);
 
 static ssize_t slabs_cpu_partial_show(struct kmem_cache *s, char *buf)
 {
@@ -5363,9 +5363,9 @@ static struct attribute *slab_attrs[] = {
 	&min_partial_attr.attr,
 	&cpu_partial_attr.attr,
 	&slabs_objects_attr.attr,
-	&objects_partial_attr.attr,
-	&total_objects_partial_attr.attr,
-	&partial_attr.attr,
+	&partial_slabs_objects_attr.attr,
+	&partial_slabs_total_objects_attr.attr,
+	&partial_slabs_attr.attr,
 	&cpu_slabs_objects_attr.attr,
 	&cpu_slabs_total_objects_attr.attr,
 	&cpu_slabs_attr.attr,
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
