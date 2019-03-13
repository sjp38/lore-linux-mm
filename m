Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A187C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 05:21:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E79B20693
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 05:21:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="yyj8H+HO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E79B20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B34B48E0006; Wed, 13 Mar 2019 01:21:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABD208E0002; Wed, 13 Mar 2019 01:21:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 985988E0006; Wed, 13 Mar 2019 01:21:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 71C8F8E0002
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 01:21:19 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id g7so231487qtj.14
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 22:21:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oH5EnFXP99XnzGKj2+Fm20mBDHurM0tmDh5XcLBmzO0=;
        b=C4mSpfJCpZRmloeaXoINgOz0+4RaDhaoN22ZePXpzmnPtlw/0LyZZse2Sp9C2/VyMW
         wUDfSHUBBXh7mb0vPa0MRFonaGMxbj0FQXH1tXOi3NZQko4L4b1tzVOmHtY1YUP5HwS/
         2dr3cffr8nFIfiO1ivczhpMqWplygu7LFPQkWlaicBGA0eTBvCGASyTljlmdCBsZL7Ei
         qoRV7UZVXLGhLTdmkXy4LGYmPQefEhoEbQXYMk0UctBak2eY2yIMUu/jWFryZVYEfpO7
         LEQRQ3iWfkh1FFHUsgzbJsfZMWPTt3pMRgPfS5RimPUXn7JmUy8HOb5zhMfMdb92iK5d
         yo6Q==
X-Gm-Message-State: APjAAAVrqnspZ2Nhz2GGSvGEFA9ZI45Y9kvnEq9j44QaBaB5TTXTsq+K
	lSALqK/MNxIR2Mp3cpTJ5IH6YmuR6Q00MYfN29cCvuerly+7w7OaRY7DhJOmCWk9Ho31iTsoiHM
	qR/XgGx+FmyDcxvGy0uz3LDYvDzn7/h0VRCwC7rREsxTmsIwP/XUZrEmNf0k+1W4=
X-Received: by 2002:ac8:2ea6:: with SMTP id h35mr33211887qta.181.1552454479251;
        Tue, 12 Mar 2019 22:21:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2Owov0gkT+NGyArJ1Os2MwKa94M2NkMcrgUCU8EL7SL7/9I0sKbfHyjeDMO5dr6ytk3e6
X-Received: by 2002:ac8:2ea6:: with SMTP id h35mr33211853qta.181.1552454478274;
        Tue, 12 Mar 2019 22:21:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552454478; cv=none;
        d=google.com; s=arc-20160816;
        b=ACe+0jJCKztX+vZdxB9ZIEIg3rt4tnu2oVTsGND8QEI/yowUnv861AmtStYUlXan+J
         a9Oit3ykESZLgPuUOFScs1fvZGV8ch2/ByyiJpko/HzUMsrTuiKJxRaVALgdAybzhwgR
         bw2kuYkY6xLcwFVququUFCKXjzGAGxG/KjWnSxCVQw/EAmrnHSlDm+c/P3MLn4MaRsO9
         dI5E2APKjbBckDbIe1yPC19Gofaaugt4mvtChoViTSe87MGGO4RVmtDSALPR2dA7d2Cw
         byeMJMr3FJH6KmljYz3411A/7ZPNTTsupTEpKNoSUMSX0ODINw26ild4/2RmKFodxcEY
         bzKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=oH5EnFXP99XnzGKj2+Fm20mBDHurM0tmDh5XcLBmzO0=;
        b=DoB5wJD3ig5BknmGBhQlekFMEjysu7uzdmpqBdq7ku1HuT7vdDpcSkdr27qdV4j8c8
         ixBxH/hkR5nWw2JlqpUvvsozitNDQAH83LDsi2gyWE/VMoAgRHdVxodUO/EUm4MflNZK
         fJtqph3Jy0C83POeb8K/uG5vBvSUlv0hF0wJgpnog4mPbJDSSiFBuyTrPp7ZKetS5LLq
         Nup/MbuS49mIYaavLXdjK3CAmrJpgnTJT/bap/eQm8SX+N/hqDS7WsdqWOcNHZNh5htJ
         LI7z8dbi4iD9eGSptBBIQhBKylQ39VCUgnuVLPjeMjakueI+BoyaXSS5FDEPCYOTjxlR
         2tLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=yyj8H+HO;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id q13si154121qvq.75.2019.03.12.22.21.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 22:21:18 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=yyj8H+HO;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id AF46438B2;
	Wed, 13 Mar 2019 01:21:16 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Wed, 13 Mar 2019 01:21:17 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=oH5EnFXP99XnzGKj2+Fm20mBDHurM0tmDh5XcLBmzO0=; b=yyj8H+HO
	0lEcwPvsPIKedyFwvpt6C7idg6C71qRWiMru79jaMnbydSrBWisIMNPVooAYEPIb
	vPWmT5pHGXVnv2BdMpIqsbwKAYa8usJOAP4ScHK1YDw+ZUsemauGcvRVmYhPgyNV
	Kgjpaet3X9e6xAzOmx+cIeaVu5lXBV4IuLsGFmQgqm7BjwkdsLK6NEUT1BlzpZMj
	vnTWSkC0LetbFYXLePJk4rLXdzLJhHxdCojK8G4SD9vt7LkmPeI/pXvUoPPA7y67
	HSGesKprGMkQl2/pAP+EIyZAvbs7EB1FndLXRJzjKXUOBlZXYGIvnSThowLAh8Og
	0RBn22oRc+9rfQ==
