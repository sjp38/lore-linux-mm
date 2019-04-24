Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A7DBC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 11:12:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAE7A218D3
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 11:12:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAE7A218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D4506B0007; Wed, 24 Apr 2019 07:12:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45E666B0008; Wed, 24 Apr 2019 07:12:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28B366B000A; Wed, 24 Apr 2019 07:12:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id C9B2B6B0007
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:12:35 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id n11so2640776wmh.2
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 04:12:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WMpspZdiTfo3o0Ccu0Zw52cfcU4CJMh6yc6VE/EvfkE=;
        b=YmH4/UeRbZdpGrRkYmoJjW8K1aKGzts5xWacJVHb9rdFwjjoE4OSluk448oSBO7OG3
         kXQOa99NXl72gxe3vEoab0Y1pdmenjvXPvpMv23OgJ4d5Zy/35t4KMZC6cEsKo4ZDusj
         6pMef0tVxTMO7ERxS0+QyfJ4YVdtuHVa0p0fqsWMwEWO4yJm+XEKffvXF3K69RNiZVwe
         zt/6g2vZV8EYhI9QCPaIt5ANclet/ANKwpbqHFn5diFZUpe3NKmTEnTz09EIWo9x2g/c
         0Raqs5+l/W/CuqBrWCrxW5fy9pkC+k0m3hs9GRoq2nQGh6OA63/8TGQ70FUUEYYJm3ki
         /1bg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: APjAAAWflboGGt71RgSTS3rXuCJvP8yjBdnhppcpRFwy5U3agro9h5yB
	iNGQmdU2FQEBJHEexYEV8y1VpRgaaW105qPG3qvHMuU/LmPjMcg679Yqqc3K85snYc5Vvitxf5H
	DLmuxKQTr92FMyZVFqXvYIpybxaDGjLMqKjBMoord274OzhdEFnvrf1y3+RIjHPCcQQ==
X-Received: by 2002:adf:f68c:: with SMTP id v12mr4568985wrp.40.1556104355331;
        Wed, 24 Apr 2019 04:12:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXnS5Ioke8EcZpblCbCG+YutpZWNd+CLct/h+Zeaiv8xDmK2xLhuElIswPeygjtoD7PAcf
X-Received: by 2002:adf:f68c:: with SMTP id v12mr4568915wrp.40.1556104354145;
        Wed, 24 Apr 2019 04:12:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556104354; cv=none;
        d=google.com; s=arc-20160816;
        b=SI3wBn+U0XESqtnyxaocR036hfHGJsxT+bWm4pkfY1LT0LA4Se89je69A4Gonei2GH
         E1NSBFRUKPewI9t5fWuywfVxT945TZQiwQ0KUHV/QTbimg228+/7cjTFIaQn+rIfXOin
         CwpBzxHMgIEZzbIMDM23oFu5iP5COK95JaJDkkyLMNWadwzmFeyZbTBimR1H41+9A5IM
         tKc9hV6/1L49PtqDN79b8eBbNQ58rqF1S8RI5t0VusfOlw6H+7LgP7dzef1VGpjkTxep
         sXJLWdA6CcfMWhLNtlQ0NnoCCMEGKopuiAw79aKaF7tX2zLJY/Tp5bE7j+eO+2cKED6O
         mz0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=WMpspZdiTfo3o0Ccu0Zw52cfcU4CJMh6yc6VE/EvfkE=;
        b=YlljcXZZlquTbTzUweQOqmX378lTxc3ULeHWGqvqp2fZAqMXo0iK7eDIRkGm5avbAU
         FdZB/BzsaPV79UfewH6LwGNB0AjuTy9igcqa8UFXIh5ROm3wt+YIXEJyDAarhpyRVAPR
         wc2g6C75V5ordeaDljOUu3ljAQMd957eBLJVB2ElHovLjOX8PEnU5yqa1Tvne7+kbbJ+
         ui1/or6hAIIt+VFCRcvVcCs2CU//28QXchlcUV6xZPelBo6l1ze/iQEQ8Vdwo1WNaWmI
         N2ZlIXEiFAEeE/kz/6lDCZn2pEgtv0vaO17KAc45k+lz2x+QGl3Sj1tWsRIyHeMoKEkf
         BUNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id e9si13497081wrr.339.2019.04.24.04.12.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 24 Apr 2019 04:12:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from localhost ([127.0.0.1] helo=flow.W.breakpoint.cc)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1hJFpI-0006KY-BW; Wed, 24 Apr 2019 13:12:32 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: linux-mm@kvack.org
