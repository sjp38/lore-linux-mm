Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBA71C49ED6
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 00:29:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B27E2089F
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 00:29:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="reevYIbB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B27E2089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B3796B028B; Wed, 11 Sep 2019 20:29:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 03B906B028C; Wed, 11 Sep 2019 20:29:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E953B6B028D; Wed, 11 Sep 2019 20:29:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0064.hostedemail.com [216.40.44.64])
	by kanga.kvack.org (Postfix) with ESMTP id C269C6B028B
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 20:29:37 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 5977A1F23A
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 00:29:37 +0000 (UTC)
X-FDA: 75924385194.11.egg98_19b60794d3d13
X-HE-Tag: egg98_19b60794d3d13
X-Filterd-Recvd-Size: 9927
Received: from mail-pf1-f202.google.com (mail-pf1-f202.google.com [209.85.210.202])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 00:29:36 +0000 (UTC)
Received: by mail-pf1-f202.google.com with SMTP id g15so16987953pfb.8
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 17:29:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=uzRVa/RHNdYkg1IHiO1rEv5ugF6T1ClH+7w2oKbnwMc=;
        b=reevYIbBpu8qm5Syfb7KaiDsleUA1e7n1fMPaAtKblnilYbRmyLrNKnFVygczUNOaC
         rbfRBCNiQ+J/oOw01EI/XtsHetn9BKDvU6xYeRWQ8iwr+gYVT8HDdWH4fvspbEwe3NGc
         rfFlyKtlUt4wsegLwzUgRGQu6A2HGC981pHEpuJFEzqXrFbMFKM4RBfnYPMbsvG4sanX
         cMS0WVZmBtzWKJ9IS5BQRvDTQEnqzbRscD55f5Df8ImrKUeR996sFxL4jYb0unAMRX42
         VCgX/IOpvSf6DCIxsKzh2czffBa60jeg80ZOcPcpCtKTSqQPPliKf/r991sLp+HkEEDh
         U8jQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:in-reply-to:message-id:mime-version
         :references:subject:from:to:cc;
        bh=uzRVa/RHNdYkg1IHiO1rEv5ugF6T1ClH+7w2oKbnwMc=;
        b=VpVy0WHQX7qRlI+Y8XQIWX+kuziNuVXifLtmIQmQnyJkgVpZgFtPEsiLLGmdoHXGDc
         JdvqFiKGPXCIOP5TaEutfDDuqqoflgItWfnCO18D8h+SSJsBtVXjXIX17O/9aOxEZ/Aq
         xGHNINBlvl+psIokZA/70P/7f1fJD477DbBp/wwidXz27bx4h7ozbu1F8G/IThtZi11Y
         756lxJ2WxWcWIGEKw5NkGGuxLRzYLLAV7LkLGwx5g42sz+3OKu46Etrh/cOcAL9qB0U1
         bjpghUhQ6Gu4WiA94bo4HwWpaU/q7czg31uBrff4faL1uSMi0fmFL7CFHirMcNcTPo++
         Y9gw==
X-Gm-Message-State: APjAAAXKzaSJQrQzUpXeqPlGhDdcEHrM63kRCxLqyEsCkPqKJ7DRQTX/
	hK/RjBAkRFiEs/LaTMYVdpe/G5bekUo=
X-Google-Smtp-Source: APXvYqyJcNIZcsl0b9NOFSki+grLmlxvDyaynkn792Wsw0UtMxyJV6e1qsRj2iFCHRvd+xD8o5J35UoEtVM=
X-Received: by 2002:a63:5920:: with SMTP id n32mr29546334pgb.352.1568248175321;
 Wed, 11 Sep 2019 17:29:35 -0700 (PDT)
Date: Wed, 11 Sep 2019 18:29:28 -0600
In-Reply-To: <20190912002929.78873-1-yuzhao@google.com>
Message-Id: <20190912002929.78873-2-yuzhao@google.com>
Mime-Version: 1.0
References: <20190911071331.770ecddff6a085330bf2b5f2@linux-foundation.org> <20190912002929.78873-1-yuzhao@google.com>
X-Mailer: git-send-email 2.23.0.162.g0b9fbb3734-goog
Subject: [PATCH 2/3] mm: avoid slub allocation while holding list_lock
From: Yu Zhao <yuzhao@google.com>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Yu Zhao <yuzhao@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If we are already under list_lock, don't call kmalloc(). Otherwise we
will run into deadlock because kmalloc() also tries to grab the same
lock.

