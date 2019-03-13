Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAB06C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 05:21:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7074F2183E
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 05:21:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="yDZ2iVVm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7074F2183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 234938E0005; Wed, 13 Mar 2019 01:21:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BDD58E0002; Wed, 13 Mar 2019 01:21:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 084D38E0005; Wed, 13 Mar 2019 01:21:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D5E428E0002
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 01:21:15 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id e1so745726qth.23
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 22:21:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Y8N9T28j5V2rcuZvEFbiMge48OZHR3sYOunVsFBM+HA=;
        b=pPb2Zath7xj5uI0S/V5cgjxpxsCzzOdXrLg1dTBvjKLCSQZrijqfYSgqWfB5HvRAUP
         VJRO2JIwF6bcUVRximEOEmZoHivdKY0T/jox8B6Em/XKbnhhlaPkejceCFDCZ2m153ng
         wj0d4pPP0F/oWJh8nUsRkGWE3hRV4/4ZQ5msry/T8p/MRzdw3XZzEUt1yhWP74Jqjs94
         oLMRI//ocfexT81v7XW78pFuL1KZk2TIaJleUuBoPtdrhL6IpmvMhfDnaQrh9Oetq1+c
         KUlNL0mWEVogqHocgSQWDeDKoEMv3dvjewGncKDU2vPGwGAK8SmIFpvdzGygN7+ryfYx
         lbPw==
X-Gm-Message-State: APjAAAUxonST97aeqPNvDBRIIEQFhf0U+5JtETzHgcDtT+J+VzfPFFGo
	jcZ0tfxnAE9vFmdubIT9wVdLcGgWSCCPHDW+dqNBoZwPVQOoK9ny4E/P8enddc8+s5ttwiR3/YP
	FULEQ3o0bcimUUcnb+qdEt+YrKU3EArxfUF2i0W5Fo/0UtLSupdzERw3qwJYKLlA=
X-Received: by 2002:a37:63cc:: with SMTP id x195mr21396504qkb.293.1552454475638;
        Tue, 12 Mar 2019 22:21:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCeiFfYvbPSZW8GCLkt3HWPnQHwpSKkanNHgabTY2q2uctlLBWQrvB34yR9khTM0kyZ0Gp
X-Received: by 2002:a37:63cc:: with SMTP id x195mr21396469qkb.293.1552454474570;
        Tue, 12 Mar 2019 22:21:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552454474; cv=none;
        d=google.com; s=arc-20160816;
        b=nHZW0oFC1NzhedpOa9FxvaA+4Xn+ZGfV6ifxsNS2mcW29JcK2CISpZSKRSJnTv4cEK
         YIdZZ/FQY9+PlFHnpxwb5FJFPu3Ag0y2z0MXupAjcIfeMXyawdPqfF7r1nR70uswhuxZ
         +Nsmr6Fx9Gd+pPKisUNTksIYkDRUPoaNCEwgBJWAkLOcSWEXQoerzIuX6ZFuiqy+g/35
         owJlKCq8pVfq9yASfmT4sjD6uBoWitoDaeWcpfXFsm+e/ZCMlo0HXVhW/lD6jxR6s+p+
         PplfsmpHfuVieeU4iJxaPuF4LG8wZqIF/+n5sXtNdU7G+qIXxQdouCqTpoVaLR2foH7g
         zwKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Y8N9T28j5V2rcuZvEFbiMge48OZHR3sYOunVsFBM+HA=;
        b=vx+K54r781z+pWrOgVdz9XeY933ZG6TxN3vwwGrAZ/vQ4tFaiQC7YNe+qkXzQEqqCr
         U76/tmaflDm8TfhTtAtO1zJKYrjq8CE+SLn8NCeuA9PLrgYa3FOODfTfqXCVCmsrulPh
         6g6zkJawXdHXLUxuJkR7CAn8ACRlmirMfs8lIL3Uihqaic6ZQu7lUX6PjaZSigZYWDeL
         B68cr3GPoYCCPH9fPtVIi6W3EPjaU5FdTMciePBCXVVefIJRaXxYFxe753O7fO8wtZSr
         e6nciWDjmkOi3m1/QNWsz6Odk/x0Rr8GFrXo/LxzIvHQCCem6y9HmqMdhifJKlNeVU0O
         oJqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=yDZ2iVVm;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id t125si1614775qkf.21.2019.03.12.22.21.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 22:21:14 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=yDZ2iVVm;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id F3D4938B7;
	Wed, 13 Mar 2019 01:21:12 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Wed, 13 Mar 2019 01:21:13 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=Y8N9T28j5V2rcuZvEFbiMge48OZHR3sYOunVsFBM+HA=; b=yDZ2iVVm
	5psjseLHdnznxFaT+DnVAdhsGId6gAWyeg0vBMHl0JMAREDzaKD33cI/KXX7JAcD
	9Vnok+jjUycsqcCVHBOtDKz18bIa7S3gCoxUOaJRXNchyPWSoIbDEYiJd56uv8OJ
	JKYFunc9hm8VN3sxCBG+a/vQpBzoHIj0erW38KdVljPjv4dTGFmCzoAfdjR3A8Hr
	Y55NhT1TTURNsDPgOc9USK/R1NriKmLAljrDbIw8Ui5SI1BehgKLGvIRiZRVKVlE
	m2VSOrztE9rdxZ2iepOqHO0fujjrr3zY0mROLaFEj8oxjNYl+hs2m/ux/TJz4NBS
	pfLLdpQZWkMGEg==
