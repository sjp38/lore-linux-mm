Return-Path: <SRS0=PcJq=O5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70484C43444
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 19:22:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1811B218FE
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 19:22:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="XFRpu48z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1811B218FE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1EC98E0012; Thu, 20 Dec 2018 14:22:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 983A98E0001; Thu, 20 Dec 2018 14:22:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D76A8E0012; Thu, 20 Dec 2018 14:22:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4613D8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 14:22:02 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id m37so2944163qte.10
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:22:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject:references:mime-version
         :content-disposition:feedback-id;
        bh=9xsw+LRXhN6pULsUawdWy8PNdT5DJqPqassI+W8RJZA=;
        b=W3gNfbEWLB3Kyr+qQdKJwUjWPjPbROFBzHEjnj8Pnbw1+aHUPetRrfscIesaOMRyuj
         Sk9lAQ36gklOXf9bcTpQYkBxzvrMV0G78ylYQ30yn2/IJsfSlLWNkyZc5GZb3AgmxV/v
         LlWItfDtARmuex6bE6hf8qy2sBKqxIL6xuep9xDNWIBMgPYKdSQEIEb7/OfaxXnoaYPP
         2NwxVJPnKp5eH68ZSrV8/YBSg8XMhWacR64useOqwa++fiCQsE899KG5oN7QHyTs5Y5d
         NBZCpgZLZra6sHIlAndqI8tw5O28b0G5h/iVK1mw0fSAhQGaZPQedN2LP9peRwqE3BuY
         5ohw==
X-Gm-Message-State: AA+aEWYYO760JF9xYx7vjp0amYNwQVdu916DDSNNLGZAXDzypS2CfRnT
	/vx+JxKltMm9PBpNPG/2hQ6t90b+1B2CF7pcrN/neSmMWtSDejTqVSghYZwBLOuqyMR/994Fv6w
	1LM7AVqBpvt9BElnpJUymLYic14cRRZ4iMi7qgIs3/7D6NivAdhLNBF+2YnFDgjU=
X-Received: by 2002:aed:3c7d:: with SMTP id u58mr28254982qte.198.1545333722046;
        Thu, 20 Dec 2018 11:22:02 -0800 (PST)
X-Google-Smtp-Source: AFSGD/UXQWr/SSbuabKSfCzlcKisKVo7nl3+3Wml7LQNT73o1FzIAX2W6vE+iQpXM/pjLPZeER/6
X-Received: by 2002:aed:3c7d:: with SMTP id u58mr28254958qte.198.1545333721636;
        Thu, 20 Dec 2018 11:22:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545333721; cv=none;
        d=google.com; s=arc-20160816;
        b=0yQRsXn3SNhyxrEv5Bvh5upj22yFcrBNF9BH3xE5I6GecwX735BSJrPFmw+HMcdZJK
         0K5QkOzaI6ABVcaNvjCHmw2mYQjmVqZDqxWdkBToLsaaIqOeqsdKLVDKAP5qPsSZ5SqE
         iwiSfJ2TYDLJhghwlbvqAozcFQNKQygTO76bOL2vidvaueSy/1KEnS68ZDmBFProKbVc
         8ce8rG5ktLkur9P50Qs3ba7+GUDOAO4fTzHIt9aSFudIoI3CYcLvIztzWUczXGEII1LK
         nDI2viDDk6ZhUECj2MDYTTDgOjgpMe0Hr+ao6wpwXSL6dMR4qXG5jifagaN+DQI9mSOk
         uX4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:content-disposition:mime-version:references:subject:cc
         :cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id
         :dkim-signature;
        bh=9xsw+LRXhN6pULsUawdWy8PNdT5DJqPqassI+W8RJZA=;
        b=prFlyGG9HZVdIBYHc6TvsSFM6l2W0GAwps15PZAWGw8IXM29ATTv3dFJyT+TuJPNHU
         h9pOCiT1G8nTJ+4SIRUofCQAIHl1wduWOmqy/hEI/2gnqRFB1B2V0B0KTQADvlefb+A4
         hZ5LQlbjtRKTqLkd5aW3XDb1JgLIQ9CJ6Y7kdN77gcIYjwkwpQ76zYD68guOr1EK2k5j
         MNohMv60x1V4TRMOGQtvMKabJ8NdA2zwtF5lXsZmHR3QrTB5RPWkEu1RYNctdfTsEwIw
         rFMb4MaxtNks6KNDfyMIeo6Z/cHPovpwFZypg8FpB9gb8jF3z3bN6uWzoe/+CueNqgQH
         3h1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=fail header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=XFRpu48z;
       spf=pass (google.com: domain of 01000167cd1147f1-b4c1de14-b084-405f-a4d4-26e0506d342e-000000@amazonses.com designates 54.240.9.34 as permitted sender) smtp.mailfrom=01000167cd1147f1-b4c1de14-b084-405f-a4d4-26e0506d342e-000000@amazonses.com
