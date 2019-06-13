Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 101A5C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 08:14:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABCAC20866
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 08:14:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABCAC20866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 522B26B0005; Thu, 13 Jun 2019 04:14:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D33A6B0006; Thu, 13 Jun 2019 04:14:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39B176B0007; Thu, 13 Jun 2019 04:14:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E0F576B0005
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 04:14:16 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f9so13961105pfn.6
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 01:14:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=PjwpKMSvyqymmJclCY5/3R0WJb0RbMS45F6wM9MWbVQ=;
        b=EXOJ5+BoS2MOlvv6/yaR+igfcQqnDqxdJ1aRR4Roqikd1Q2nMZ2bYENjt41B52Z3zT
         DS6iryM1BI4oaBxDp/fdnL/kzr0XGC/R/flVXbUqh4GTXaSe2MIrP+AJw3CG+To5W4YK
         nV7at6Lactl6d8fveA0/YJ8aUXFSpEQ+BcMaIMmAK+z+o0pe3EJTBsHfAwxWd3pPf/Qr
         iK95hi9zUG6DFAX/2Yfyh/5uM42SyKOdUD3cKPwnwPA9KLZWyAtXa++B0C/0FDIQBpgv
         QKv7leYj/vZbZ+QHaWOBAoIIOaGucABLG0SOR1q7UantZJyXhwDgVtUd6TwFraNuCekq
         boOw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-Gm-Message-State: APjAAAURtAkE5+9zPo5QDRZodxkXxTVca9KsAJt9LpTQ/pyzJXXjapma
	uhPdZ7QuuBPJgIwwvr8hg7znmn27WBAChYsvoE/2x5SIn3q6/YESf5G4oth2/xcYSSf5K6ayyzV
	hL2VRXjRWbriYBm3k8KziPLQmte4079TjvbIXVZx7VKFnC9oDt7Moc11tqi+bLvsL/w==
X-Received: by 2002:a17:902:3341:: with SMTP id a59mr56609403plc.186.1560413656458;
        Thu, 13 Jun 2019 01:14:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQJCGj09sHRCSAgbtjLvH0hk0vm1VLBc6LGKWazTPP4PvxzqnXb/ivanRSE/dtZ8L72bMz
X-Received: by 2002:a17:902:3341:: with SMTP id a59mr56609316plc.186.1560413654992;
        Thu, 13 Jun 2019 01:14:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560413654; cv=none;
        d=google.com; s=arc-20160816;
        b=BZTZ3VYHHjtKAO12+8Gnbdrs9UX15H8sUwHg+s1lH5XF8arLfbYwXwuZ/sWVYHH+8n
         b1YrZShwYneGw6jxGArjjjcUm8RzXtvB4nQ8Jf7oqTS9dpY7DpP1uPbpTFDAuGD5L2wH
         e/kbZGjY0iiqGbm36VGPaA2s5LO6DcKHrVdadgLivI0boSWHtW3JlEJLf7sajd5+3+sm
         3C9cOGeDibo01ON61GK6wU7I4bP0kmDe7koqV5GoMwcPi+gesni3us8q2qqnMkIcDEp7
         nlpISWaiaf4M/tfy5UIfzZtaJYuh9vSiXllNRcURP8Pz6ekxZJWSZHTljZ0TT+w1SXLA
         sbvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=PjwpKMSvyqymmJclCY5/3R0WJb0RbMS45F6wM9MWbVQ=;
        b=BhcsDZkFUUsNjHvlcF/VKmyCPjlK0WDm3Vx6EGOa2pi12NQYHQ38kLkrn3vDT9Goqn
         WHIQpb5bhRBe9+35bwNtOa9HB/A94RmJXKWEXSsPiWcihVcBWsVewfIXaHaq95uIoz9p
         yiuFq03+6lVMpfxq30wmj1hL43bcGXLvKfqwH/nv++/XXX+JDtt+acWelF3fZ1gQGFx0
         EFR1j7XnkOfw157QOtqq3mcOrgVeNlc9f2VA5eymozOPTh+eGpPFc0ze25yIG4iPRt7F
         h5/pL/zXejK9yHBmClenwbbKoLA2hKOfp6lLwKHZQkhHloZrb7LlWXY4OJj8tHogdTzg
         a3kQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTPS id m6si2342663pjl.60.2019.06.13.01.14.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 01:14:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) client-ip=210.61.82.184;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-UUID: 2ad63aae6c7a4eecae24f2c5d8ebf831-20190613
