Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CBAB46B02F4
	for <linux-mm@kvack.org>; Wed, 17 May 2017 10:12:45 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t12so10597859pgo.7
        for <linux-mm@kvack.org>; Wed, 17 May 2017 07:12:45 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id k8si2264980pln.98.2017.05.17.07.12.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 07:12:44 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id u26so1903692pfd.2
        for <linux-mm@kvack.org>; Wed, 17 May 2017 07:12:44 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 3/6] mm/slub: add cpu_slabs_[total_]objects sysfs
Date: Wed, 17 May 2017 22:11:43 +0800
Message-Id: <20170517141146.11063-4-richard.weiyang@gmail.com>
In-Reply-To: <20170517141146.11063-1-richard.weiyang@gmail.com>
References: <20170517141146.11063-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

For cpu slabs, show_slab_objects could display statistics for objects.

This patch just adds an entry to reflect it.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/slub.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index c7dddf22829d..f2f751e6cb96 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4958,6 +4958,18 @@ static ssize_t cpu_slabs_show(struct kmem_cache *s, char *buf)
 }
 SLAB_ATTR_RO(cpu_slabs);
 
+static ssize_t cpu_slabs_objects_show(struct kmem_cache *s, char *buf)
+{
+	return show_slab_objects(s, buf, SO_CPU|SO_OBJECTS);
+}
+SLAB_ATTR_RO(cpu_slabs_objects);
+
+static ssize_t cpu_slabs_total_objects_show(struct kmem_cache *s, char *buf)
+{
+	return show_slab_objects(s, buf, SO_CPU|SO_TOTAL);
+}
+SLAB_ATTR_RO(cpu_slabs_total_objects);
+
 static ssize_t objects_show(struct kmem_cache *s, char *buf)
 {
 	return show_slab_objects(s, buf, SO_ALL|SO_OBJECTS);
@@ -5354,6 +5366,8 @@ static struct attribute *slab_attrs[] = {
 	&objects_partial_attr.attr,
 	&total_objects_partial_attr.attr,
 	&partial_attr.attr,
+	&cpu_slabs_objects_attr.attr,
+	&cpu_slabs_total_objects_attr.attr,
 	&cpu_slabs_attr.attr,
 	&ctor_attr.attr,
 	&aliases_attr.attr,
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
