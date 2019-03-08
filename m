Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6546BC43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09AD220851
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="4OgKHpNJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09AD220851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABC0A8E000C; Thu,  7 Mar 2019 23:15:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A68658E0002; Thu,  7 Mar 2019 23:15:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E9ED8E000C; Thu,  7 Mar 2019 23:15:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F5758E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 23:15:34 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id i3so17349401qtc.7
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 20:15:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8QX/a55REiyFrStRj7zkmM3pdCMENMhdp/xRcRhpQ7Q=;
        b=tpdZakJEQ1LvOhbkt/iodWe1XRO2HU9bHOqE+0laAmtqhNcRDYr9qeZ/vTvTw8ZUj1
         cmZn6arWlDNxVZnuOSFV/PlmmQ8RlbuNx2wV59we7TzVi6uWNPlXxhZp8BOz9uWou2Lq
         0esmD8FSDfrIiJBrjaGZzzeLrittJDpuaehrUJh435p9ykRtW06XjH0JlNY7Y2QX4t3I
         zIuY1ISRL2mGSduTo/cCcu8UzuIYKh3zOI+EkxKwXOYhOIxbkDc6IexHclTHSvZ4x2Le
         KS+Ahd4Jg0G0X9FuLFtl3phWpzeXCFT5pTqwL0EKFIDCFgCnxhS8sxHoo0zi95Mzch64
         it7Q==
X-Gm-Message-State: APjAAAVQY3sGwnFYn4G5+4K3FEztD9ncklf6z2YmsgWPbzRqamKRXFnq
	MlwX+boPs8PsvdhrtlPRu7kGs0LH9dp4HP3pX9YIzBesVgQejqNdvmnf4/vQa5wqOVlE84IgvxB
	8mT8G9i1cnaVbxiJXUX8s0y2iuHZHdAX9i+paT7YnnaKkxQwbPkXJPWZUIeah2hI=
X-Received: by 2002:a37:5786:: with SMTP id l128mr12576420qkb.263.1552018534090;
        Thu, 07 Mar 2019 20:15:34 -0800 (PST)
X-Google-Smtp-Source: APXvYqz0vu0JXVHJypOH1w76f4CEjge2//Ztc1PDrSktUW31ccrVP8kqz1C1iBqV5gKYAdavQqSx
X-Received: by 2002:a37:5786:: with SMTP id l128mr12576376qkb.263.1552018532780;
        Thu, 07 Mar 2019 20:15:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552018532; cv=none;
        d=google.com; s=arc-20160816;
        b=Yld44B1koIbgeOWkK39uDIYEJWtxnKYAD9ScNb++bBdOD+9j5JRFUsEmSLtpajE67I
         rpPMhiHxXo2hnKzuMzHRQuMYp8PWqxuww91awMxZajJFfomZzp94kpcG0LlqsfcRhkzj
         QtieCCM9hK08LOdtPoMs6cgwH9Go/VhWobKdRTjORUvRk86PMd5Bcc4SZUX6/0KmgrVk
         6b9wW2w9eGuf7Yu3MWIELJIhMLjKn6zhkjXV4pvoIRgqRpQlWm4uEDCnNTJrokMQMjND
         Dk0VBGf9lcMDEHOEYjKj4MNMnerW5Jlah6exfjRYqlj0WWEqkT+aUHKBKbAXXxBhGII2
         aHMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=8QX/a55REiyFrStRj7zkmM3pdCMENMhdp/xRcRhpQ7Q=;
        b=PhlqSlLifKyKpaHgT4ZY6oIvOmmPpY27vHVktMkwQcUdh6IIpQfvxQO51zszM0g4MM
         Wlq80u4k4NbALwJ1419rfEbDAiF2dTtt0ouQS7sHE1qzWK7E0HxI/1Iumb0S3uH9/4J/
         EhEvslvNZzzfX2mbrq5VPH/wkilB/ksXzc2/uF32urrP0iozbtJ1IhB/vtwfH1LYZbPk
         gSTPVSwawFEPDXD/5uXtvqkQOBuufLq7wS5JDBR/HHUMhvVJwPypcdarVJ6H9IZe22iR
         l9XW7zyqKlEgH7ptdMCtmXIdz9uiMb/WSNLjHyovr3TODpHfINPWFtPa20mDWrSRa6FT
         lbFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=4OgKHpNJ;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id g189si4728946qka.158.2019.03.07.20.15.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 20:15:32 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=4OgKHpNJ;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 540D736AD;
	Thu,  7 Mar 2019 23:15:31 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 07 Mar 2019 23:15:31 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=8QX/a55REiyFrStRj7zkmM3pdCMENMhdp/xRcRhpQ7Q=; b=4OgKHpNJ
	1u0eko9YuAGds8yLt2tfSydWns7NHejGA2AAwya5Bz3c0CwCeK70XZqnpT0p1sBL
	c9Ph1Vdcc3bz148QGhCZRVvschnqBbGge0KzukdGjW16FCctqo0voU2skY0wg8n0
	EywD+QLBn0poqfSWeSiCDJWN1hRader6UwHc2kkBKRGKp4dEBwd6T0sk2uArtHFW
	WFRqglq0qTU8UTqL81s784f7C3PrbQZOlYX0gZ3QQqMeGHldWAnL3iCXuI63eppF
	ES2sLOEFDMvqVD/m2YvVrLWJA6J2hN2hZbKZqDJHFCaHAQ9ltEBJsdRvbIrAhLB2
	mTtGV/h1ohjjLg==