X-UUID: 2ad63aae6c7a4eecae24f2c5d8ebf831-20190613
Received: from mtkcas06.mediatek.inc [(172.21.101.30)] by mailgw02.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 333036920; Thu, 13 Jun 2019 16:14:10 +0800
Received: from mtkcas08.mediatek.inc (172.21.101.126) by
 mtkmbs08n1.mediatek.inc (172.21.101.55) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Thu, 13 Jun 2019 16:14:08 +0800
Received: from mtksdccf07.mediatek.inc (172.21.84.99) by mtkcas08.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Thu, 13 Jun 2019 16:14:08 +0800
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko
	<glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Christoph Lameter
	<cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes
	<rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthias Brugger
	<matthias.bgg@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Arnd
 Bergmann <arnd@arndb.de>, Vasily Gorbik <gor@linux.ibm.com>, Andrey Konovalov
	<andreyknvl@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Miles Chen
	<miles.chen@mediatek.com>, Walter Wu <walter-zh.wu@mediatek.com>
CC: <kasan-dev@googlegroups.com>, <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-mediatek@lists.infradead.org>, <wsd_upstream@mediatek.com>
Subject: [PATCH v3] kasan: add memory corruption identification for software tag-based mode
Date: Thu, 13 Jun 2019 16:13:57 +0800
Message-ID: <20190613081357.1360-1-walter-zh.wu@mediatek.com>
X-Mailer: git-send-email 2.18.0
MIME-Version: 1.0
Content-Type: text/plain
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch adds memory corruption identification at bug report for
software tag-based mode, the report show whether it is "use-after-free"
or "out-of-bound" error instead of "invalid-access" error.This will make
it easier for programmers to see the memory corruption problem.

Now we extend the quarantine to support both generic and tag-based kasan.
For tag-based kasan, the quarantine stores only freed object information
to check if an object is freed recently. When tag-based kasan reports an
error, we can check if the tagged addr is in the quarantine and make a
good guess if the object is more like "use-after-free" or "out-of-bound".

Due to tag-based kasan, the tag values are stored in the shadow memory,
all tag comparison failures are memory corruption. Even if those freed
object have been deallocated, we still can get the memory corruption.
So the freed object doesn't need to be kept in quarantine, it can be
immediately released after calling kfree(). We only need the freed object
information in quarantine, the error handler is able to use object
information to know if it has been allocated or deallocated, therefore
every slab memory corruption can be identified whether it's
"use-after-free" or "out-of-bound".

The difference between generic kasan and tag-based kasan quarantine is
slab memory usage. Tag-based kasan only stores freed object information
rather than the object itself. So tag-based kasan quarantine memory usage
is smaller than generic kasan.

====== Benchmarks

The following numbers were collected in QEMU.
Both generic and tag-based KASAN were used in inline instrumentation mode
and no stack checking.

Boot time :
* ~1.5 sec for clean kernel
* ~3 sec for generic KASAN
* ~3.5  sec for tag-based KASAN
* ~3.5 sec for tag-based KASAN + corruption identification

Slab memory usage after boot :
* ~10500 kb  for clean kernel
* ~30500 kb  for generic KASAN
* ~12300 kb  for tag-based KASAN
* ~17100 kb  for tag-based KASAN + corruption identification

====== Changes

Change since v1:
- add feature option CONFIG_KASAN_SW_TAGS_IDENTIFY.
- change QUARANTINE_FRACTION to reduce quarantine size.
- change the qlist order in order to find the newest object in quarantine
- reduce the number of calling kmalloc() from 2 to 1 time.
- remove global variable to use argument to pass it.
- correct the amount of qobject cache->size into the byes of qlist_head.
- only use kasan_cache_shrink() to shink memory.

Change since v2:
- remove the shinking memory function kasan_cache_shrink()
- modify the description of the CONFIG_KASAN_SW_TAGS_IDENTIFY 
- optimize the quarantine_find_object() and qobject_free()
- fix the duplicating function name 3 times in the header.
- modify the function name set_track() to kasan_set_track()

Cc: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Walter Wu <walter-zh.wu@mediatek.com>
---
 lib/Kconfig.kasan      |   8 +++
 mm/kasan/Makefile      |   1 +
 mm/kasan/common.c      |   9 +--
 mm/kasan/kasan.h       |  36 ++++++++++-
 mm/kasan/quarantine.c  | 137 +++++++++++++++++++++++++++++++++++++----
 mm/kasan/report.c      |  37 +++++++----
 mm/kasan/tags.c        |  40 ++++++++++++
 mm/kasan/tags_report.c |   8 ++-
 mm/slub.c              |   2 +-
 9 files changed, 244 insertions(+), 34 deletions(-)

diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 9950b660e62d..f612326f63f0 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -134,6 +134,14 @@ config KASAN_S390_4_LEVEL_PAGING
 	  to 3TB of RAM with KASan enabled). This options allows to force
 	  4-level paging instead.
 
+config KASAN_SW_TAGS_IDENTIFY
+	bool "Enable memory corruption identification"
+	depends on KASAN_SW_TAGS
+	help
+	  This option enables best-effort identification of bug type
+	  (use-after-free or out-of-bounds) at the cost of increased
+	  memory consumption for object quarantine.
+
 config TEST_KASAN
 	tristate "Module for testing KASAN for bug detection"
 	depends on m && KASAN
diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
index 5d1065efbd47..d8540e5070cb 100644
--- a/mm/kasan/Makefile
+++ b/mm/kasan/Makefile
@@ -19,3 +19,4 @@ CFLAGS_tags.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 obj-$(CONFIG_KASAN) := common.o init.o report.o
 obj-$(CONFIG_KASAN_GENERIC) += generic.o generic_report.o quarantine.o
 obj-$(CONFIG_KASAN_SW_TAGS) += tags.o tags_report.o
+obj-$(CONFIG_KASAN_SW_TAGS_IDENTIFY) += quarantine.o
diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 80bbe62b16cd..0375a37d36cb 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -81,7 +81,7 @@ static inline depot_stack_handle_t save_stack(gfp_t flags)
 	return depot_save_stack(&trace, flags);
 }
 
-static inline void set_track(struct kasan_track *track, gfp_t flags)
+void kasan_set_track(struct kasan_track *track, gfp_t flags)
 {
 	track->pid = current->pid;
 	track->stack = save_stack(flags);
@@ -456,8 +456,8 @@ static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
 			unlikely(!(cache->flags & SLAB_KASAN)))
 		return false;
 
-	set_track(&get_alloc_info(cache, object)->free_track, GFP_NOWAIT);
-	quarantine_put(get_free_info(cache, object), cache);
+	kasan_set_track(&get_alloc_info(cache, object)->free_track, GFP_NOWAIT);
+	quarantine_put(get_free_info(cache, tagged_object), cache);
 
 	return IS_ENABLED(CONFIG_KASAN_GENERIC);
 }
@@ -494,7 +494,8 @@ static void *__kasan_kmalloc(struct kmem_cache *cache, const void *object,
 		KASAN_KMALLOC_REDZONE);
 
 	if (cache->flags & SLAB_KASAN)