Instead, statically allocate bitmap in struct kmem_cache_node. Given
currently page->objects has 15 bits, we bloat the per-node struct by
4K. So we waste some memory but only do so when slub debug is on.

  WARNING: possible recursive locking detected
  --------------------------------------------
  mount-encrypted/4921 is trying to acquire lock:
  (&(&n->list_lock)->rlock){-.-.}, at: ___slab_alloc+0x104/0x437

  but task is already holding lock:
  (&(&n->list_lock)->rlock){-.-.}, at: __kmem_cache_shutdown+0x81/0x3cb

  other info that might help us debug this:
   Possible unsafe locking scenario:

         CPU0
         ----
    lock(&(&n->list_lock)->rlock);
    lock(&(&n->list_lock)->rlock);

   *** DEADLOCK ***

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 include/linux/slub_def.h |  4 ++++
 mm/slab.h                |  1 +
 mm/slub.c                | 44 ++++++++++++++--------------------------
 3 files changed, 20 insertions(+), 29 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index d2153789bd9f..719d43574360 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -9,6 +9,10 @@
  */
 #include <linux/kobject.h>
 
+#define OO_SHIFT	15
+#define OO_MASK		((1 << OO_SHIFT) - 1)
+#define MAX_OBJS_PER_PAGE	32767 /* since page.objects is u15 */
+
 enum stat_item {
 	ALLOC_FASTPATH,		/* Allocation from cpu slab */
 	ALLOC_SLOWPATH,		/* Allocation by getting a new cpu slab */
diff --git a/mm/slab.h b/mm/slab.h
index 9057b8056b07..2d8639835db1 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -556,6 +556,7 @@ struct kmem_cache_node {
 	atomic_long_t nr_slabs;
 	atomic_long_t total_objects;
 	struct list_head full;
+	unsigned long object_map[BITS_TO_LONGS(MAX_OBJS_PER_PAGE)];
 #endif
 #endif
 
diff --git a/mm/slub.c b/mm/slub.c
index 62053ceb4464..f28072c9f2ce 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -187,10 +187,6 @@ static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
  */
 #define DEBUG_METADATA_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER)
 
-#define OO_SHIFT	15
-#define OO_MASK		((1 << OO_SHIFT) - 1)
-#define MAX_OBJS_PER_PAGE	32767 /* since page.objects is u15 */
-
 /* Internal SLUB flags */
 /* Poison object */
 #define __OBJECT_POISON		((slab_flags_t __force)0x80000000U)
@@ -454,6 +450,8 @@ static void get_map(struct kmem_cache *s, struct page *page, unsigned long *map)
 	void *p;
 	void *addr = page_address(page);
 
+	bitmap_zero(map, page->objects);
+
 	for (p = page->freelist; p; p = get_freepointer(s, p))
 		set_bit(slab_index(p, s, addr), map);
 }
@@ -3680,14 +3678,12 @@ static int kmem_cache_open(struct kmem_cache *s, slab_flags_t flags)
 }
 
 static void list_slab_objects(struct kmem_cache *s, struct page *page,
-							const char *text)
+			      unsigned long *map, const char *text)
 {
 #ifdef CONFIG_SLUB_DEBUG
 	void *addr = page_address(page);
 	void *p;
-	unsigned long *map = bitmap_zalloc(page->objects, GFP_ATOMIC);
-	if (!map)
-		return;
+
 	slab_err(s, page, text, s->name);
 	slab_lock(page);
 
@@ -3699,8 +3695,8 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
 			print_tracking(s, p);
 		}
 	}
+
 	slab_unlock(page);
-	bitmap_free(map);
 #endif
 }
 
@@ -3721,7 +3717,7 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
 			remove_partial(n, page);
 			list_add(&page->slab_list, &discard);
 		} else {
-			list_slab_objects(s, page,
+			list_slab_objects(s, page, n->object_map,
 			"Objects remaining in %s on __kmem_cache_shutdown()");
 		}
 	}
