Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5553C10F11
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:36:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 689202075B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:36:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Yke+3xpE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 689202075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18BAF6B000A; Wed, 10 Apr 2019 21:36:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13DCB6B000C; Wed, 10 Apr 2019 21:36:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F1FE26B000D; Wed, 10 Apr 2019 21:36:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA2B86B000A
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 21:36:14 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id i124so3724595qkf.14
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 18:36:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7KCR/bG3UyviFO0P3mTQEntswZ73LUL6n099eGv7Rtc=;
        b=Ys1qp0X2263sG7x5UdVoRC+L+Mrp1qicO9vomPUIQTnIZ+p8F9WoM4NOzktRzS+Fl+
         x7WnBrzKCzJ1ElfWWy+dnWMeZe4wX3h8Iz2DwO2cVwNORG7R+QtH+QC3cnkh3pku7aGC
         0PChaSwMmh/fXgUyktokvRRs0OoBoACRNuAZxixmTru9gdMAO1iJWo9m4+zUtFOJlVvN
         yqSEAZIvG258TXGYlK04iYsCAcfvxu10w6bDn6JJbWd+11ArwQXg4/vesxxLj5EKLgaz
         JHAfYMc0yI8sRaqoVXBLEjKD+ZjhpqnEebRSQbTQbEiKTI6oPaX3QJwrV9EcpcKKKM3W
         npdQ==
X-Gm-Message-State: APjAAAWMx/0TkIUZH+1uuke+hZ1L7au64hcdI/hfh7G+wRbb/Jk/h91I
	UtSFeKTdD43CbBtiaKzmP1LX+YDOhm32Nh0nfkqeOCQzxl0ViID0V/9q8bQ1wdWVmABUTKCXinG
	/Km3BiOns8xUIAiGrIyukRadVD43xo8jcdnZcveL5IpNttGttwFhFQs42lCzdQBM=
X-Received: by 2002:a37:a40d:: with SMTP id n13mr35152341qke.325.1554946574497;
        Wed, 10 Apr 2019 18:36:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyl/opTkCjhINZelRh13Onj6rUxfvnWXhPWyPR/a5mwBgzl92Tst715fawDpVNaXdbSzI6e
X-Received: by 2002:a37:a40d:: with SMTP id n13mr35152273qke.325.1554946572836;
        Wed, 10 Apr 2019 18:36:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554946572; cv=none;
        d=google.com; s=arc-20160816;
        b=Cy3CftFKgMjuMwRT53evFCYRaRTNerOs+nrKgMpyJ9+/WslQ2q+r8l+K8jedRvyX/Q
         eQH8Pa+SKE07AYutobZRK3RGa/rSxQ2ScOhBmP3UAqca4mp9FLUCl0NlMOWzjInOltsE
         wBob8SLTJZV97ChWQoTDEpnVVIU34npgSvsllXYCsX42L2tp0p5YQPw34m959N6HJwhm
         vV0kEKK6FPwmhssmo17Z5PfcYlprqvMFd6QkSFDNHuPJnxK0d897TxFvg4dEX0vXumbE
         g7yQYwsE8F/qW9S0x7PtVyL/OtrfjDJ9KD6F+OHZpGe1k11UjSKaCusJEXZUfutQbLig
         9MkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=7KCR/bG3UyviFO0P3mTQEntswZ73LUL6n099eGv7Rtc=;
        b=vCU3YQH9/QV4qmbc0ldU//AI7BzfzYl1ZLl/gDFR5f6CoUSjsMss1RNk/z3NeBuOWN
         +dusJJqYK9OjtuOrw9pXI0rysw6k0jKxtN84FEwCzeE70hPUkoR0Mz9r5ZhRWM46A6uF
         sYoR7QTHtXCkH10x7DLQVM6laHGZR++7dCXX4h4yjTbb31s9+xWtdR1BzdFDw2Fhx0k+
         SUlyi8tD1MR3LHhNWDraouHIPKysk8fRb39jxM4LjhgI/msX5uafMWAKjP4UkDDMvRwn
         Law1m+kJyjRH6aTTu6g4+GN+exS6dowhdNyU88n2HzvKUtjhR3qV6qqnS8GjZ1/ZfLiQ
         xf1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Yke+3xpE;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id x38si15950423qta.266.2019.04.10.18.36.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 18:36:12 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Yke+3xpE;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 8CD398ABC;
	Wed, 10 Apr 2019 21:36:12 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Wed, 10 Apr 2019 21:36:12 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=7KCR/bG3UyviFO0P3mTQEntswZ73LUL6n099eGv7Rtc=; b=Yke+3xpE
	xbJwz9rTHdABSJJFp/2DM6HeQd5AfPKukKEqcybXNfrdIfBA1Sigb+OHLZyHAM6x
	i8g77d8ma8NT5M00F8MExYap0A6XKTHvkaUjWUyEQ1IrdFYSxpdVF1/SCajGDb4G
	vFysYVG7IgfEcqcwZWLDsKtieqNm8fpstQ+fotjSDojSeS1BIiXXbhUzLjdbj06L
	4tgJSR4NFEde3dEZ2/JbdEe7J9iwUMDI3787xNYWPIMkRktlJfU03yVYih+XLZ1j
	h4EYMfrbJvyTHv6+V32Ws6InJNvtvzWnSc8LxZBjKYHHhfAONJZbNDZN+UzubMhK
	bNZIoWwb+YhaAA==