Cc: tglx@linutronix.de,
	frederic@kernel.org,
	Christoph Lameter <cl@linux.com>,
	anna-maria@linutronix.de,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 2/4] mm/swap: Add static key dependent pagevec locking
Date: Wed, 24 Apr 2019 13:12:06 +0200
Message-Id: <20190424111208.24459-3-bigeasy@linutronix.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190424111208.24459-1-bigeasy@linutronix.de>
References: <20190424111208.24459-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Thomas Gleixner <tglx@linutronix.de>

The locking of struct pagevec is done by disabling preemption. In case the
struct has be accessed form interrupt context then interrupts are
disabled. This means the struct can only be accessed locally from the
CPU. There is also no lockdep coverage which would scream during if it
accessed from wrong context.

Create struct swap_pagevec which contains of a pagevec member and a
spin_lock_t. Introduce a static key, which changes the locking behavior
only if the key is set in the following way: Before the struct is accessed
the spin_lock has to be acquired instead of using preempt_disable(). Since
the struct is used CPU-locally there is no spinning on the lock but the
lock is acquired immediately. If the struct is accessed from interrupt
context, spin_lock_irqsave() is used.

No functional change yet because static key is not enabled.

[anna-maria: introduce static key]
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/compaction.c |  14 ++--
 mm/internal.h   |   2 +
 mm/swap.c       | 186 +++++++++++++++++++++++++++++++++++++++---------
 3 files changed, 165 insertions(+), 37 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 3319e0872d014..ec47c96186771 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -2224,10 +2224,16 @@ compact_zone(struct compact_control *cc, struct capture_control *capc)
 				block_start_pfn(cc->migrate_pfn, cc->order);
 
 			if (last_migrated_pfn < current_block_start) {
-				cpu = get_cpu();
-				lru_add_drain_cpu(cpu);
-				drain_local_pages(cc->zone);
-				put_cpu();
+				if (static_branch_unlikely(&use_pvec_lock)) {
+					cpu = get_cpu();
+					lru_add_drain_cpu(cpu);
+					drain_local_pages(cc->zone);
+					put_cpu();
+				} else {
+					cpu = raw_smp_processor_id();
+					lru_add_drain_cpu(cpu);
+					drain_cpu_pages(cpu, cc->zone);
+				}
 				/* No more flushing until we migrate again */
 				last_migrated_pfn = 0;
 			}
diff --git a/mm/internal.h b/mm/internal.h
index 9eeaf2b95166f..ddfa760e61652 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -36,6 +36,8 @@
 /* Do not use these with a slab allocator */
 #define GFP_SLAB_BUG_MASK (__GFP_DMA32|__GFP_HIGHMEM|~__GFP_BITS_MASK)
 
+extern struct static_key_false use_pvec_lock;
+
 void page_writeback_init(void);
 
 vm_fault_t do_swap_page(struct vm_fault *vmf);
diff --git a/mm/swap.c b/mm/swap.c
index 301ed4e043205..136c80480dbde 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -43,14 +43,107 @@
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
 
-static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
-static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
-static DEFINE_PER_CPU(struct pagevec, lru_deactivate_file_pvecs);
-static DEFINE_PER_CPU(struct pagevec, lru_lazyfree_pvecs);
+DEFINE_STATIC_KEY_FALSE(use_pvec_lock);
+
+struct swap_pagevec {
+	spinlock_t	lock;
+	struct pagevec	pvec;
+};
+
+#define DEFINE_PER_CPU_PAGEVEC(lvar)				\
+	DEFINE_PER_CPU(struct swap_pagevec, lvar) = {		\
+		.lock = __SPIN_LOCK_UNLOCKED((lvar).lock) }
+
+static DEFINE_PER_CPU_PAGEVEC(lru_add_pvec);
+static DEFINE_PER_CPU_PAGEVEC(lru_rotate_pvecs);
+static DEFINE_PER_CPU_PAGEVEC(lru_deactivate_file_pvecs);
+static DEFINE_PER_CPU_PAGEVEC(lru_lazyfree_pvecs);
 #ifdef CONFIG_SMP