@@ -4397,7 +4393,6 @@ static int validate_slab(struct kmem_cache *s, struct page *page,
 		return 0;
 
 	/* Now we know that a valid freelist exists */
-	bitmap_zero(map, page->objects);
 
 	get_map(s, page, map);
 	for_each_object(p, s, addr, page->objects) {
@@ -4422,7 +4417,7 @@ static void validate_slab_slab(struct kmem_cache *s, struct page *page,
 }
 
 static int validate_slab_node(struct kmem_cache *s,
-		struct kmem_cache_node *n, unsigned long *map)
+		struct kmem_cache_node *n)
 {
 	unsigned long count = 0;
 	struct page *page;
@@ -4431,7 +4426,7 @@ static int validate_slab_node(struct kmem_cache *s,
 	spin_lock_irqsave(&n->list_lock, flags);
 
 	list_for_each_entry(page, &n->partial, slab_list) {
-		validate_slab_slab(s, page, map);
+		validate_slab_slab(s, page, n->object_map);
 		count++;
 	}
 	if (count != n->nr_partial)
@@ -4442,7 +4437,7 @@ static int validate_slab_node(struct kmem_cache *s,
 		goto out;
 
 	list_for_each_entry(page, &n->full, slab_list) {
-		validate_slab_slab(s, page, map);
+		validate_slab_slab(s, page, n->object_map);
 		count++;
 	}
 	if (count != atomic_long_read(&n->nr_slabs))
@@ -4459,15 +4454,11 @@ static long validate_slab_cache(struct kmem_cache *s)
 	int node;
 	unsigned long count = 0;
 	struct kmem_cache_node *n;
-	unsigned long *map = bitmap_alloc(oo_objects(s->max), GFP_KERNEL);
-
-	if (!map)
-		return -ENOMEM;
 
 	flush_all(s);
 	for_each_kmem_cache_node(s, node, n)
-		count += validate_slab_node(s, n, map);
-	bitmap_free(map);
+		count += validate_slab_node(s, n);
+
 	return count;
 }
 /*
@@ -4603,9 +4594,7 @@ static void process_slab(struct loc_track *t, struct kmem_cache *s,
 	void *addr = page_address(page);
 	void *p;
 
-	bitmap_zero(map, page->objects);
 	get_map(s, page, map);
-
 	for_each_object(p, s, addr, page->objects)
 		if (!test_bit(slab_index(p, s, addr), map))
 			add_location(t, s, get_track(s, p, alloc));
@@ -4619,11 +4608,9 @@ static int list_locations(struct kmem_cache *s, char *buf,
 	struct loc_track t = { 0, 0, NULL };
 	int node;
 	struct kmem_cache_node *n;
-	unsigned long *map = bitmap_alloc(oo_objects(s->max), GFP_KERNEL);
 
-	if (!map || !alloc_loc_track(&t, PAGE_SIZE / sizeof(struct location),
-				     GFP_KERNEL)) {
-		bitmap_free(map);
+	if (!alloc_loc_track(&t, PAGE_SIZE / sizeof(struct location),
+			     GFP_KERNEL)) {
 		return sprintf(buf, "Out of memory\n");
 	}
 	/* Push back cpu slabs */
@@ -4638,9 +4625,9 @@ static int list_locations(struct kmem_cache *s, char *buf,
 
 		spin_lock_irqsave(&n->list_lock, flags);
 		list_for_each_entry(page, &n->partial, slab_list)
-			process_slab(&t, s, page, alloc, map);
+			process_slab(&t, s, page, alloc, n->object_map);
 		list_for_each_entry(page, &n->full, slab_list)
-			process_slab(&t, s, page, alloc, map);
+			process_slab(&t, s, page, alloc, n->object_map);
 		spin_unlock_irqrestore(&n->list_lock, flags);
 	}
 
@@ -4689,7 +4676,6 @@ static int list_locations(struct kmem_cache *s, char *buf,
 	}
 
 	free_loc_track(&t);
-	bitmap_free(map);
 	if (!t.count)
 		len += sprintf(buf, "No data\n");
 	return len;
-- 
2.23.0.162.g0b9fbb3734-goog