X-ME-Sender: <xms:DJquXLfGNYsfv5ISzPeeGp_sDa8sVZHEsysTxof5MYSH0G4bLonDHA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudekgdegvdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudejuddrudelrdduleegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:DJquXLRlb8sR5qSVm-sZwXBKD_NYiQ2TPOhh5xjj0MDHdfDbz47PQA>
    <xmx:DJquXEZhmAEgZ81ChwH2jL5995CHAe0FHnqU3iBG-qw50d_9pU5q1A>
    <xmx:DJquXOdJN4Q6fN0diYrG7BnthHAWKigaowkT154SvcVY7nVyRy2hmw>
    <xmx:DJquXHr621koiyCETK0quHnJrIboZc34ZrnU2bDBuXIHtToidsN_Lg>
Received: from eros.localdomain (124-171-19-194.dyn.iinet.net.au [124.171.19.194])
	by mail.messagingengine.com (Postfix) with ESMTPA id 1DF95E409D;
	Wed, 10 Apr 2019 21:36:03 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>,
	Tycho Andersen <tycho@tycho.ws>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>,
	Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v3 04/15] slub: Slab defrag core
Date: Thu, 11 Apr 2019 11:34:30 +1000
Message-Id: <20190411013441.5415-5-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190411013441.5415-1-tobin@kernel.org>
References: <20190411013441.5415-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Internal fragmentation can occur within pages used by the slub
allocator.  Under some workloads large numbers of pages can be used by
partial slab pages.  This under-utilisation is bad simply because it
wastes memory but also because if the system is under memory pressure
higher order allocations may become difficult to satisfy.  If we can
defrag slab caches we can alleviate these problems.

Implement Slab Movable Objects in order to defragment slab caches.

Slab defragmentation may occur:

1. Unconditionally when __kmem_cache_shrink() is called on a slab cache
   by the kernel calling kmem_cache_shrink().

2. Unconditionally through the use of the slabinfo command.

	slabinfo <cache> -s

3. Conditionally via the use of kmem_cache_defrag()

- Use Slab Movable Objects when shrinking cache.

Currently when the kernel calls kmem_cache_shrink() we curate the
partial slabs list.  If object migration is not enabled for the cache we
still do this, if however, SMO is enabled we attempt to move objects in
partially full slabs in order to defragment the cache.  Shrink attempts
to move all objects in order to reduce the cache to a single partial
slab for each node.

- Add conditional per node defrag via new function:

	kmem_defrag_slabs(int node).

kmem_defrag_slabs() attempts to defragment all slab caches for node.
 Defragmentation is done conditionally dependent on MAX_PARTIAL _AND_
 defrag_used_ratio.

   Caches are only considered for defragmentation if the number of
   partial slabs exceeds MAX_PARTIAL (per node).

   Also, defragmentation only occurs if the usage ratio of the slab is
   lower than the configured percentage (sysfs field added in this
   patch).  Fragmentation ratios are measured by calculating the
   percentage of objects in use compared to the total number of objects
   that the slab page can accommodate.

   The scanning of slab caches is optimized because the defragmentable
   slabs come first on the list. Thus we can terminate scans on the
   first slab encountered that does not support defragmentation.

   kmem_defrag_slabs() takes a node parameter. This can either be -1 if
   defragmentation should be performed on all nodes, or a node number.

   Defragmentation may be disabled by setting defrag ratio to 0

	echo 0 > /sys/kernel/slab/<cache>/defrag_used_ratio