Received: from a9-34.smtp-out.amazonses.com (a9-34.smtp-out.amazonses.com. [54.240.9.34])
        by mx.google.com with ESMTPS id o24si4207390qkl.147.2018.12.20.11.22.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Dec 2018 11:22:01 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000167cd1147f1-b4c1de14-b084-405f-a4d4-26e0506d342e-000000@amazonses.com designates 54.240.9.34 as permitted sender) client-ip=54.240.9.34;
Authentication-Results: mx.google.com;
       dkim=fail header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=XFRpu48z;
       spf=pass (google.com: domain of 01000167cd1147f1-b4c1de14-b084-405f-a4d4-26e0506d342e-000000@amazonses.com designates 54.240.9.34 as permitted sender) smtp.mailfrom=01000167cd1147f1-b4c1de14-b084-405f-a4d4-26e0506d342e-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1545333721;
	h=Message-Id:Date:From:To:Cc:Cc:Cc:CC:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Subject:References:MIME-Version:Content-Type:Feedback-ID;
	bh=/ZPhvHYHxnhQXiDFBeTlfZ9rpP4ThfXAI7UKJ2h1uV4=;
	b=XFRpu48zIQe/ov7J8L8ah9XuPoxvby9CaIwWUnunOEf3Hz20fCT1tgxRWbjhwVOn
	7SzDaFQLjcG+7EW7Zu1gfetTALDAOjUJR4TxHhhhg5wcg3crLpfCgw9HxpwTlw/IAbV
	XVFuD6zVkyWlL1HbGaIa2R1UgQVhyGAQXWLT0clM=
Message-ID:
 <01000167cd1147f1-b4c1de14-b084-405f-a4d4-26e0506d342e-000000@email.amazonses.com>
User-Agent: quilt/0.65
Date: Thu, 20 Dec 2018 19:22:01 +0000
From: Christoph Lameter <cl@linux.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
CC: akpm@linux-foundation.org
Cc: Mel Gorman <mel@skynet.ie>
Cc: andi@firstfloor.org
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC 5/7] slub: Slab defrag core
References: <20181220192145.023162076@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=mobility_core
X-SES-Outgoing: 2018.12.20-54.240.9.34
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181220192201.6gPC99DadmlceMPeZsR_fbOKo-C2FOTkfYQ1OS3F5w4@z>

Slab defragmentation may occur:

1. Unconditionally when kmem_cache_shrink is called on a slab cache by the
   kernel calling kmem_cache_shrink.

2. Through the use of the slabinfo command.

3. Per node defrag conditionally when kmem_cache_defrag(<node>) is called
   (can be called from reclaim code with a later patch).

   Defragmentation is only performed if the fragmentation of the slab
   is lower than the specified percentage. Fragmentation ratios are measured
   by calculating the percentage of objects in use compared to the total
   number of objects that the slab page can accomodate.

   The scanning of slab caches is optimized because the
   defragmentable slabs come first on the list. Thus we can terminate scans
   on the first slab encountered that does not support defragmentation.

   kmem_cache_defrag() takes a node parameter. This can either be -1 if
   defragmentation should be performed on all nodes, or a node number.

A couple of functions must be setup via a call to kmem_cache_setup_defrag()
in order for a slabcache to support defragmentation. These are

kmem_defrag_isolate_func (void *isolate(struct kmem_cache *s, void **objects, int nr))

	Must stabilize that the objects and ensure that they will not be freed until
	the migration function is complete. SLUB guarantees that
	the objects are still allocated. However, other threads may be blocked
	in slab_free() attempting to free objects in the slab. These may succeed
	as soon as isolate() returns to the slab allocator. The function must
	be able to detect such situations and void the attempts to free such
	objects (by for example voiding the corresponding entry in the objects
	array).

	No slab operations may be performed in isolate(). Interrupts
	are disabled. What can be done is very limited. The slab lock
	for the page that contains the object is taken. Any attempt to perform
	a slab operation may lead to a deadlock.

	kmem_defrag_isolate_func returns a private pointer that is passed to
	kmem_defrag_kick_func(). Should we be unable to obtain all references
	then that pointer may indicate to the kick() function that it should
	not attempt any object removal or move but simply undo the measure
	that were used to stabilize the object.

