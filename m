Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DC99C04E84
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 19:58:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3EFF520818
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 19:58:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="iFWYfCRR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3EFF520818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B05996B0005; Thu, 16 May 2019 15:58:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB5AF6B0006; Thu, 16 May 2019 15:58:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CC3F6B0007; Thu, 16 May 2019 15:58:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0986B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 15:58:16 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id q127so3782972qkd.2
        for <linux-mm@kvack.org>; Thu, 16 May 2019 12:58:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=7Q3Pd9gVjfkBZfHQeAcZj5EMeyC7pVTgLb1I61hawRU=;
        b=dgP1B7jYruKi3xCh0HbfBw8wvEn4wj38nWQl3xMO9nBcDXAyi0VXQTepCO1R1KN8Lf
         IqgM9kbsofOrJclcjlRZTvtCrXF5oHoToPqmaROHAIlfKgLm9e6kncsD3j7+twOWMGP4
         wOXuHurRk1Exu+8di1O/Psdc0XnswR17St8vV8umMPwEZFfOVmos5shJJX9Lup99paFN
         /DUnFMz8BXU1X8vAH2xpUZibVHLCccaUXnrcjl6r02EjlILIFqnJl+Wr5GdsJJrdaRwn
         Hoi8Cg6bEo6Z/boYDx74Di6C0mhE7+i2Q9bOwl5ygtAoqwKKsU5y0TjOsA7sYgpSkb7w
         cJBg==
X-Gm-Message-State: APjAAAUWcnMGcfzR4xz0NcBV5hOL6ABdCVVoUiF3k5KZm6ehhdgP9VbG
	dHB4/6KiVvO3jAdI713C/PgcgkF+OfrlCpQmuWpNbGkGPmqdFMwr987F0GV09K1Ygo/kEHKcyoQ
	FiqTOv5bKFj5Un3dER2j7UTmsxyBLMTVClewntzLbVpqWMee2qh12ny0Zuy77nFm7hw==
X-Received: by 2002:a0c:9649:: with SMTP id 9mr30432189qvy.43.1558036696209;
        Thu, 16 May 2019 12:58:16 -0700 (PDT)
X-Received: by 2002:a0c:9649:: with SMTP id 9mr30432071qvy.43.1558036694616;
        Thu, 16 May 2019 12:58:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558036694; cv=none;
        d=google.com; s=arc-20160816;
        b=S5uT2+0lvgkFydZBRWeVrM84Ym0lT/ocRKMEGnAHSCfl9ewRHB1j1Xrljt6ftiaTUO
         MeCEgym6ZH5N/cVMxzgA+jVXDLzxTdy9thmfQfNviqM/nfG80ZHtcdUqx2WncoDhlcpL
         AjNNnGljsxiVOUNJx0mlJAzVv+9qqWbPXJrX4iqnscMmq8hyzfq98jJHL1LYjLanWNVF
         lU5YnmgdjabH+PrHdBwA7T9sNDJb0DTR4f6qipEX+kEoczFnlQsfogLZMKeHsNUKQKI2
         YnrnpneLBXnOzDStF/r5eBNft+jeJYhm7h1JpkdKOORBH+jKX8Yq3Dy6a3AmlsZpGQWJ
         Cd4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=7Q3Pd9gVjfkBZfHQeAcZj5EMeyC7pVTgLb1I61hawRU=;
        b=JJ3L/oFTOl+yZuBPz9QL8FzRYKf0MXP9hb2igVa/vzeG9SC94zHPWhcL2Ijq1gv8+o
         uHjyfpOkc9g3QnFOCrxoqX79GSbswC70oU8zCDl6MKxkIYBqzHdmzLlL6Fp0BOzta5x1
         J1G6tQ6gK0wtegZdJUOz1JNpwJ4hj9P0xBtDBOp4bGfb5wLPRlOB3xdL1qGc0+DQbfpk
         Z+nkJendy83R5/8goLGOLzsuO8699TNuLUNL7cGHOOoIO/DIwh+nRD41FLKASCBT1YK8
         M214h9CPQfRqFQB0CMp5VjJ5WCWaku55tZASiSB7WMUE9UNiS/vT/Bcgk/i12gtlhTby
         AM5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=iFWYfCRR;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i54sor5159152qvc.14.2019.05.16.12.58.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 12:58:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=iFWYfCRR;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=7Q3Pd9gVjfkBZfHQeAcZj5EMeyC7pVTgLb1I61hawRU=;
        b=iFWYfCRRYAwkOEZq2CYURXChyBWupDWSf4fpv0o7B/Lt22vB6reh/j3sWQkLjAXsic
         ntzl+7LllwdKVgJNix6C27aBYBM2bQ+tO3W/MoN8DrIlHBPNyt7RNW9WTAb3Ps5K8WDI
         5Q6QzaQAYRzeT/JCHQecuULdjTDFXf2IxNOS6Ukb1qJFDQJLU3kuKyymh/nVMqBZRXT4
         rPlirMqebkvUAOy+dJsLB6rfNbXoBPEg3W9n9veW4Bil+CeG6vwnfuQDu/BtFyJaEM4K
         2Ec5dvGMmZ+mWS18bYatN8K3RZYdTyDvtaf+jZfU44F/jRnN89t9fno4mqkK5DgqfB69
         RBrg==