X-ME-Sender: <xms:TJOIXH3AvNBagiemGajvs9ULvyqvBsLxWrITiWua50XwS33ImMdFKg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeelgdekudcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedv
X-ME-Proxy: <xmx:TJOIXNueZMJXfTUUz9Gs8ytgtd05xSs_BbkpK0Te2gh0kBStvQxm5g>
    <xmx:TJOIXFhg3RXYSKtAfP0id-ORFLnywvOH9XztA92WXhYgKvywYGBiHg>
    <xmx:TJOIXG_TfejfR1p_x9F8trV46aWPk5MaOEaxE3Yj2NDyP3iN-nMnQQ>
    <xmx:TJOIXAOIoVq0HirRru5eZTkqHIeErAmJ2-NuN0hIOfUEhOB-yMgmEQ>
Received: from eros.localdomain (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id CBF93E4360;
	Wed, 13 Mar 2019 01:21:12 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 3/5] slab: Use slab_list instead of lru
Date: Wed, 13 Mar 2019 16:20:28 +1100
Message-Id: <20190313052030.13392-4-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190313052030.13392-1-tobin@kernel.org>
References: <20190313052030.13392-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently we use the page->lru list for maintaining lists of slabs.  We
have a list_head in the page structure (slab_list) that can be used for
this purpose.  Doing so makes the code cleaner since we are not
overloading the lru list.

