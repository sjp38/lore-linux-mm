Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D927CC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 05:32:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B600218A3
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 05:32:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="QB7lwDAt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B600218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36F6F8E0008; Thu, 14 Mar 2019 01:32:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F8868E0001; Thu, 14 Mar 2019 01:32:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 171B48E0008; Thu, 14 Mar 2019 01:32:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA7ED8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 01:32:27 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id h28so3380440qkk.7
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 22:32:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CDYia77DvmbgSMo0ig5s08PvnjuxIbLDQT/0qMx7ZFE=;
        b=NJatEEgxwJVSpHkBdOUtISFegI8GpIrDWQwiMkQ/Fl/X9DJu3+4uuiUrux7GLE7AEw
         3s13wtZV4qFrCPHx1vyS8NZtEaRcOgUCQ6o0HGwnGtRTj/6HSgggKBjxXuc9l/V4SOAC
         ZoMeXCI0qzlJShv3Mor84MAr+C3YsICHyoggCDkhXv6w3Rvn0kd9rcHesImW0krWH7ZA
         QKKzXFCbevawJWLm7asfKb4JsOkyrSO8qhZfgROGgSTmiZByMJUg7YyGpI9XBRMmq7cm
         wlXKVN996jd849IhxvfT8vObZ0PQJYvBZhM0AuqilKgCwldoBf0S+rmQKA7zHoy9rryG
         nhjw==
X-Gm-Message-State: APjAAAXETNQ5dHAqfGLXShyLQ/yzHbPj3jwse/jZ3gN05puYv4chxBms
	UPt0q7KHffdmpCYr86uTFlEhjveHCJFP6PLixp1GWmJWLn+S54dDeYEpR2yl7j7Lp1yWTs6wpDU
	cs7SLmGMpzY+RZ9CU+wzNHjtCZjUpUd5/uAkG/IcxkmET7tCBxZh+fP4uxozW8/o=
X-Received: by 2002:ac8:504c:: with SMTP id h12mr17963054qtm.208.1552541547633;
        Wed, 13 Mar 2019 22:32:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKvcrvczkmHiP1Z2ynRV2hj8Fcif2vs4TDHROLQuiMWXwSkxHkFzz9EaLC8XcEkuqu0HIq
X-Received: by 2002:ac8:504c:: with SMTP id h12mr17963002qtm.208.1552541546303;
        Wed, 13 Mar 2019 22:32:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552541546; cv=none;
        d=google.com; s=arc-20160816;
        b=vu6LAmGrvuHvptwhTbQ0lWefqnlLp7Pw5qv1f1jVvE5r0xYoXOfeQnEL0FTBCRvYMK
         aCjomSL6ysMvUY5ixy4agMDkMPOCfs5KlZ8SdnU1Ose/OaoUx9MmpV7c+DIqyVbjFJC2
         rvaclFWXYz89Kyb5hggM38RfEMOZ7NrKGI2aCHtb9K6q+mBB8RZQO5Ke8rScKsB+CL+4
         nNgSfhnvR/+bYX/jrP6jUBDtF+naVqMyxA9r5UY0YQFW2ZoBfnG8fJLpvZBcpJG8Ig0X
         4IAjvjEPiFy303NeqQU4OC2bu39GIZvYa0kO3++p1CoPO+S9q+QZyz0kfQpxiCB25zNF
         SYGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=CDYia77DvmbgSMo0ig5s08PvnjuxIbLDQT/0qMx7ZFE=;
        b=F5L3jjPP6TyLA4eIXHa4GDLaUjiyQVJYDXVT1Gmr19TNvwMaHMtckKHmEPiN+Ul9VO
         8lo1+CuW1c1Co67B8QZAyBPw8aIB1z/RwJ5HCbGNyHEQFBAUbKaSBfI0p8/UoOjx8fLw
         YkFVc9+wpfPqz9KeNLze56c7pwNGngFK83ihUWr0AirfmifxA8cg+qu+8tc/fxKVA4Vo
         K6TUnoYTON1HSrhHSEH+XtSRWB4aM8fmwUC1pqP98oYniQj5tk1yIhRc7YDPmG5p2j9U
         n1EPkstxc0E7N+PMyHL/T4wpsSkzCMKpNQKmseLTv+3rVHnJp0kPbWn0iqMiBV2GT7ls
         /8jA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=QB7lwDAt;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id x10si3650929qkf.110.2019.03.13.22.32.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 22:32:26 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=QB7lwDAt;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 08CC2214E0;
	Thu, 14 Mar 2019 01:32:26 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 14 Mar 2019 01:32:26 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=CDYia77DvmbgSMo0ig5s08PvnjuxIbLDQT/0qMx7ZFE=; b=QB7lwDAt
	qaYokPpKcM/8jy+xe5qQ75mWZyiWH1ykAoex1QxLI+ynOh3z9vwrRxFcLZXdxFc1
	JOsNgRKpidOoAoPm8Zpf9xDBpIAZNnuZdhwoc3Kpm3NpOVs9H259Oe9RDX5g8wGD
	/3N06MO17idYXC/sgIn8rADeyEFppnF93UPUbchhaZe52loh8kI+dJucH0i6tLVr
	70G4QqPrixhWRpBZwgapwUPUtE+F3fFNJYN7j3trb70y1oq54g7N4yEUFm5FdJw1
	E3SyT0tBzEk2t5rYTSdDq4xhkNcygrqSPKOV1/XqHm5uDvE085UTYlkAseVi1PvM
	NDWjoFCpqchYvQ==
X-ME-Sender: <xms:aeeJXET4CmGUOZzRurzr2gKL5HzIT3b3Pi53QCNRhyYAVhf6hsfcmQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrhedugdekgecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpeef
X-ME-Proxy: <xmx:aeeJXKvBGukFQPbX1c219GowTD2JnQ8TcNkWIwlpGKjBMb0QRoYw-Q>
    <xmx:aeeJXKk9hIS-1yA5HdBRTimdiYUiIe6FUPNSHGTZVhCP0AAwfuQzKg>
    <xmx:aeeJXLIxCswZ8ajxU3th4VnbA72U3xeiGGpnpK_YN3W0pZOAOectbA>
    <xmx:aueJXH6BbapL2513L7uUa-9Pv8K04b73F_H_Q8QPaGVBt9i0SMkQuQ>
Received: from eros.localdomain (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id 6CB94E4482;
	Thu, 14 Mar 2019 01:32:22 -0400 (EDT)
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
Subject: [PATCH v3 5/7] slub: Use slab_list instead of lru
Date: Thu, 14 Mar 2019 16:31:33 +1100
Message-Id: <20190314053135.1541-6-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190314053135.1541-1-tobin@kernel.org>
References: <20190314053135.1541-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently we use the page->lru list for maintaining lists of slabs.  We
have a list in the page structure (slab_list) that can be used for this
purpose.  Doing so makes the code cleaner since we are not overloading
the lru list.

Use the slab_list instead of the lru list for maintaining lists of
slabs.

Reviewed-by: Roman Gushchin <guro@fb.com>
Acked-by: Christoph Lameter <cl@linux.com>
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