X-Google-Smtp-Source: APXvYqwxyB7R4q8MYTReU6DBPJMYRR+jbohC4axrrpcnzy+U2pP19Koa2IVl0z8K4lV6uG8kYDsEpw==
X-Received: by 2002:a0c:876c:: with SMTP id 41mr25728232qvi.175.1558036694121;
        Thu, 16 May 2019 12:58:14 -0700 (PDT)
Received: from qcai.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id g9sm2771007qtj.67.2019.05.16.12.58.12
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 12:58:13 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org,
	me@tobin.cc,
	cl@linux.com,
	vbabka@suse.cz,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	viro@zeniv.linux.org.uk,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] slab: remove /proc/slab_allocators
Date: Thu, 16 May 2019 15:57:41 -0400
Message-Id: <1558036661-17577-1-git-send-email-cai@lca.pw>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It turned out that DEBUG_SLAB_LEAK is still broken even after recent
recue efforts that when there is a large number of objects like
kmemleak_object which is normal on a debug kernel,

  # grep kmemleak /proc/slabinfo
  kmemleak_object   2243606 3436210 ...

reading /proc/slab_allocators could easily loop forever while processing
the kmemleak_object cache and any additional freeing or allocating
objects will trigger a reprocessing. To make a situation worse,
soft-lockups could easily happen in this sitatuion which will call
printk() to allocate more kmemleak objects to guarantee an infinite
loop.