kmem_defrag_migrate_func (void migrate(struct kmem_cache *, void **objects, int nr,
			int node, void *get_result))

	After SLUB has stabilzed the objects in a
	slab it will then drop all locks and use migrate() to move objects out
	of the slab. The existence of the object is guaranteed by virtue of
	the earlier obtained references via kmem_defrag_get_func(). The
	callback may perform any slab operation since no locks are held at
	the time of call.

	The callback should remove the object from the slab in some way. This
	may be accomplished by reclaiming the object and then running
	kmem_cache_free() or reallocating it and then running
	kmem_cache_free(). Reallocation is advantageous because the partial
	slabs were just sorted to have the partial slabs with the most objects
	first. Reallocation is likely to result in filling up a slab in
	addition to freeing up one slab. A filled up slab can also be removed
	from the partial list. So there could be a double effect.

	kmem_defrag_migrate_func() does not return a result. SLUB will check
	the number of remaining objects in the slab. If all objects were
	removed then the slab is freed and we have reduced the overall
	fragmentation of the slab cache.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slab.h |    3 
 mm/slub.c            |  265 ++++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 215 insertions(+), 53 deletions(-)

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -351,6 +351,12 @@ static __always_inline void slab_lock(st
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
@@ -3946,79 +3952,6 @@ void kfree(const void *x)
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
@@ -4325,14 +4258,271 @@ static inline void *alloc_scratch(void)
 		GFP_KERNEL);
 }
 