- Add a defrag ratio sysfs field and set it to 30% by default. A limit
of 30% specifies that more than 3 out of 10 available slots for objects
need to be in use otherwise slab defragmentation will be attempted on
the remaining objects.

In order for a cache to be defragmentable the cache must support object
migration (SMO).  Enabling SMO for a cache is done via a call to the
recently added function:

	void kmem_cache_setup_mobility(struct kmem_cache *,
				       kmem_cache_isolate_func,
			               kmem_cache_migrate_func);

Co-developed-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 Documentation/ABI/testing/sysfs-kernel-slab |  14 +
 include/linux/slab.h                        |   1 +
 include/linux/slub_def.h                    |   7 +
 mm/slub.c                                   | 385 ++++++++++++++++----
 4 files changed, 334 insertions(+), 73 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-kernel-slab b/Documentation/ABI/testing/sysfs-kernel-slab
index 29601d93a1c2..7770c03be6b4 100644
--- a/Documentation/ABI/testing/sysfs-kernel-slab
+++ b/Documentation/ABI/testing/sysfs-kernel-slab
@@ -180,6 +180,20 @@ Description:
 		list.  It can be written to clear the current count.
 		Available when CONFIG_SLUB_STATS is enabled.
 
+What:		/sys/kernel/slab/cache/defrag_used_ratio
+Date:		February 2019
+KernelVersion:	5.0
+Contact:	Christoph Lameter <cl@linux-foundation.org>
+		Pekka Enberg <penberg@cs.helsinki.fi>,
+Description:
+		The defrag_used_ratio file allows the control of how aggressive
+		slab fragmentation reduction works at reclaiming objects from
+		sparsely populated slabs. This is a percentage. If a slab has
+		less than this percentage of objects allocated then reclaim will
+		attempt to reclaim objects so that the whole slab page can be
+		freed. 0% specifies no reclaim attempt (defrag disabled), 100%
+		specifies attempt to reclaim all pages.  The default is 30%.
+
 What:		/sys/kernel/slab/cache/deactivate_to_tail
 Date:		February 2008
 KernelVersion:	2.6.25
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 886fc130334d..4bf381b34829 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -149,6 +149,7 @@ struct kmem_cache *kmem_cache_create_usercopy(const char *name,
 			void (*ctor)(void *));
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
+unsigned long kmem_defrag_slabs(int node);
 
 void memcg_create_kmem_cache(struct mem_cgroup *, struct kmem_cache *);
 void memcg_deactivate_kmem_caches(struct mem_cgroup *);
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 2879a2f5f8eb..34c6f1250652 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -107,6 +107,13 @@ struct kmem_cache {
 	unsigned int red_left_pad;	/* Left redzone padding size */
 	const char *name;	/* Name (only for display!) */
 	struct list_head list;	/* List of slab caches */
+	int defrag_used_ratio;	/*
+				 * Ratio used to check against the
+				 * percentage of objects allocated in a
+				 * slab page.  If less than this ratio
+				 * is allocated then reclaim attempts
+				 * are made.
+				 */
 #ifdef CONFIG_SYSFS
 	struct kobject kobj;	/* For sysfs */
 	struct work_struct kobj_remove_work;
diff --git a/mm/slub.c b/mm/slub.c
index f6b0e4a395ef..e601c804ed79 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -354,6 +354,12 @@ static __always_inline void slab_lock(struct page *page)
 	bit_spin_lock(PG_locked, &page->flags);
 }
 
+static __always_inline int slab_trylock(struct page *page)
+{
+	VM_BUG_ON_PAGE(PageTail(page), page);
+	return bit_spin_trylock(PG_locked, &page->flags);
+}
+
 static __always_inline void slab_unlock(struct page *page)
 {
 	VM_BUG_ON_PAGE(PageTail(page), page);
@@ -3643,6 +3649,7 @@ static int kmem_cache_open(struct kmem_cache *s, slab_flags_t flags)
 
 	set_cpu_partial(s);
 
+	s->defrag_used_ratio = 30;
 #ifdef CONFIG_NUMA
 	s->remote_node_defrag_ratio = 1000;
 #endif
@@ -3959,79 +3966,6 @@ void kfree(const void *x)
 }
 EXPORT_SYMBOL(kfree);
 
