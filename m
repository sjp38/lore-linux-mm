Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E68F46B02F2
	for <linux-mm@kvack.org>; Wed, 17 May 2017 10:12:38 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u12so10615004pgo.4
        for <linux-mm@kvack.org>; Wed, 17 May 2017 07:12:38 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id b1si2224691pld.97.2017.05.17.07.12.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 07:12:38 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id u26so1903464pfd.2
        for <linux-mm@kvack.org>; Wed, 17 May 2017 07:12:38 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 1/6] mm/slub: add total_objects_partial sysfs
Date: Wed, 17 May 2017 22:11:41 +0800
Message-Id: <20170517141146.11063-2-richard.weiyang@gmail.com>
In-Reply-To: <20170517141146.11063-1-richard.weiyang@gmail.com>
References: <20170517141146.11063-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

For partial slabs, show_slab_objects could display its total objects.

This patch just adds an entry to display it.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/slub.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index a7a109247730..1100d2e75870 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4983,6 +4983,12 @@ static ssize_t objects_partial_show(struct kmem_cache *s, char *buf)
 }
 SLAB_ATTR_RO(objects_partial);
 
+static ssize_t total_objects_partial_show(struct kmem_cache *s, char *buf)
+{
+	return show_slab_objects(s, buf, SO_PARTIAL|SO_TOTAL);
+}
+SLAB_ATTR_RO(total_objects_partial);
+
 static ssize_t slabs_cpu_partial_show(struct kmem_cache *s, char *buf)
 {
 	int objects = 0;
@@ -5359,6 +5365,7 @@ static struct attribute *slab_attrs[] = {
 	&cpu_partial_attr.attr,
 	&objects_attr.attr,
 	&objects_partial_attr.attr,
+	&total_objects_partial_attr.attr,
 	&partial_attr.attr,
 	&cpu_slabs_attr.attr,
 	&ctor_attr.attr,
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