X-ME-Sender: <xms:YuyBXJrl8qIA9oXaX0sg0Aifvaxp3Pum-0Z0Oq7tcruBqkqMKCVcwA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrfeelgdeifecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrhedrudehkeenucfrrghrrghmpehmrghilhhfrhhomhepthhosghi
    nheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepke
X-ME-Proxy: <xmx:YuyBXHEw9dASlVsp2ggeJWT1W5ppPBPdekZT46OA-3eyR9Pw3QVy2g>
    <xmx:YuyBXE5MCDiXKJxt6K526-mya_ynhVj1CwIq54C03vkePUfspon7iA>
    <xmx:YuyBXCDAoKQT9V-BZvOXg8J6Re89bhQ4WT6lMnPo3bBhVW4efLwwqQ>
    <xmx:YuyBXKWxfisv5AA6o7kDvYiNQHXBrjlbrePiriPnqH-JhbwqzjNf4w>
Received: from eros.localdomain (124-169-5-158.dyn.iinet.net.au [124.169.5.158])
	by mail.messagingengine.com (Postfix) with ESMTPA id 6A98CE4548;
	Thu,  7 Mar 2019 23:15:27 -0500 (EST)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Christopher Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>,
	Tycho Andersen <tycho@tycho.ws>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC 09/15] slub: Enable slab defragmentation using SMO
Date: Fri,  8 Mar 2019 15:14:20 +1100
Message-Id: <20190308041426.16654-10-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190308041426.16654-1-tobin@kernel.org>
References: <20190308041426.16654-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If many objects are allocated with the slab allocator and freed in an
arbitrary order then the slab caches can become internally fragmented.
Now that the slab allocator supports movable objects we can defragment
any cache that has this feature enabled.

Slab defragmentation may occur:

1. Unconditionally when __kmem_cache_shrink() is called on a slab cache
   by the kernel calling kmem_cache_shrink().

2. Unconditionally through the use of the slabinfo command.

	slabinfo <cache> -s

3. Conditionally via the use of kmem_cache_defrag()

Use SMO when shrinking cache.  Currently when the kernel calls
kmem_cache_shrink() we curate the partial slabs list.  If object
migration is not enabled for the cache we still do this, if however SMO
is enabled, we attempt to move objects in partially full slabs in order
to defragment the cache.  Shrink attempts to move all objects in order
to reduce the cache to a single partial slab for each node.