-#define SHRINK_PROMOTE_MAX 32
-
-/*
- * kmem_cache_shrink discards empty slabs and promotes the slabs filled
- * up most to the head of the partial lists. New allocations will then
- * fill those up and thus they can be removed from the partial lists.
- *
- * The slabs with the least items are placed last. This results in them
- * being allocated from last increasing the chance that the last objects
- * are freed in them.
- */
-int __kmem_cache_shrink(struct kmem_cache *s)
-{
-	int node;
-	int i;
-	struct kmem_cache_node *n;
-	struct page *page;
-	struct page *t;
-	struct list_head discard;
-	struct list_head promote[SHRINK_PROMOTE_MAX];
-	unsigned long flags;
-	int ret = 0;
-
-	flush_all(s);
-	for_each_kmem_cache_node(s, node, n) {
-		INIT_LIST_HEAD(&discard);
-		for (i = 0; i < SHRINK_PROMOTE_MAX; i++)
-			INIT_LIST_HEAD(promote + i);
-
-		spin_lock_irqsave(&n->list_lock, flags);
-
-		/*
-		 * Build lists of slabs to discard or promote.
-		 *
-		 * Note that concurrent frees may occur while we hold the
-		 * list_lock. page->inuse here is the upper limit.
-		 */
-		list_for_each_entry_safe(page, t, &n->partial, lru) {
-			int free = page->objects - page->inuse;
-
-			/* Do not reread page->inuse */
-			barrier();
-
-			/* We do not keep full slabs on the list */
-			BUG_ON(free <= 0);
-
-			if (free == page->objects) {
-				list_move(&page->lru, &discard);
-				n->nr_partial--;
-			} else if (free <= SHRINK_PROMOTE_MAX)
-				list_move(&page->lru, promote + free - 1);
-		}
-
-		/*
-		 * Promote the slabs filled up most to the head of the
-		 * partial list.
-		 */
-		for (i = SHRINK_PROMOTE_MAX - 1; i >= 0; i--)
-			list_splice(promote + i, &n->partial);
-
-		spin_unlock_irqrestore(&n->list_lock, flags);
-
-		/* Release empty slabs */
-		list_for_each_entry_safe(page, t, &discard, lru)
-			discard_slab(s, page);
-
-		if (slabs_node(s, node))
-			ret = 1;
-	}
-
-	return ret;
-}
-
 #ifdef CONFIG_MEMCG
 static void kmemcg_cache_deact_after_rcu(struct kmem_cache *s)
 {
@@ -4326,6 +4260,287 @@ int __kmem_cache_create(struct kmem_cache *s, slab_flags_t flags)
 	return err;
 }
 