-static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
+static DEFINE_PER_CPU_PAGEVEC(activate_page_pvecs);
 #endif
 
+static inline
+struct swap_pagevec *lock_swap_pvec(struct swap_pagevec __percpu *p)
+{
+	struct swap_pagevec *swpvec;
+
+	if (static_branch_likely(&use_pvec_lock)) {
+		swpvec = raw_cpu_ptr(p);
+
+		spin_lock(&swpvec->lock);
+	} else {
+		swpvec = &get_cpu_var(*p);
+	}
+	return swpvec;
+}
+
+static inline struct swap_pagevec *
+lock_swap_pvec_cpu(struct swap_pagevec __percpu *p, int cpu)
+{
+	struct swap_pagevec *swpvec = per_cpu_ptr(p, cpu);
+
+	if (static_branch_likely(&use_pvec_lock))
+		spin_lock(&swpvec->lock);
+
+	return swpvec;
+}
+
+static inline struct swap_pagevec *
+lock_swap_pvec_irqsave(struct swap_pagevec __percpu *p, unsigned long *flags)
+{
+	struct swap_pagevec *swpvec;
+
+	if (static_branch_likely(&use_pvec_lock)) {
+		swpvec = raw_cpu_ptr(p);
+
+		spin_lock_irqsave(&swpvec->lock, (*flags));
+	} else {
+		local_irq_save(*flags);
+
+		swpvec = this_cpu_ptr(p);
+	}
+	return swpvec;
+}
+
+static inline struct swap_pagevec *
+lock_swap_pvec_cpu_irqsave(struct swap_pagevec __percpu *p, int cpu,
+			   unsigned long *flags)
+{
+	struct swap_pagevec *swpvec = per_cpu_ptr(p, cpu);
+
+	if (static_branch_likely(&use_pvec_lock))
+		spin_lock_irqsave(&swpvec->lock, *flags);
+	else
+		local_irq_save(*flags);
+
+	return swpvec;
+}
+
+static inline void unlock_swap_pvec(struct swap_pagevec *swpvec,
+				    struct swap_pagevec __percpu *p)
+{
+	if (static_branch_likely(&use_pvec_lock))
+		spin_unlock(&swpvec->lock);
+	else
+		put_cpu_var(*p);
+
+}
+
+static inline void unlock_swap_pvec_cpu(struct swap_pagevec *swpvec)
+{
+	if (static_branch_likely(&use_pvec_lock))
+		spin_unlock(&swpvec->lock);
+}
+
+static inline void
+unlock_swap_pvec_irqrestore(struct swap_pagevec *swpvec, unsigned long flags)
+{
+	if (static_branch_likely(&use_pvec_lock))
+		spin_unlock_irqrestore(&swpvec->lock, flags);
+	else
+		local_irq_restore(flags);
+}
+
 /*
  * This path almost never happens for VM activity - pages are normally
  * freed via pagevecs.  But it gets used by networking.
@@ -248,15 +341,17 @@ void rotate_reclaimable_page(struct page *page)
 {
 	if (!PageLocked(page) && !PageDirty(page) &&
 	    !PageUnevictable(page) && PageLRU(page)) {
+		struct swap_pagevec *swpvec;
 		struct pagevec *pvec;
 		unsigned long flags;
 
 		get_page(page);
-		local_irq_save(flags);
-		pvec = this_cpu_ptr(&lru_rotate_pvecs);
+
+		swpvec = lock_swap_pvec_irqsave(&lru_rotate_pvecs, &flags);
+		pvec = &swpvec->pvec;
 		if (!pagevec_add(pvec, page) || PageCompound(page))
 			pagevec_move_tail(pvec);
-		local_irq_restore(flags);
+		unlock_swap_pvec_irqrestore(swpvec, flags);
 	}
 }
 
@@ -291,27 +386,32 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
 #ifdef CONFIG_SMP
 static void activate_page_drain(int cpu)
 {
-	struct pagevec *pvec = &per_cpu(activate_page_pvecs, cpu);
+	struct swap_pagevec *swpvec = lock_swap_pvec_cpu(&activate_page_pvecs, cpu);
+	struct pagevec *pvec = &swpvec->pvec;
 
 	if (pagevec_count(pvec))
 		pagevec_lru_move_fn(pvec, __activate_page, NULL);
+	unlock_swap_pvec_cpu(swpvec);
 }
 
 static bool need_activate_page_drain(int cpu)
 {
-	return pagevec_count(&per_cpu(activate_page_pvecs, cpu)) != 0;
+	return pagevec_count(per_cpu_ptr(&activate_page_pvecs.pvec, cpu)) != 0;
 }
 
 void activate_page(struct page *page)
 {
 	page = compound_head(page);
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
-		struct pagevec *pvec = &get_cpu_var(activate_page_pvecs);
+		struct swap_pagevec *swpvec;
+		struct pagevec *pvec;
 
 		get_page(page);
+		swpvec = lock_swap_pvec(&activate_page_pvecs);
+		pvec = &swpvec->pvec;
 		if (!pagevec_add(pvec, page) || PageCompound(page))
 			pagevec_lru_move_fn(pvec, __activate_page, NULL);
-		put_cpu_var(activate_page_pvecs);
+		unlock_swap_pvec(swpvec, &activate_page_pvecs);
 	}
 }
 
@@ -333,7 +433,8 @@ void activate_page(struct page *page)
 
 static void __lru_cache_activate_page(struct page *page)
 {
-	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
+	struct swap_pagevec *swpvec = lock_swap_pvec(&lru_add_pvec);
+	struct pagevec *pvec = &swpvec->pvec;
 	int i;
 
 	/*
@@ -355,7 +456,7 @@ static void __lru_cache_activate_page(struct page *page)
 		}
 	}
 
-	put_cpu_var(lru_add_pvec);
+	unlock_swap_pvec(swpvec, &lru_add_pvec);
 }
 
 /*
@@ -397,12 +498,13 @@ EXPORT_SYMBOL(mark_page_accessed);
 
 static void __lru_cache_add(struct page *page)
 {
-	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
+	struct swap_pagevec *swpvec = lock_swap_pvec(&lru_add_pvec);
+	struct pagevec *pvec = &swpvec->pvec;
 
 	get_page(page);
 	if (!pagevec_add(pvec, page) || PageCompound(page))
 		__pagevec_lru_add(pvec);
-	put_cpu_var(lru_add_pvec);
+	unlock_swap_pvec(swpvec, &lru_add_pvec);
 }
 
 /**
@@ -570,28 +672,34 @@ static void lru_lazyfree_fn(struct page *page, struct lruvec *lruvec,
  */
 void lru_add_drain_cpu(int cpu)
 {
-	struct pagevec *pvec = &per_cpu(lru_add_pvec, cpu);
+	struct swap_pagevec *swpvec = lock_swap_pvec_cpu(&lru_add_pvec, cpu);
+	struct pagevec *pvec = &swpvec->pvec;
+	unsigned long flags;
 
 	if (pagevec_count(pvec))
 		__pagevec_lru_add(pvec);
+	unlock_swap_pvec_cpu(swpvec);
 
-	pvec = &per_cpu(lru_rotate_pvecs, cpu);
+	swpvec = lock_swap_pvec_cpu_irqsave(&lru_rotate_pvecs, cpu, &flags);
+	pvec = &swpvec->pvec;
 	if (pagevec_count(pvec)) {
-		unsigned long flags;
 
 		/* No harm done if a racing interrupt already did this */
-		local_irq_save(flags);
 		pagevec_move_tail(pvec);
-		local_irq_restore(flags);
 	}
+	unlock_swap_pvec_irqrestore(swpvec, flags);
 
-	pvec = &per_cpu(lru_deactivate_file_pvecs, cpu);
+	swpvec = lock_swap_pvec_cpu(&lru_deactivate_file_pvecs, cpu);
+	pvec = &swpvec->pvec;
 	if (pagevec_count(pvec))
 		pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
+	unlock_swap_pvec_cpu(swpvec);
 
-	pvec = &per_cpu(lru_lazyfree_pvecs, cpu);
+	swpvec = lock_swap_pvec_cpu(&lru_lazyfree_pvecs, cpu);
+	pvec = &swpvec->pvec;
 	if (pagevec_count(pvec))
 		pagevec_lru_move_fn(pvec, lru_lazyfree_fn, NULL);
+	unlock_swap_pvec_cpu(swpvec);
 
 	activate_page_drain(cpu);
 }