-		set_track(&get_alloc_info(cache, object)->alloc_track, flags);
+		kasan_set_track(&get_alloc_info(cache, object)->alloc_track,
+						flags);
 
 	return set_tag(object, tag);
 }
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 3e0c11f7d7a1..0ff9fb5afb91 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -98,6 +98,12 @@ struct kasan_alloc_meta {
 struct qlist_node {
 	struct qlist_node *next;
 };
+struct qlist_object {
+	unsigned long addr;
+	unsigned int size;
+	struct kasan_track free_track;
+	struct qlist_node qnode;
+};
 struct kasan_free_meta {
 	/* This field is used while the object is in the quarantine.
 	 * Otherwise it might be used for the allocator freelist.
@@ -133,11 +139,13 @@ void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
 void kasan_report_invalid_free(void *object, unsigned long ip);
 
-#if defined(CONFIG_KASAN_GENERIC) && \
-	(defined(CONFIG_SLAB) || defined(CONFIG_SLUB))
+#if (defined(CONFIG_KASAN_GENERIC) || defined(CONFIG_KASAN_SW_TAGS_IDENTIFY)) \
+	&& (defined(CONFIG_SLAB) || defined(CONFIG_SLUB))
 void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
 void quarantine_reduce(void);
 void quarantine_remove_cache(struct kmem_cache *cache);
+void kasan_set_track(struct kasan_track *track, gfp_t flags);
+struct kmem_cache *qlink_to_cache(struct qlist_node *qlink);
 #else
 static inline void quarantine_put(struct kasan_free_meta *info,
 				struct kmem_cache *cache) { }
@@ -162,6 +170,30 @@ static inline u8 random_tag(void)
 
 #endif
 
+#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
+bool quarantine_find_object(void *object,
+		struct kasan_track *free_track);
+
+struct qlist_object *qobject_create(struct kasan_free_meta *info,
+		struct kmem_cache *cache);
+
+void qobject_free(struct qlist_node *qlink);
+#else
+static inline bool quarantine_find_object(void *object,
+		struct kasan_track *free_track)
+{
+	return false;
+}
+
+static inline struct qlist_object *qobject_create(struct kasan_free_meta *info,
+		struct kmem_cache *cache)
+{
+	return NULL;
+}
+
+static inline void qobject_free(struct qlist_node *qlink) {}
+#endif
+
 #ifndef arch_kasan_set_tag
 #define arch_kasan_set_tag(addr, tag)	((void *)(addr))
 #endif
diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
index 978bc4a3eb51..495507a71a77 100644
--- a/mm/kasan/quarantine.c
+++ b/mm/kasan/quarantine.c
@@ -61,12 +61,16 @@ static void qlist_init(struct qlist_head *q)
 static void qlist_put(struct qlist_head *q, struct qlist_node *qlink,
 		size_t size)
 {
-	if (unlikely(qlist_empty(q)))
+	struct qlist_node *prev_qlink = q->head;
+
+	if (unlikely(qlist_empty(q))) {
+		q->head = qlink;
+		q->tail = qlink;
+		qlink->next = NULL;
+	} else {
 		q->head = qlink;
-	else
-		q->tail->next = qlink;
-	q->tail = qlink;
-	qlink->next = NULL;
+		qlink->next = prev_qlink;
+	}
 	q->bytes += size;
 }
 
@@ -121,9 +125,19 @@ static unsigned long quarantine_batch_size;
  * Quarantine doesn't support memory shrinker with SLAB allocator, so we keep
  * the ratio low to avoid OOM.
  */
+#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
+/*
+ * Tag-based KASAN only stores freed object information rather than the
+ * object itself. The quarantine in tag-based KASAN only needs less usage
+ * to achieve the same effect as generic KASAN. So We modify the
+ * QUARANTINE_FRACTION to slim the quarantine.
+ */
+#define QUARANTINE_FRACTION 128
+#else
 #define QUARANTINE_FRACTION 32
+#endif
 
-static struct kmem_cache *qlink_to_cache(struct qlist_node *qlink)
+struct kmem_cache *qlink_to_cache(struct qlist_node *qlink)
 {
 	return virt_to_head_page(qlink)->slab_cache;
 }
@@ -139,16 +153,22 @@ static void *qlink_to_object(struct qlist_node *qlink, struct kmem_cache *cache)
 
 static void qlink_free(struct qlist_node *qlink, struct kmem_cache *cache)
 {
-	void *object = qlink_to_object(qlink, cache);
+	void *object;
 	unsigned long flags;
 
-	if (IS_ENABLED(CONFIG_SLAB))
-		local_irq_save(flags);
+	if (IS_ENABLED(CONFIG_KASAN_SW_TAGS_IDENTIFY)) {
+		qobject_free(qlink);
+	} else {
+		object = qlink_to_object(qlink, cache);
 
-	___cache_free(cache, object, _THIS_IP_);
+		if (IS_ENABLED(CONFIG_SLAB))
+			local_irq_save(flags);
 
-	if (IS_ENABLED(CONFIG_SLAB))
-		local_irq_restore(flags);
+		___cache_free(cache, object, _THIS_IP_);
+
+		if (IS_ENABLED(CONFIG_SLAB))
+			local_irq_restore(flags);
+	}
 }
 
 static void qlist_free_all(struct qlist_head *q, struct kmem_cache *cache)
@@ -175,6 +195,8 @@ void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache)
 	unsigned long flags;
 	struct qlist_head *q;
 	struct qlist_head temp = QLIST_INIT;
+	struct kmem_cache *qobject_cache;
+	struct qlist_object *free_obj_info;
 
 	/*
 	 * Note: irq must be disabled until after we move the batch to the
@@ -187,7 +209,18 @@ void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache)
 	local_irq_save(flags);
 
 	q = this_cpu_ptr(&cpu_quarantine);
-	qlist_put(q, &info->quarantine_link, cache->size);
+	if (IS_ENABLED(CONFIG_KASAN_SW_TAGS_IDENTIFY)) {
+		free_obj_info = qobject_create(info, cache);
+		if (!free_obj_info) {
+			local_irq_restore(flags);
+			return;
+		}
+		qobject_cache = qlink_to_cache(&free_obj_info->qnode);
+		qlist_put(q, &free_obj_info->qnode, qobject_cache->size);
+	} else {
+		qlist_put(q, &info->quarantine_link, cache->size);
+	}
+
 	if (unlikely(q->bytes > QUARANTINE_PERCPU_SIZE)) {
 		qlist_move_all(q, &temp);
 
@@ -327,3 +360,81 @@ void quarantine_remove_cache(struct kmem_cache *cache)
 
 	synchronize_srcu(&remove_cache_srcu);
 }
+
+#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
+static bool qlist_find_object(struct qlist_head *from, void *arg)
+{
+	struct qlist_node *curr;
+	struct qlist_object *curr_obj;
+	struct qlist_object *target = (struct qlist_object *)arg;
+
+	if (unlikely(qlist_empty(from)))
+		return false;
+
+	curr = from->head;
+	while (curr) {
+		struct qlist_node *next = curr->next;
+
+		curr_obj = container_of(curr, struct qlist_object, qnode);
+		if (unlikely((target->addr >= curr_obj->addr) &&
+			(target->addr < (curr_obj->addr + curr_obj->size)))) {
+			target->free_track = curr_obj->free_track;
+			return true;
+		}
+
+		curr = next;
+	}
+	return false;
+}
+
+static int per_cpu_find_object(void *arg)
+{
+	struct qlist_head *q;
+
+	q = this_cpu_ptr(&cpu_quarantine);
+	return qlist_find_object(q, arg);
+}
+
+struct cpumask cpu_allowed_mask __read_mostly;
+
+bool quarantine_find_object(void *addr, struct kasan_track *free_track)
+{
+	unsigned long flags;
+	bool find = false;
+	int cpu, i, idx;
+	struct qlist_object target;
+
+	target.addr = (unsigned long)addr;
+
+	cpumask_copy(&cpu_allowed_mask, cpu_online_mask);
+	for_each_cpu(cpu, &cpu_allowed_mask) {
+		find = smp_call_on_cpu(cpu, per_cpu_find_object,
+				(void *)&target, true);
+		if (find) {
+			if (free_track)
+				*free_track = target.free_track;
+			return true;
+		}
+	}
+
+	raw_spin_lock_irqsave(&quarantine_lock, flags);
+	for (i = 0; i < QUARANTINE_BATCHES; i++) {
+		idx = quarantine_tail - i;
+		if (idx < 0)
+			idx += QUARANTINE_BATCHES;
+		if (qlist_empty(&global_quarantine[idx]))
+			continue;
+		find = qlist_find_object(&global_quarantine[idx],
+				(void *)&target);
+		if (find) {
+			if (free_track)
+				*free_track = target.free_track;
+			raw_spin_unlock_irqrestore(&quarantine_lock, flags);
+			return true;
+		}
+	}
+	raw_spin_unlock_irqrestore(&quarantine_lock, flags);
+
+	return false;
+}
+#endif
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index ca9418fe9232..3cbc24cd3d43 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -150,18 +150,27 @@ static void describe_object_addr(struct kmem_cache *cache, void *object,
 }
 
 static void describe_object(struct kmem_cache *cache, void *object,
-				const void *addr)
+				const void *tagged_addr)
 {
+	void *untagged_addr = reset_tag(tagged_addr);
 	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
+	struct kasan_track free_track;
 
 	if (cache->flags & SLAB_KASAN) {
-		print_track(&alloc_info->alloc_track, "Allocated");
-		pr_err("\n");
-		print_track(&alloc_info->free_track, "Freed");
-		pr_err("\n");
+		if (IS_ENABLED(CONFIG_KASAN_SW_TAGS_IDENTIFY) &&
+			quarantine_find_object((void *)tagged_addr,
+				&free_track)) {
+			print_track(&free_track, "Freed");
+			pr_err("\n");
+		} else {
+			print_track(&alloc_info->alloc_track, "Allocated");
+			pr_err("\n");
+			print_track(&alloc_info->free_track, "Freed");
+			pr_err("\n");
+		}
 	}
 
-	describe_object_addr(cache, object, addr);
+	describe_object_addr(cache, object, untagged_addr);
 }
 
 static inline bool kernel_or_module_addr(const void *addr)
@@ -180,23 +189,25 @@ static inline bool init_task_stack_addr(const void *addr)
 			sizeof(init_thread_union.stack));
 }
 
-static void print_address_description(void *addr)
+static void print_address_description(void *tagged_addr)
 {
-	struct page *page = addr_to_page(addr);
+	void *untagged_addr = reset_tag(tagged_addr);
+	struct page *page = addr_to_page(untagged_addr);
 
 	dump_stack();
 	pr_err("\n");
 
 	if (page && PageSlab(page)) {
 		struct kmem_cache *cache = page->slab_cache;
-		void *object = nearest_obj(cache, page,	addr);
+		void *object = nearest_obj(cache, page,	untagged_addr);
 
-		describe_object(cache, object, addr);
+		describe_object(cache, object, tagged_addr);
 	}
 
-	if (kernel_or_module_addr(addr) && !init_task_stack_addr(addr)) {
+	if (kernel_or_module_addr(untagged_addr) &&
+			!init_task_stack_addr(untagged_addr)) {
 		pr_err("The buggy address belongs to the variable:\n");
-		pr_err(" %pS\n", addr);
+		pr_err(" %pS\n", untagged_addr);
 	}
 
 	if (page) {
@@ -314,7 +325,7 @@ void kasan_report(unsigned long addr, size_t size,
 	pr_err("\n");
 
 	if (addr_has_shadow(untagged_addr)) {
-		print_address_description(untagged_addr);
+		print_address_description(tagged_addr);
 		pr_err("\n");
 		print_shadow_for_address(info.first_bad_addr);
 	} else {
diff --git a/mm/kasan/tags.c b/mm/kasan/tags.c
index 63fca3172659..68de6e44f74e 100644
--- a/mm/kasan/tags.c
+++ b/mm/kasan/tags.c
@@ -124,6 +124,46 @@ void check_memory_region(unsigned long addr, size_t size, bool write,
 	}
 }
 
+#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
+struct qlist_object *qobject_create(struct kasan_free_meta *info,
+				struct kmem_cache *cache)
+{
+	struct qlist_object *qobject_info;
+	void *object;
+
+	object = ((void *)info) - cache->kasan_info.free_meta_offset;
+	qobject_info = kmalloc(sizeof(struct qlist_object), GFP_NOWAIT);
+	if (!qobject_info)
+		return NULL;
+	qobject_info->addr = (unsigned long) object;
+	qobject_info->size = cache->object_size;
+	kasan_set_track(&qobject_info->free_track, GFP_NOWAIT);
+
+	return qobject_info;
+}
+
+void qobject_free(struct qlist_node *qlink)
+{
+	struct qlist_object *qobject = container_of(qlink,
+			struct qlist_object, qnode);
+	unsigned long flags;
+
+	struct kmem_cache *qobject_cache = qlink_to_cache(qlink);
+
+	if (IS_ENABLED(CONFIG_SLAB))
+		local_irq_save(flags);
+
+	/*
+	 * ___cache_free() free the qobject instead of kfree()
+	 * in order to be out of quarantine.
+	 */
+	___cache_free(qobject_cache, (void *)qobject, _THIS_IP_);
+
+	if (IS_ENABLED(CONFIG_SLAB))
+		local_irq_restore(flags);
+}
+#endif
+
 #define DEFINE_HWASAN_LOAD_STORE(size)					\
 	void __hwasan_load##size##_noabort(unsigned long addr)		\
 	{								\
diff --git a/mm/kasan/tags_report.c b/mm/kasan/tags_report.c
index 8eaf5f722271..63b0b1f381ff 100644
--- a/mm/kasan/tags_report.c
+++ b/mm/kasan/tags_report.c
@@ -36,7 +36,13 @@
 
 const char *get_bug_type(struct kasan_access_info *info)
 {
-	return "invalid-access";
+	if (IS_ENABLED(CONFIG_KASAN_SW_TAGS_IDENTIFY)) {
+		if (quarantine_find_object((void *)info->access_addr, NULL))
+			return "use-after-free";
+		else
+			return "out-of-bounds";
+	} else
+		return "invalid-access";
 }
 
 void *find_first_bad_addr(void *addr, size_t size)
diff --git a/mm/slub.c b/mm/slub.c
index 1b08fbcb7e61..751429d02846 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3004,7 +3004,7 @@ static __always_inline void slab_free(struct kmem_cache *s, struct page *page,
 		do_slab_free(s, page, head, tail, cnt, addr);
 }
 
-#ifdef CONFIG_KASAN_GENERIC
+#if defined(CONFIG_KASAN_GENERIC) || defined(CONFIG_KASAN_SW_TAGS_IDENTIFY)
 void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr)
 {
 	do_slab_free(cache, virt_to_head_page(x), x, NULL, 1, addr);
-- 
2.18.0