+/*
+ * Allocate a slab scratch space that is sufficient to keep pointers to
+ * individual objects for all objects in cache and also a bitmap for the
+ * objects (used to mark which objects are active).
+ */
+static inline void *alloc_scratch(struct kmem_cache *s)
+{
+	unsigned int size = oo_objects(s->max);
+
+	return kmalloc(size * sizeof(void *) +
+		       BITS_TO_LONGS(size) * sizeof(unsigned long),
+		       GFP_KERNEL);
+}
+
+/*
+ * move_slab_page() - Move all objects in the given slab.
+ * @page: The slab we are working on.
+ * @scratch: Pointer to scratch space.
+ * @node: The target node to move objects to.
+ *
+ * If the target node is not the current node then the object is moved
+ * to the target node.  If the target node is the current node then this
+ * is an effective way of defragmentation since the current slab page
+ * with its object is exempt from allocation.
+ */
+static void move_slab_page(struct page *page, void *scratch, int node)
+{
+	unsigned long objects;
+	struct kmem_cache *s;
+	unsigned long flags;
+	unsigned long *map;
+	void *private;
+	int count;
+	void *p;
+	void **vector = scratch;
+	void *addr = page_address(page);
+
+	local_irq_save(flags);
+	slab_lock(page);
+
+	BUG_ON(!PageSlab(page)); /* Must be a slab page */
+	BUG_ON(!page->frozen);	 /* Slab must have been frozen earlier */
+
+	s = page->slab_cache;
+	objects = page->objects;
+	map = scratch + objects * sizeof(void **);
+
+	/* Determine used objects */
+	bitmap_fill(map, objects);
+	for (p = page->freelist; p; p = get_freepointer(s, p))
+		__clear_bit(slab_index(p, s, addr), map);
+
+	/* Build vector of pointers to objects */
+	count = 0;
+	memset(vector, 0, objects * sizeof(void **));
+	for_each_object(p, s, addr, objects)
+		if (test_bit(slab_index(p, s, addr), map))
+			vector[count++] = p;
+
+	if (s->isolate)
+		private = s->isolate(s, vector, count);
+	else
+		/* Objects do not need to be isolated */
+		private = NULL;
+
+	/*
+	 * Pinned the objects. Now we can drop the slab lock. The slab
+	 * is frozen so it cannot vanish from under us nor will
+	 * allocations be performed on the slab. However, unlocking the
+	 * slab will allow concurrent slab_frees to proceed. So the
+	 * subsystem must have a way to tell from the content of the
+	 * object that it was freed.
+	 *
+	 * If neither RCU nor ctor is being used then the object may be
+	 * modified by the allocator after being freed which may disrupt
+	 * the ability of the migrate function to tell if the object is
+	 * free or not.
+	 */
+	slab_unlock(page);
+	local_irq_restore(flags);
+
+	/* Perform callback to move the objects */
+	s->migrate(s, vector, count, node, private);
+}
+
+/*
+ * kmem_cache_defrag() - Defragment node.
+ * @s: cache we are working on.
+ * @node: The node to move objects from.
+ * @target_node: The node to move objects to.
+ * @ratio: The defrag ratio (percentage, between 0 and 100).
+ *
+ * Release slabs with zero objects and try to call the migration function
+ * for slabs with less than the 'ratio' percentage of objects allocated.
+ *
+ * Moved objects are allocated on @target_node.
+ *
+ * Return: The number of partial slabs left on @node after the
+ *         operation.
+ */
+static unsigned long kmem_cache_defrag(struct kmem_cache *s,
+				       int node, int target_node, int ratio)
+{
+	struct kmem_cache_node *n = get_node(s, node);
+	struct page *page, *page2;
+	LIST_HEAD(move_list);
+	unsigned long flags;
+
+	if (node == target_node && n->nr_partial <= 1) {
+		/*
+		 * Trying to reduce fragmentation on a node but there is
+		 * only a single or no partial slab page. This is already
+		 * the optimal object density that we can reach.
+		 */
+		return n->nr_partial;
+	}
+
+	spin_lock_irqsave(&n->list_lock, flags);
+	list_for_each_entry_safe(page, page2, &n->partial, lru) {
+		if (!slab_trylock(page))
+			/* Busy slab. Get out of the way */
+			continue;
+
+		if (page->inuse) {
+			if (page->inuse > ratio * page->objects / 100) {
+				slab_unlock(page);
+				/*
+				 * Skip slab because the object density
+				 * in the slab page is high enough.
+				 */
+				continue;
+			}
+
+			list_move(&page->lru, &move_list);
+			if (s->migrate) {
+				/* Stop page being considered for allocations */
+				n->nr_partial--;
+				page->frozen = 1;
+			}
+			slab_unlock(page);
+		} else {	/* Empty slab page */
+			list_del(&page->lru);
+			n->nr_partial--;
+			slab_unlock(page);
+			discard_slab(s, page);
+		}
+	}
+
+	if (!s->migrate) {
+		/*
+		 * No defrag method. By simply putting the zaplist at
+		 * the end of the partial list we can let them simmer
+		 * longer and thus increase the chance of all objects
+		 * being reclaimed.
+		 */
+		list_splice(&move_list, n->partial.prev);
+	}
+
+	spin_unlock_irqrestore(&n->list_lock, flags);
+
+	if (s->migrate && !list_empty(&move_list)) {
+		void **scratch = alloc_scratch(s);
+		if (scratch) {
+			/* Try to remove / move the objects left */
+			list_for_each_entry(page, &move_list, lru) {
+				if (page->inuse)
+					move_slab_page(page, scratch, target_node);
+			}
+			kfree(scratch);
+		}
+
+		/* Inspect results and dispose of pages */
+		spin_lock_irqsave(&n->list_lock, flags);
+		list_for_each_entry_safe(page, page2, &move_list, lru) {
+			list_del(&page->lru);
+			slab_lock(page);
+			page->frozen = 0;
+
+			if (page->inuse) {
+				/*
+				 * Objects left in slab page, move it to the
+				 * tail of the partial list to increase the
+				 * chance that the freeing of the remaining
+				 * objects will free the slab page.
+				 */
+				n->nr_partial++;
+				list_add_tail(&page->lru, &n->partial);
+				slab_unlock(page);
+			} else {
+				slab_unlock(page);
+				discard_slab(s, page);
+			}
+		}
+		spin_unlock_irqrestore(&n->list_lock, flags);
+	}
+
+	return n->nr_partial;
+}
+
+/**
+ * kmem_defrag_slabs() - Defrag slab caches.
+ * @node: The node to defrag or -1 for all nodes.
+ *
+ * Defrag slabs conditional on the amount of fragmentation in a page.
+ *
+ * Return: The total number of partial slabs in migratable caches left
+ *         on @node after the operation.
+ */
+unsigned long kmem_defrag_slabs(int node)
+{
+	struct kmem_cache *s;
+	unsigned long left = 0;
+	int nid;
+
+	if (node >= MAX_NUMNODES)
+		return -EINVAL;
+
+	/*
+	 * kmem_defrag_slabs() may be called from the reclaim path which
+	 * may be called for any page allocator alloc. So there is the
+	 * danger that we get called in a situation where slub already
+	 * acquired the slub_lock for other purposes.
+	 */
+	if (!mutex_trylock(&slab_mutex))
+		return 0;
+
+	list_for_each_entry(s, &slab_caches, list) {
+		/*
+		 * Defragmentable caches come first. If the slab cache is
+		 * not defragmentable then we can stop traversing the list.
+		 */
+		if (!s->migrate)
+			break;
+
+		if (node >= 0) {
+			if (s->node[node]->nr_partial > MAX_PARTIAL) {
+				left += kmem_cache_defrag(s, node, node,
+							  s->defrag_used_ratio);
+			}
+			continue;
+		}
+
+		for_each_node_state(nid, N_NORMAL_MEMORY) {
+			if (s->node[nid]->nr_partial > MAX_PARTIAL) {
+				left += kmem_cache_defrag(s, nid, nid,
+							  s->defrag_used_ratio);
+			}
+		}
+	}
+	mutex_unlock(&slab_mutex);
+	return left;
+}
+EXPORT_SYMBOL(kmem_defrag_slabs);
+
+/**
+ * __kmem_cache_shrink() - Shrink a cache.
+ * @s: The cache to shrink.
+ *
+ * Reduces the memory footprint of a slab cache by as much as possible.
+ *
+ * This works by:
+ *  1. Removing empty slabs from the partial list.
+ *  2. Migrating slab objects to denser slab pages if the slab cache
+ *  supports migration.  If not, reorganizing the partial list so that
+ *  more densely allocated slab pages come first.
+ *
+ * Not called directly, called by kmem_cache_shrink().
+ */
+int __kmem_cache_shrink(struct kmem_cache *s)
+{
+	int node;
+	int left = 0;
+
+	flush_all(s);
+	for_each_node_state(node, N_NORMAL_MEMORY)
+		left += kmem_cache_defrag(s, node, node, 100);
+
+	return left;
+}
+EXPORT_SYMBOL(__kmem_cache_shrink);
+
 void kmem_cache_setup_mobility(struct kmem_cache *s,
 			       kmem_cache_isolate_func isolate,
 			       kmem_cache_migrate_func migrate)