@@ -606,6 +714,9 @@ void lru_add_drain_cpu(int cpu)
  */
 void deactivate_file_page(struct page *page)
 {
+	struct swap_pagevec *swpvec;
+	struct pagevec *pvec;
+
 	/*
 	 * In a workload with many unevictable page such as mprotect,
 	 * unevictable page deactivation for accelerating reclaim is pointless.
@@ -614,11 +725,12 @@ void deactivate_file_page(struct page *page)
 		return;
 
 	if (likely(get_page_unless_zero(page))) {
-		struct pagevec *pvec = &get_cpu_var(lru_deactivate_file_pvecs);
+		swpvec = lock_swap_pvec(&lru_deactivate_file_pvecs);
+		pvec = &swpvec->pvec;
 
 		if (!pagevec_add(pvec, page) || PageCompound(page))
 			pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
-		put_cpu_var(lru_deactivate_file_pvecs);
+		unlock_swap_pvec(swpvec, &lru_deactivate_file_pvecs);
 	}
 }
 
@@ -631,21 +743,29 @@ void deactivate_file_page(struct page *page)
  */
 void mark_page_lazyfree(struct page *page)
 {
+	struct swap_pagevec *swpvec;
+	struct pagevec *pvec;
+
 	if (PageLRU(page) && PageAnon(page) && PageSwapBacked(page) &&
 	    !PageSwapCache(page) && !PageUnevictable(page)) {
-		struct pagevec *pvec = &get_cpu_var(lru_lazyfree_pvecs);
+		swpvec = lock_swap_pvec(&lru_lazyfree_pvecs);
+		pvec = &swpvec->pvec;
 
 		get_page(page);
 		if (!pagevec_add(pvec, page) || PageCompound(page))
 			pagevec_lru_move_fn(pvec, lru_lazyfree_fn, NULL);
-		put_cpu_var(lru_lazyfree_pvecs);
+		unlock_swap_pvec(swpvec, &lru_lazyfree_pvecs);
 	}
 }
 
 void lru_add_drain(void)
 {
-	lru_add_drain_cpu(get_cpu());
-	put_cpu();
+	if (static_branch_likely(&use_pvec_lock)) {
+		lru_add_drain_cpu(raw_smp_processor_id());
+	} else {
+		lru_add_drain_cpu(get_cpu());
+		put_cpu();
+	}
 }
 
 #ifdef CONFIG_SMP
@@ -683,10 +803,10 @@ void lru_add_drain_all(void)
 	for_each_online_cpu(cpu) {
 		struct work_struct *work = &per_cpu(lru_add_drain_work, cpu);
 
-		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
-		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
-		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs, cpu)) ||
-		    pagevec_count(&per_cpu(lru_lazyfree_pvecs, cpu)) ||
+		if (pagevec_count(&per_cpu(lru_add_pvec.pvec, cpu)) ||
+		    pagevec_count(&per_cpu(lru_rotate_pvecs.pvec, cpu)) ||
+		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs.pvec, cpu)) ||
+		    pagevec_count(&per_cpu(lru_lazyfree_pvecs.pvec, cpu)) ||
 		    need_activate_page_drain(cpu)) {
 			INIT_WORK(work, lru_add_drain_per_cpu);
 			queue_work_on(cpu, mm_percpu_wq, work);
-- 
2.20.1