Also, since it seems no one had noticed when it was totally broken
more than 2-year ago - see the commit fcf88917dd43 ("slab: fix a crash
by reading /proc/slab_allocators"), probably nobody cares about it
anymore due to the decline of the SLAB. Just remove it entirely.

Suggested-by: Vlastimil Babka <vbabka@suse.cz>
Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Qian Cai <cai@lca.pw>
---
 include/linux/slab_def.h |   3 -
 lib/Kconfig.debug        |   4 -
 mm/slab.c                | 226 +----------------------------------------------
 3 files changed, 1 insertion(+), 232 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 9a5eafb7145b..abc7de77b988 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -61,9 +61,6 @@ struct kmem_cache {
 	atomic_t allocmiss;
 	atomic_t freehit;
 	atomic_t freemiss;
-#ifdef CONFIG_DEBUG_SLAB_LEAK
-	atomic_t store_user_clean;
-#endif
 
 	/*
 	 * If debugging is enabled, then the allocator can add additional
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index fdfa173651eb..eae43952902e 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -542,10 +542,6 @@ config DEBUG_SLAB
 	  allocation as well as poisoning memory on free to catch use of freed
 	  memory. This can make kmalloc/kfree-intensive workloads much slower.
 
-config DEBUG_SLAB_LEAK
-	bool "Memory leak debugging"
-	depends on DEBUG_SLAB
-
 config SLUB_DEBUG_ON
 	bool "SLUB debugging on by default"
 	depends on SLUB && SLUB_DEBUG
diff --git a/mm/slab.c b/mm/slab.c
index 2915d912e89a..f7117ad9b3a3 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -362,29 +362,6 @@ static void **dbg_userword(struct kmem_cache *cachep, void *objp)
 
 #endif
 
-#ifdef CONFIG_DEBUG_SLAB_LEAK
-
-static inline bool is_store_user_clean(struct kmem_cache *cachep)
-{
-	return atomic_read(&cachep->store_user_clean) == 1;
-}
-
-static inline void set_store_user_clean(struct kmem_cache *cachep)
-{
-	atomic_set(&cachep->store_user_clean, 1);
-}
-
-static inline void set_store_user_dirty(struct kmem_cache *cachep)
-{
-	if (is_store_user_clean(cachep))
-		atomic_set(&cachep->store_user_clean, 0);
-}
-
-#else
-static inline void set_store_user_dirty(struct kmem_cache *cachep) {}
-
-#endif
-
 /*
  * Do not go above this order unless 0 objects fit into the slab or
  * overridden on the command line.
@@ -2552,11 +2529,6 @@ static void *slab_get_obj(struct kmem_cache *cachep, struct page *page)
 	objp = index_to_obj(cachep, page, get_free_obj(page, page->active));
 	page->active++;
 
-#if DEBUG
-	if (cachep->flags & SLAB_STORE_USER)
-		set_store_user_dirty(cachep);
-#endif
-
 	return objp;
 }
 
@@ -2762,10 +2734,8 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
 		*dbg_redzone1(cachep, objp) = RED_INACTIVE;
 		*dbg_redzone2(cachep, objp) = RED_INACTIVE;
 	}
-	if (cachep->flags & SLAB_STORE_USER) {
-		set_store_user_dirty(cachep);
+	if (cachep->flags & SLAB_STORE_USER)
 		*dbg_userword(cachep, objp) = (void *)caller;
-	}
 
 	objnr = obj_to_index(cachep, page, objp);
 
@@ -4184,200 +4154,6 @@ ssize_t slabinfo_write(struct file *file, const char __user *buffer,
 	return res;
 }
 
-#ifdef CONFIG_DEBUG_SLAB_LEAK
-
-static inline int add_caller(unsigned long *n, unsigned long v)
-{
-	unsigned long *p;
-	int l;
-	if (!v)
-		return 1;
-	l = n[1];
-	p = n + 2;
-	while (l) {
-		int i = l/2;
-		unsigned long *q = p + 2 * i;
-		if (*q == v) {
-			q[1]++;
-			return 1;
-		}
-		if (*q > v) {
-			l = i;
-		} else {
-			p = q + 2;
-			l -= i + 1;
-		}
-	}
-	if (++n[1] == n[0])
-		return 0;
-	memmove(p + 2, p, n[1] * 2 * sizeof(unsigned long) - ((void *)p - (void *)n));
-	p[0] = v;
-	p[1] = 1;
-	return 1;
-}
-
-static void handle_slab(unsigned long *n, struct kmem_cache *c,
-						struct page *page)
-{
-	void *p;
-	int i, j;
-	unsigned long v;
-
-	if (n[0] == n[1])
-		return;
-	for (i = 0, p = page->s_mem; i < c->num; i++, p += c->size) {
-		bool active = true;
-
-		for (j = page->active; j < c->num; j++) {
-			if (get_free_obj(page, j) == i) {
-				active = false;
-				break;
-			}
-		}
-
-		if (!active)
-			continue;
-
-		/*
-		 * probe_kernel_read() is used for DEBUG_PAGEALLOC. page table
-		 * mapping is established when actual object allocation and
-		 * we could mistakenly access the unmapped object in the cpu
-		 * cache.
-		 */
-		if (probe_kernel_read(&v, dbg_userword(c, p), sizeof(v)))
-			continue;
-
-		if (!add_caller(n, v))
-			return;
-	}
-}
-
-static void show_symbol(struct seq_file *m, unsigned long address)
-{
-#ifdef CONFIG_KALLSYMS
-	unsigned long offset, size;
-	char modname[MODULE_NAME_LEN], name[KSYM_NAME_LEN];
-
-	if (lookup_symbol_attrs(address, &size, &offset, modname, name) == 0) {
-		seq_printf(m, "%s+%#lx/%#lx", name, offset, size);
-		if (modname[0])
-			seq_printf(m, " [%s]", modname);
-		return;
-	}
-#endif
-	seq_printf(m, "%px", (void *)address);
-}
-
-static int leaks_show(struct seq_file *m, void *p)
-{
-	struct kmem_cache *cachep = list_entry(p, struct kmem_cache,
-					       root_caches_node);
-	struct page *page;
-	struct kmem_cache_node *n;
-	const char *name;
-	unsigned long *x = m->private;
-	int node;
-	int i;
-
-	if (!(cachep->flags & SLAB_STORE_USER))
-		return 0;
-	if (!(cachep->flags & SLAB_RED_ZONE))
-		return 0;
-
-	/*
-	 * Set store_user_clean and start to grab stored user information
-	 * for all objects on this cache. If some alloc/free requests comes
-	 * during the processing, information would be wrong so restart
-	 * whole processing.
-	 */
-	do {
-		drain_cpu_caches(cachep);
-		/*
-		 * drain_cpu_caches() could make kmemleak_object and
-		 * debug_objects_cache dirty, so reset afterwards.
-		 */
-		set_store_user_clean(cachep);
-
-		x[1] = 0;
-
-		for_each_kmem_cache_node(cachep, node, n) {
-
-			check_irq_on();
-			spin_lock_irq(&n->list_lock);
-
-			list_for_each_entry(page, &n->slabs_full, slab_list)
-				handle_slab(x, cachep, page);
-			list_for_each_entry(page, &n->slabs_partial, slab_list)
-				handle_slab(x, cachep, page);
-			spin_unlock_irq(&n->list_lock);
-		}
-	} while (!is_store_user_clean(cachep));
-
-	name = cachep->name;
-	if (x[0] == x[1]) {
-		/* Increase the buffer size */
-		mutex_unlock(&slab_mutex);
-		m->private = kcalloc(x[0] * 4, sizeof(unsigned long),
-				     GFP_KERNEL);
-		if (!m->private) {
-			/* Too bad, we are really out */
-			m->private = x;
-			mutex_lock(&slab_mutex);
-			return -ENOMEM;
-		}
-		*(unsigned long *)m->private = x[0] * 2;
-		kfree(x);
-		mutex_lock(&slab_mutex);
-		/* Now make sure this entry will be retried */
-		m->count = m->size;
-		return 0;
-	}
-	for (i = 0; i < x[1]; i++) {
-		seq_printf(m, "%s: %lu ", name, x[2*i+3]);
-		show_symbol(m, x[2*i+2]);
-		seq_putc(m, '\n');
-	}
-
-	return 0;
-}
-
-static const struct seq_operations slabstats_op = {
-	.start = slab_start,
-	.next = slab_next,
-	.stop = slab_stop,
-	.show = leaks_show,
-};
-
-static int slabstats_open(struct inode *inode, struct file *file)
-{
-	unsigned long *n;
-
-	n = __seq_open_private(file, &slabstats_op, PAGE_SIZE);
-	if (!n)
-		return -ENOMEM;
-
-	*n = PAGE_SIZE / (2 * sizeof(unsigned long));
-
-	return 0;
-}
-
-static const struct file_operations proc_slabstats_operations = {
-	.open		= slabstats_open,
-	.read		= seq_read,
-	.llseek		= seq_lseek,
-	.release	= seq_release_private,
-};
-#endif
-
-static int __init slab_proc_init(void)
-{
-#ifdef CONFIG_DEBUG_SLAB_LEAK
-	proc_create("slab_allocators", 0, NULL, &proc_slabstats_operations);
-#endif
-	return 0;
-}
-module_init(slab_proc_init);
-
 #ifdef CONFIG_HARDENED_USERCOPY
 /*
  * Rejects incorrectly sized objects and objects that are to be copied
-- 
1.8.3.1