@@ -5177,6 +5392,29 @@ static ssize_t destroy_by_rcu_show(struct kmem_cache *s, char *buf)
 }
 SLAB_ATTR_RO(destroy_by_rcu);
 
+static ssize_t defrag_used_ratio_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", s->defrag_used_ratio);
+}
+
+static ssize_t defrag_used_ratio_store(struct kmem_cache *s,
+				       const char *buf, size_t length)
+{
+	unsigned long ratio;
+	int err;
+
+	err = kstrtoul(buf, 10, &ratio);
+	if (err)
+		return err;
+
+	if (ratio > 100)
+		return -EINVAL;
+
+	s->defrag_used_ratio = ratio;
+	return length;
+}
+SLAB_ATTR(defrag_used_ratio);
+
 #ifdef CONFIG_SLUB_DEBUG
 static ssize_t slabs_show(struct kmem_cache *s, char *buf)
 {
@@ -5501,6 +5739,7 @@ static struct attribute *slab_attrs[] = {
 	&validate_attr.attr,
 	&alloc_calls_attr.attr,
 	&free_calls_attr.attr,
+	&defrag_used_ratio_attr.attr,
 #endif
 #ifdef CONFIG_ZONE_DMA
 	&cache_dma_attr.attr,
-- 
2.21.0