The slab_list is part of a union within the page struct (included here
stripped down):

	union {
		struct {	/* Page cache and anonymous pages */
			struct list_head lru;
			...
		};
		struct {
			dma_addr_t dma_addr;
		};
		struct {	/* slab, slob and slub */
			union {
				struct list_head slab_list;
				struct {	/* Partial pages */
					struct page *next;
					int pages;	/* Nr of pages left */
					int pobjects;	/* Approximate count */
				};
			};
		...

Here we see that slab_list and lru are the same bits.  We can verify
that this change is safe to do by examining the object file produced from
slab.c before and after this patch is applied.

Steps taken to verify:

 1. checkout current tip of Linus' tree

    commit a667cb7a94d4 ("Merge branch 'akpm' (patches from Andrew)")

 2. configure and build (selecting SLAB allocator)

    CONFIG_SLAB=y
    CONFIG_SLAB_FREELIST_RANDOM=y
    CONFIG_DEBUG_SLAB=y
    CONFIG_DEBUG_SLAB_LEAK=y
    CONFIG_HAVE_DEBUG_KMEMLEAK=y

 3. dissasemble object file `objdump -dr mm/slab.o > before.s
 4. apply patch
 5. build
 6. dissasemble object file `objdump -dr mm/slab.o > after.s
 7. diff before.s after.s

Use slab_list list_head instead of the lru list_head for maintaining
lists of slabs.

Reviewed-by: Roman Gushchin <guro@fb.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/slab.c | 49 +++++++++++++++++++++++++------------------------
 1 file changed, 25 insertions(+), 24 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 28652e4218e0..09cc64ef9613 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1710,8 +1710,8 @@ static void slabs_destroy(struct kmem_cache *cachep, struct list_head *list)
 {
 	struct page *page, *n;
 
-	list_for_each_entry_safe(page, n, list, lru) {
-		list_del(&page->lru);
+	list_for_each_entry_safe(page, n, list, slab_list) {
+		list_del(&page->slab_list);
 		slab_destroy(cachep, page);
 	}
 }
@@ -2265,8 +2265,8 @@ static int drain_freelist(struct kmem_cache *cache,
 			goto out;
 		}
 
-		page = list_entry(p, struct page, lru);
-		list_del(&page->lru);
+		page = list_entry(p, struct page, slab_list);
+		list_del(&page->slab_list);
 		n->free_slabs--;
 		n->total_slabs--;
 		/*
@@ -2726,13 +2726,13 @@ static void cache_grow_end(struct kmem_cache *cachep, struct page *page)
 	if (!page)
 		return;
 
-	INIT_LIST_HEAD(&page->lru);
+	INIT_LIST_HEAD(&page->slab_list);
 	n = get_node(cachep, page_to_nid(page));
 
 	spin_lock(&n->list_lock);
 	n->total_slabs++;
 	if (!page->active) {
-		list_add_tail(&page->lru, &(n->slabs_free));
+		list_add_tail(&page->slab_list, &n->slabs_free);
 		n->free_slabs++;
 	} else
 		fixup_slab_list(cachep, n, page, &list);
@@ -2841,9 +2841,9 @@ static inline void fixup_slab_list(struct kmem_cache *cachep,
 				void **list)
 {
 	/* move slabp to correct slabp list: */
-	list_del(&page->lru);
+	list_del(&page->slab_list);
 	if (page->active == cachep->num) {
-		list_add(&page->lru, &n->slabs_full);
+		list_add(&page->slab_list, &n->slabs_full);
 		if (OBJFREELIST_SLAB(cachep)) {
 #if DEBUG
 			/* Poisoning will be done without holding the lock */
@@ -2857,7 +2857,7 @@ static inline void fixup_slab_list(struct kmem_cache *cachep,
 			page->freelist = NULL;
 		}
 	} else
-		list_add(&page->lru, &n->slabs_partial);
+		list_add(&page->slab_list, &n->slabs_partial);
 }
 
 /* Try to find non-pfmemalloc slab if needed */
@@ -2880,20 +2880,20 @@ static noinline struct page *get_valid_first_slab(struct kmem_cache_node *n,
 	}
 
 	/* Move pfmemalloc slab to the end of list to speed up next search */
-	list_del(&page->lru);
+	list_del(&page->slab_list);
 	if (!page->active) {
-		list_add_tail(&page->lru, &n->slabs_free);
+		list_add_tail(&page->slab_list, &n->slabs_free);
 		n->free_slabs++;
 	} else
-		list_add_tail(&page->lru, &n->slabs_partial);
+		list_add_tail(&page->slab_list, &n->slabs_partial);
 
-	list_for_each_entry(page, &n->slabs_partial, lru) {
+	list_for_each_entry(page, &n->slabs_partial, slab_list) {
 		if (!PageSlabPfmemalloc(page))
 			return page;
 	}
 
 	n->free_touched = 1;
-	list_for_each_entry(page, &n->slabs_free, lru) {
+	list_for_each_entry(page, &n->slabs_free, slab_list) {
 		if (!PageSlabPfmemalloc(page)) {
 			n->free_slabs--;
 			return page;
@@ -2908,11 +2908,12 @@ static struct page *get_first_slab(struct kmem_cache_node *n, bool pfmemalloc)
 	struct page *page;
 
 	assert_spin_locked(&n->list_lock);
-	page = list_first_entry_or_null(&n->slabs_partial, struct page, lru);
+	page = list_first_entry_or_null(&n->slabs_partial, struct page,
+					slab_list);
 	if (!page) {
 		n->free_touched = 1;
 		page = list_first_entry_or_null(&n->slabs_free, struct page,
-						lru);
+						slab_list);
 		if (page)
 			n->free_slabs--;
 	}
@@ -3413,29 +3414,29 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
 		objp = objpp[i];
 
 		page = virt_to_head_page(objp);
-		list_del(&page->lru);
+		list_del(&page->slab_list);
 		check_spinlock_acquired_node(cachep, node);
 		slab_put_obj(cachep, page, objp);
 		STATS_DEC_ACTIVE(cachep);
 
 		/* fixup slab chains */
 		if (page->active == 0) {
-			list_add(&page->lru, &n->slabs_free);
+			list_add(&page->slab_list, &n->slabs_free);
 			n->free_slabs++;
 		} else {
 			/* Unconditionally move a slab to the end of the
 			 * partial list on free - maximum time for the
 			 * other objects to be freed, too.
 			 */
-			list_add_tail(&page->lru, &n->slabs_partial);
+			list_add_tail(&page->slab_list, &n->slabs_partial);
 		}
 	}
 
 	while (n->free_objects > n->free_limit && !list_empty(&n->slabs_free)) {
 		n->free_objects -= cachep->num;
 
-		page = list_last_entry(&n->slabs_free, struct page, lru);
-		list_move(&page->lru, list);
+		page = list_last_entry(&n->slabs_free, struct page, slab_list);
+		list_move(&page->slab_list, list);
 		n->free_slabs--;
 		n->total_slabs--;
 	}
@@ -3473,7 +3474,7 @@ static void cache_flusharray(struct kmem_cache *cachep, struct array_cache *ac)
 		int i = 0;
 		struct page *page;
 
-		list_for_each_entry(page, &n->slabs_free, lru) {
+		list_for_each_entry(page, &n->slabs_free, slab_list) {
 			BUG_ON(page->active);
 
 			i++;
@@ -4336,9 +4337,9 @@ static int leaks_show(struct seq_file *m, void *p)
 			check_irq_on();
 			spin_lock_irq(&n->list_lock);
 
-			list_for_each_entry(page, &n->slabs_full, lru)
+			list_for_each_entry(page, &n->slabs_full, slab_list)
 				handle_slab(x, cachep, page);
-			list_for_each_entry(page, &n->slabs_partial, lru)
+			list_for_each_entry(page, &n->slabs_partial, slab_list)
 				handle_slab(x, cachep, page);
 			spin_unlock_irq(&n->list_lock);
 		}
-- 
2.21.0