kmem_cache_defrag() differs from shrink in that it operates dependent on
the defrag_used_ratio and only attempts to move objects if the number of
partial slabs exceeds MAX_PARTIAL (for each node).

Add function kmem_cache_defrag(int node).

   kmem_cache_defrag() only performs defragmentation if the usage ratio
   of the slab is lower than the configured percentage (sysfs file added
   in previous patch).  Fragmentation ratios are measured by calculating
   the percentage of objects in use compared to the total number of
   objects that the slab page can accommodate.

   The scanning of slab caches is optimized because the defragmentable
   slabs come first on the list. Thus we can terminate scans on the
   first slab encountered that does not support defragmentation.

   kmem_cache_defrag() takes a node parameter. This can either be -1 if
   defragmentation should be performed on all nodes, or a node number.

   Defragmentation may be disabled by setting defrag ratio to 0

	echo 0 > /sys/kernel/slab/<cache>/defrag_used_ratio

In order for a cache to be defragmentable the cache must support object
migration (SMO).  Enabling SMO for a cache is done via a call to the
recently added function:

	void kmem_cache_setup_mobility(struct kmem_cache *,
				       kmem_cache_isolate_func,
			               kmem_cache_migrate_func);

Co-developed-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 include/linux/slab.h |   1 +
 mm/slub.c            | 266 +++++++++++++++++++++++++++++++------------
 2 files changed, 194 insertions(+), 73 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 22e87c41b8a4..b9b46bc9937e 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -147,6 +147,7 @@ struct kmem_cache *kmem_cache_create_usercopy(const char *name,
 			void (*ctor)(void *));
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
+int kmem_cache_defrag(int node);
 
 void memcg_create_kmem_cache(struct mem_cgroup *, struct kmem_cache *);
 void memcg_deactivate_kmem_caches(struct mem_cgroup *);
diff --git a/mm/slub.c b/mm/slub.c
index 515db0f36c55..53dd4cb5b5a4 100644
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
@@ -3959,79 +3965,6 @@ void kfree(const void *x)
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
@@ -4411,6 +4344,193 @@ static void __move(struct page *page, void *scratch, int node)
 	s->migrate(s, vector, count, node, private);
 }
 
+/*
+ * __defrag() - Defragment node.
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
+ * Return: The number of partial slabs left on the node after the operation.
+ */
+static unsigned long __defrag(struct kmem_cache *s, int node, int target_node,
+			      int ratio)
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
+		 * No defrag method. By simply putting the zaplist at the
+		 * end of the partial list we can let them simmer longer
+		 * and thus increase the chance of all objects being
+		 * reclaimed.
+		 *
+		 */
+		list_splice(&move_list, n->partial.prev);
+	}
+
+	spin_unlock_irqrestore(&n->list_lock, flags);
+
+	if (s->migrate && !list_empty(&move_list)) {
+		void **scratch = alloc_scratch(s);
+		struct page *page, *page2;
+
+		if (scratch) {
+			/* Try to remove / move the objects left */
+			list_for_each_entry(page, &move_list, lru) {
+				if (page->inuse)
+					__move(page, scratch, target_node);
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
+ * kmem_cache_defrag() - Defrag slab caches.
+ * @node: The node to defrag or -1 for all nodes.
+ *
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
+					left += __defrag(s, nid, nid, s->defrag_used_ratio);
+		} else {
+			if (s->node[node]->nr_partial > MAX_PARTIAL)
+				left += __defrag(s, node, node, s->defrag_used_ratio);
+		}
+	}
+	mutex_unlock(&slab_mutex);
+	return left;
+}
+EXPORT_SYMBOL(kmem_cache_defrag);
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
+		left += __defrag(s, node, node, 100);
+
+	return left;
+}
+EXPORT_SYMBOL(__kmem_cache_shrink);
+
 void kmem_cache_setup_mobility(struct kmem_cache *s,
 			       kmem_cache_isolate_func isolate,
 			       kmem_cache_migrate_func migrate)
-- 
2.21.0