+/*
+ * Move all objects in the given slab.
+ *
+ * If the target node is the current node then the object is moved else
+ * where on the same node. Which is an effective way of defragmentation
+ * since the current slab page with its object is exempt from allocation.
+ *
+ * The scratch area passed to list function is sufficient to hold
+ * struct listhead times objects per slab. We use it to hold void ** times
+ * objects per slab plus a bitmap for each object.
+ */
+static void kmem_cache_move(struct page *page, void *scratch, int node)
+{
+	void **vector = scratch;
+	void *p;
+	void *addr = page_address(page);
+	struct kmem_cache *s;
+	unsigned long *map;
+	int count;
+	void *private;
+	unsigned long flags;
+	unsigned long objects;
+
+	local_irq_save(flags);
+	slab_lock(page);
+
+	BUG_ON(!PageSlab(page));	/* Must be s slab page */
+	BUG_ON(!page->frozen);	/* Slab must have been frozen earlier */
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
+		/*
+		 * Objects do not need to be isolated.
+		 */
+		private = NULL;
+
+	/*
+	 * Pinned the objects. Now we can drop the slab lock. The slab
+	 * is frozen so it cannot vanish from under us nor will
+	 * allocations be performed on the slab. However, unlocking the
+	 * slab will allow concurrent slab_frees to proceed. So
+	 * the subsystem must have a way to tell from the content
+	 * of the object that it was freed.
+	 *
+	 * If neither RCU nor ctor is being used then the object
+	 * may be modified by the allocator after being freed
+	 * which may disrupt the ability of the migrate function
+	 * to tell if the object is free or not.
+	 */
+	slab_unlock(page);
+	local_irq_restore(flags);
+
+	/*
+	 * Perform callbacks to move the objects.
+	 */
+	s->migrate(s, vector, count, node, private);
+}
+
+/*
+ * Move slab objects on a particular node of the cache.
+ * Release slabs with zero objects and tryg to call the move function for
+ * slabs with less than the configured percentage of objects allocated.
+ *
+ * Returns the number of slabs left on the node after the operation.
+ */
+static unsigned long __move(struct kmem_cache *s, int node,
+		int target_node, int ratio)
+{
+	unsigned long flags;
+	struct page *page, *page2;
+	LIST_HEAD(move_list);
+	struct kmem_cache_node *n = get_node(s, node);
+
+	if (node == target_node && n->nr_partial <= 1)
+		/*
+		 * Trying to reduce fragmentataion on a node but there is
+		 * only a single or no partial slab page. This is already
+		 * the optimal object density that we can reach
+		 */
+		goto out;
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
+				 * in the slab page is high enough
+				*/
+				continue;
+			}
+
+			list_move(&page->lru, &move_list);
+			if (s->migrate) {
+				/* Remove page from being considered for allocations */
+				n->nr_partial--;
+				page->frozen = 1;
+			}
+			slab_unlock(page);
+		} else {
+			/* Empty slab page */
+			list_del(&page->lru);
+			n->nr_partial--;
+			slab_unlock(page);
+			discard_slab(s, page);
+		}
+	}
+
+	if (!s->migrate)
+		/*
+		 * No defrag method. By simply putting the zaplist at the
+		 * end of the partial list we can let them simmer longer
+		 * and thus increase the chance of all objects being
+		 * reclaimed.
+		 *
+		 * We have effectively sorted the partial list and put
+		 * the slabs with more objects first. As soon as they
+		 * are allocated they are going to be removed from the
+		 * partial list.
+		 */
+		list_splice(&move_list, n->partial.prev);
+
+
+	spin_unlock_irqrestore(&n->list_lock, flags);
+
+	if (s->migrate && !list_empty(&move_list)) {
+		void **scratch = alloc_scratch();
+		struct page *page;
+		struct page *page2;
+
+		if (scratch) {
+			/* Try to remove / move the objects left */
+			list_for_each_entry(page, &move_list, lru) {
+				if (page->inuse)
+					kmem_cache_move(page, scratch, target_node);
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
+				 * Objects left in slab page move it to
+				 * the tail of the partial list to
+				 * increase the change that the freeing
+				 * of the remaining objects will
+				 * free the slab page
+				 */
+				n->nr_partial++;
+				list_add_tail(&page->lru, &n->partial);
+				slab_unlock(page);
+
+			} else {
+				slab_unlock(page);
+				discard_slab(s, page);
+			}
+		}
+		spin_unlock_irqrestore(&n->list_lock, flags);
+	}
+out:
+	return atomic_long_read(&n->nr_slabs);
+}
+
+/*
+ * Defrag slabs conditional on the amount of fragmentation in a page.
+ */
+int kmem_cache_defrag(int node)
+{
+	struct kmem_cache *s;
+	unsigned long left = 0;
+
+	/*
+	 * kmem_cache_defrag may be called from the reclaim path which may be
+	 * called for any page allocator alloc. So there is the danger that we
+	 * get called in a situation where slub already acquired the slub_lock
+	 * for other purposes.
+	 */
+	if (!mutex_trylock(&slab_mutex))
+		return 0;
+
+	list_for_each_entry(s, &slab_caches, list) {
+		/*
+		 * Defragmentable caches come first. If the slab cache is not
+		 * defragmentable then we can stop traversing the list.
+		 */
+		if (!s->migrate)
+			break;
+
+		if (node == -1) {
+			int nid;
+
+			for_each_node_state(nid, N_NORMAL_MEMORY)
+				if (s->node[nid]->nr_partial > MAX_PARTIAL)
+					left += __move(s, nid, nid, s->defrag_ratio);
+		} else
+			left  += __move(s, node, node, 100);
+
+	}
+	mutex_unlock(&slab_mutex);
+	return left;
+}
+EXPORT_SYMBOL(kmem_cache_defrag);
+
+/*
+ * kmem_cache_shrink reduces the memory footprint of a slab cache
+ * by as much as possible. This works by removing empty slabs from
+ * the partial list, migrating slab objects to denser slab pages
+ * (if the slab cache supports that) or reorganizing the partial
+ * list so that denser slab pages come first and less dense
+ * allocated slab pages are at the end.
+ */
+int __kmem_cache_shrink(struct kmem_cache *s)
+{
+	int node;
+	int left = 0;
+
+	flush_all(s);
+	for_each_node_state(node, N_NORMAL_MEMORY)
+		left += __move(s, node, node, 100);
+
+	return 0;
+}
+EXPORT_SYMBOL(__kmem_cache_shrink);
+
 void kmem_cache_setup_mobility(struct kmem_cache *s,
 	kmem_isolate_func isolate, kmem_migrate_func migrate)
 {
 	int max_objects = oo_objects(s->max);
 
 	/*
-	 * Defragmentable slabs must have a ctor otherwise objects may be
-	 * in an undetermined state after they are allocated.
+	 * Mobile objects must have a ctor otherwise the
+	 * object may be in an undefined state on allocation.
+	 *
+	 * Since the object may need to be inspected by the
+	 * migration function at any time after allocation we
+	 * must ensure that the object always has a defined
+	 * state.
 	 */
 	BUG_ON(!s->ctor);
 

