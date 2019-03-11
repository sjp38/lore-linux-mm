Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C776C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 01:08:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B464A206DF
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 01:08:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="zbEIlQFi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B464A206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 550B88E0006; Sun, 10 Mar 2019 21:08:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5004E8E0002; Sun, 10 Mar 2019 21:08:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C9BB8E0006; Sun, 10 Mar 2019 21:08:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 172868E0002
	for <linux-mm@kvack.org>; Sun, 10 Mar 2019 21:08:31 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id k21so3287819qkg.19
        for <linux-mm@kvack.org>; Sun, 10 Mar 2019 18:08:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CxGqyPgRRgFsJNIUYcTQsfjDYACO56dLDTf5SGEtnkY=;
        b=OLUwD8O8uD9bPV3H69LNeOIafKJ+P89gbWJqb6Q3YGXvMMQW4VQstsi6c8jRz37ylQ
         yt5U6xJ2inKR3scdc9Mqyi/T9n4KXOCcQIg/U6i/ifVmlw+usC4QoqhDUqTTeLzWt6ky
         YH+JYY7NFuggMN03tXn0sCR8R4uywVtpjkbqeiCdbfguVvd3gTf7KlX6PPnptCd2flsH
         2g9yhD+rPXxhwsZKz43OTdiM4olbKNopqGB0FglvIQs95p85o0yNIg7lAbgkh4+8/Ngp
         fOQphLMPa1bGbvYY7zy5EUpV/uTzseG7H8nK74xKahSNgvMydFJtF55GtjE0jq9WpGBo
         pswQ==
X-Gm-Message-State: APjAAAV4PESH4u79DRRyFSXzLbGwfxD+ouPZwKMKVOvsHIltr0PIHtYe
	7vX8SU4h5Eb9B/J39PiE9ptTg0RuQfMkrueT71kEFHOFF7lBvafnHk+1oSZ9liKA+uso90nGth2
	NmgqWa6AbjfPcDURDlqvRWuFIvufC6FnjZFchQMdG7/Z0N6YcwLgrPHbhknmUkmY=
X-Received: by 2002:ac8:266d:: with SMTP id v42mr23371910qtv.116.1552266510879;
        Sun, 10 Mar 2019 18:08:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqwlYwUy2VbDJW0aidQRGcZfE3iKbV5WgdLxnJPDjMRTmoPpJ1XSzE9glY8vjlVh8oKYDX
X-Received: by 2002:ac8:266d:: with SMTP id v42mr23371855qtv.116.1552266509061;
        Sun, 10 Mar 2019 18:08:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552266509; cv=none;
        d=google.com; s=arc-20160816;
        b=c3ffAkXKn55snukaMhU518C1dGikV8nA0yUm+ECDtapudDEDEHgg/nzegks7qrUojl
         bk1Etk44BSn9gVS14pxAMEDKWYeLHKjTcn36QhAOnlm/clWSr8N/FfkrKbBpSKhhxB2x
         ClinnRavTxSA3d61oyQTu9UOBSHR7RZMO+JWKi9HYJYj7f/owf+s/JXwLsD/TgO7Ie1I
         qYrShwKbfSRq9i8UATTnPu1QX77wkVoWI5wAfjSJLPl1SnbrW/49zQYUAz0izAe4Xc2i
         1W29rbOFfZL+QGtEh3oUqSNPXf2y3eQSGI80zfGTm+JRYCsLp/E5Frws6dU7/c6CmYHO
         N4qA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=CxGqyPgRRgFsJNIUYcTQsfjDYACO56dLDTf5SGEtnkY=;
        b=ZKPE28kbjP/Z9ZzO0Po8dEHeCr5piCXEnCKjzpe2J0UqdPG6qaP/saqwB+Vr1h4GRF
         BFw4x1vQlh0p241RHA2rLqYayYYXKipqM7JnoWMC/fRBW01cVn16wehtKqOqWtY2unNy
         EmaYM+CFiKpUQxMAsEeqCDH1Uqmb02KTdmO/PJhzGQ7BzIT1ntBq8/JVNklEU9B1TTZE
         NjpM4nL7hvx4yC+yuqkjBotEWMYNqTo+G+uRg8VRaZ3oGPbrj2ywD4As7zCqWtdiUHkN
         F7xH/1fnxlJdPe6cVQ3cyL+LeXPAbTQhQAKv7oVVKeIwJQr5r1BImgKbYwDAZfcExJOg
         2U6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=zbEIlQFi;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id m4si2415052qvg.167.2019.03.10.18.08.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Mar 2019 18:08:29 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=zbEIlQFi;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id BE2DF21F86;
	Sun, 10 Mar 2019 21:08:28 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Sun, 10 Mar 2019 21:08:28 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=CxGqyPgRRgFsJNIUYcTQsfjDYACO56dLDTf5SGEtnkY=; b=zbEIlQFi
	Tke8QZo8EK3u9652auMp3yuH27RKJrSxGU/IXsMu6GjmwBuPx1RxrbgKPbzyLX/h
	OzALvVjZYChQHXV2jNbDF12ReyQhbvNXaUVTIQQMOuiKptz4mRpfBdEqVDTdHpGc
	7lPi3jO+XLngDVR0gOKuOmfTnNOob6e36iRwAZjrtUgkoDUArnS0eqjUiui9Jreb
	weo0uM0XrXQMmipthLO9uylb2aKet/zO9trnhamDkEtinlBeFBzdKvOOBnjFJJ5W
	0D720pDlcXN5yN5fsIynrBvmt+B9TKtf6uJ7r2NrInTGfjJ+mHrXVOWwmOi19q6E
	uuz7bGHupAes4A==
X-ME-Sender: <xms:DLWFXKcj_bWyh4sNWfLm5SObd2kaQdHx3uFqp9p6qTDk4pmMppi0yQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeehgdeftdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddukedrvdduuddrudelvddrieeinecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedv
X-ME-Proxy: <xmx:DLWFXFdUHhZADXSSXcU48tRGoPpPOvw2B8UmtNZ9aI67cSd6HFHvmA>
    <xmx:DLWFXD8XrF_FOxNokSqDDmuw5CPPZDdG4Bv7Rp9d7klLqTsZ0nS0Ow>
    <xmx:DLWFXOKQrbsj5wZ1bcENurnMNRBO5OJCGmeUrBQXg-EKaNqRczHBjg>
    <xmx:DLWFXFj512bKHTju0WWW5HbAa6bLKVjLqJIQ87TnJbg8j-a4At597A>
Received: from eros.localdomain (ppp118-211-192-66.bras1.syd2.internode.on.net [118.211.192.66])
	by mail.messagingengine.com (Postfix) with ESMTPA id 947DF10312;
	Sun, 10 Mar 2019 21:08:25 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 3/4] slab: Use slab_list instead of lru
Date: Mon, 11 Mar 2019 12:07:43 +1100
Message-Id: <20190311010744.5862-4-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190311010744.5862-1-tobin@kernel.org>
References: <20190311010744.5862-1-tobin@kernel.org>
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