X-ME-Sender: <xms:SJOIXPbB6ErmANB75MNv09ucSTaAaHGOFMjgYby9DFP9ePixKuunvQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeelgdekudcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedu
X-ME-Proxy: <xmx:SJOIXOFboK-24D-RczsQjuToTwlVj4e4hvTSyPmmWCdf5HWNqeg5GQ>
    <xmx:SJOIXNnKtw0Q9XXH-hJXVeSTxcPhimSrTlHAz-p8xz8PTG9cWB0rgA>
    <xmx:SJOIXBeY2hyoKZjFJS0XbxzHM5XJOyWNritZfLfmBQPOu2t7_IAV_Q>
    <xmx:SJOIXC1PeJ82S2tEada9V2hcjrnDpl50di76o2r9J_BMI107OflSXg>
Received: from eros.localdomain (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id 022ADE427E;
	Wed, 13 Mar 2019 01:21:08 -0400 (EDT)
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
Subject: [PATCH v2 2/5] slub: Use slab_list instead of lru
Date: Wed, 13 Mar 2019 16:20:27 +1100
Message-Id: <20190313052030.13392-3-tobin@kernel.org>
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
slub.c before and after this patch is applied.

Steps taken to verify:

 1. checkout current tip of Linus' tree

    commit a667cb7a94d4 ("Merge branch 'akpm' (patches from Andrew)")

 2. configure and build (defaults to SLUB allocator)

    CONFIG_SLUB=y
    CONFIG_SLUB_DEBUG=y
    CONFIG_SLUB_DEBUG_ON=y
    CONFIG_SLUB_STATS=y
    CONFIG_HAVE_DEBUG_KMEMLEAK=y
    CONFIG_SLAB_FREELIST_RANDOM=y
    CONFIG_SLAB_FREELIST_HARDENED=y

 3. dissasemble object file `objdump -dr mm/slub.o > before.s
 4. apply patch
 5. build
 6. dissasemble object file `objdump -dr mm/slub.o > after.s
 7. diff before.s after.s

Use slab_list list_head instead of the lru list_head for maintaining
lists of slabs.

Reviewed-by: Roman Gushchin <guro@fb.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/slub.c | 40 ++++++++++++++++++++--------------------
 1 file changed, 20 insertions(+), 20 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index b282e22885cd..d692b5e0163d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1023,7 +1023,7 @@ static void add_full(struct kmem_cache *s,
 		return;
 
 	lockdep_assert_held(&n->list_lock);
-	list_add(&page->lru, &n->full);
+	list_add(&page->slab_list, &n->full);
 }
 
 static void remove_full(struct kmem_cache *s, struct kmem_cache_node *n, struct page *page)
@@ -1032,7 +1032,7 @@ static void remove_full(struct kmem_cache *s, struct kmem_cache_node *n, struct
 		return;
 
 	lockdep_assert_held(&n->list_lock);
-	list_del(&page->lru);
+	list_del(&page->slab_list);
 }
 
 /* Tracking of the number of slabs for debugging purposes */
@@ -1773,9 +1773,9 @@ __add_partial(struct kmem_cache_node *n, struct page *page, int tail)
 {
 	n->nr_partial++;
 	if (tail == DEACTIVATE_TO_TAIL)
-		list_add_tail(&page->lru, &n->partial);
+		list_add_tail(&page->slab_list, &n->partial);
 	else
-		list_add(&page->lru, &n->partial);
+		list_add(&page->slab_list, &n->partial);
 }
 
 static inline void add_partial(struct kmem_cache_node *n,
@@ -1789,7 +1789,7 @@ static inline void remove_partial(struct kmem_cache_node *n,
 					struct page *page)
 {
 	lockdep_assert_held(&n->list_lock);
-	list_del(&page->lru);
+	list_del(&page->slab_list);
 	n->nr_partial--;
 }
 
@@ -1863,7 +1863,7 @@ static void *get_partial_node(struct kmem_cache *s, struct kmem_cache_node *n,
 		return NULL;
 
 	spin_lock(&n->list_lock);
-	list_for_each_entry_safe(page, page2, &n->partial, lru) {
+	list_for_each_entry_safe(page, page2, &n->partial, slab_list) {
 		void *t;
 
 		if (!pfmemalloc_match(page, flags))
@@ -2407,7 +2407,7 @@ static unsigned long count_partial(struct kmem_cache_node *n,
 	struct page *page;
 
 	spin_lock_irqsave(&n->list_lock, flags);
-	list_for_each_entry(page, &n->partial, lru)
+	list_for_each_entry(page, &n->partial, slab_list)
 		x += get_count(page);
 	spin_unlock_irqrestore(&n->list_lock, flags);
 	return x;
@@ -3702,10 +3702,10 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
 
 	BUG_ON(irqs_disabled());
 	spin_lock_irq(&n->list_lock);
-	list_for_each_entry_safe(page, h, &n->partial, lru) {
+	list_for_each_entry_safe(page, h, &n->partial, slab_list) {
 		if (!page->inuse) {
 			remove_partial(n, page);
-			list_add(&page->lru, &discard);
+			list_add(&page->slab_list, &discard);
 		} else {
 			list_slab_objects(s, page,
 			"Objects remaining in %s on __kmem_cache_shutdown()");
@@ -3713,7 +3713,7 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
 	}
 	spin_unlock_irq(&n->list_lock);
 
-	list_for_each_entry_safe(page, h, &discard, lru)
+	list_for_each_entry_safe(page, h, &discard, slab_list)
 		discard_slab(s, page);
 }
 
@@ -3993,7 +3993,7 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 		 * Note that concurrent frees may occur while we hold the
 		 * list_lock. page->inuse here is the upper limit.
 		 */
-		list_for_each_entry_safe(page, t, &n->partial, lru) {
+		list_for_each_entry_safe(page, t, &n->partial, slab_list) {
 			int free = page->objects - page->inuse;
 
 			/* Do not reread page->inuse */
@@ -4003,10 +4003,10 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 			BUG_ON(free <= 0);
 
 			if (free == page->objects) {
-				list_move(&page->lru, &discard);
+				list_move(&page->slab_list, &discard);
 				n->nr_partial--;
 			} else if (free <= SHRINK_PROMOTE_MAX)
-				list_move(&page->lru, promote + free - 1);
+				list_move(&page->slab_list, promote + free - 1);
 		}
 
 		/*
@@ -4019,7 +4019,7 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 		spin_unlock_irqrestore(&n->list_lock, flags);
 
 		/* Release empty slabs */
-		list_for_each_entry_safe(page, t, &discard, lru)
+		list_for_each_entry_safe(page, t, &discard, slab_list)
 			discard_slab(s, page);
 
 		if (slabs_node(s, node))
@@ -4211,11 +4211,11 @@ static struct kmem_cache * __init bootstrap(struct kmem_cache *static_cache)
 	for_each_kmem_cache_node(s, node, n) {
 		struct page *p;
 
-		list_for_each_entry(p, &n->partial, lru)
+		list_for_each_entry(p, &n->partial, slab_list)
 			p->slab_cache = s;
 
 #ifdef CONFIG_SLUB_DEBUG
-		list_for_each_entry(p, &n->full, lru)
+		list_for_each_entry(p, &n->full, slab_list)
 			p->slab_cache = s;
 #endif
 	}
@@ -4432,7 +4432,7 @@ static int validate_slab_node(struct kmem_cache *s,
 
 	spin_lock_irqsave(&n->list_lock, flags);
 
-	list_for_each_entry(page, &n->partial, lru) {
+	list_for_each_entry(page, &n->partial, slab_list) {
 		validate_slab_slab(s, page, map);
 		count++;
 	}
@@ -4443,7 +4443,7 @@ static int validate_slab_node(struct kmem_cache *s,
 	if (!(s->flags & SLAB_STORE_USER))
 		goto out;
 
-	list_for_each_entry(page, &n->full, lru) {
+	list_for_each_entry(page, &n->full, slab_list) {
 		validate_slab_slab(s, page, map);
 		count++;
 	}
@@ -4639,9 +4639,9 @@ static int list_locations(struct kmem_cache *s, char *buf,
 			continue;
 
 		spin_lock_irqsave(&n->list_lock, flags);
-		list_for_each_entry(page, &n->partial, lru)
+		list_for_each_entry(page, &n->partial, slab_list)
 			process_slab(&t, s, page, alloc, map);
-		list_for_each_entry(page, &n->full, lru)
+		list_for_each_entry(page, &n->full, slab_list)
 			process_slab(&t, s, page, alloc, map);
 		spin_unlock_irqrestore(&n->list_lock, flags);
 	}
-- 
2.21.0

