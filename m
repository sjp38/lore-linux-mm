Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 365EBC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 00:03:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CEDFF20872
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 00:03:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Pn+r46lj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEDFF20872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 793D16B000A; Sun, 17 Mar 2019 20:03:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 742ED6B000C; Sun, 17 Mar 2019 20:03:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 630F26B000D; Sun, 17 Mar 2019 20:03:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3808C6B000A
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 20:03:47 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id l10so11146114qkj.22
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 17:03:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3DA8U0JuAXup7ms+uinV4GHOJ8keBBsE3LMsYr877sE=;
        b=iz4hb4f6hJd5Ox1WEQljurl3VUA2Eyyzs2Z/ZGBPQi/iJzrGjUsAmN1s5t2Ge6sUpe
         h7Ae8Y29tE7jUCpE6KtbpeEtG71e2oDJ78ioIOyG1q+gnv2c/13rQfU6kI5rY/RFTRXW
         YGv0oqoyVkiNyeDv7ggsg9/uYmN6ZfJ6iFshXwhT/Vpg5irRc2r3gtAXoemyX1GcEdoo
         05z8VqJhf5c3JJKQObTLcUjsSeH4dWwm0V1iH5mDuNIIWj8or0XKVZWjMBW6WD8JYsBd
         2C2bzOV7R6FbMDbDk6Z2SaesnwriMyaSqMaqP8NumqNy8RM3dXfN82C4SAF7cGNLrh41
         JfGA==
X-Gm-Message-State: APjAAAXcP1zP9D6nP68eLSChNlxwF97QYMsF0ckyLcIznJhfkfKyO4uY
	lrVc6pzS7eVG92i3LCaoQ5wJ2lHIWdpjvlaOmuguqBF2uCO6WRhuUAhuJcn3X79uBGbj2CYA85l
	UIigP4eX4m+KF6NXnxsqz5UPoZEGnk13lAz1XnAa8yH+UELlJZ7k71zq8s57TR/c=
X-Received: by 2002:ac8:7513:: with SMTP id u19mr11961561qtq.202.1552867426969;
        Sun, 17 Mar 2019 17:03:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfLUCvdkAkgRP2BUQPUXIfhjrQSS68pHmPL0Zj1P4G+MeqCXQS9UTXRXogfNB2tUrGm9I2
X-Received: by 2002:ac8:7513:: with SMTP id u19mr11961497qtq.202.1552867425553;
        Sun, 17 Mar 2019 17:03:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552867425; cv=none;
        d=google.com; s=arc-20160816;
        b=fJRXPrnI5upIr+RAuKgosRNn7kQleFVKelZDc1UAi2vydKhenSVv5VB1yJS7nAaB0Z
         3v4OIY78/JqSX3Po9fWiJr6ihnIgRjVKV/zSNP1JitIsLCX009/hviQvv3eWkwi7st3a
         XwHdtsmO4tx6BkYGZ92sAm70BGsB9D+xgMcVQ/GCuDNuMllu3f/MJeYTRDnmwKIpkIIr
         +dNRA7idajJM6AoHP9FCMN8rl5SoG0rYdt+BZPdIHtNO0mIOYNWrQqMchbOmiEQdr+hj
         jb2/F6y0cAaTsuC1MPAAWcP4fr982nYDj9J1P4iTACiKiA8IYni6hs4UlmlErOhdnpRc
         /N5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=3DA8U0JuAXup7ms+uinV4GHOJ8keBBsE3LMsYr877sE=;
        b=jVfW4bWet1a+RuDbv5F7WtmQfoJKkZA0SpbRzKYRPtKPoxDHvvBzkDJaSY2Ds3b1N3
         Ji2imLA6E1fg51eLii6JmzNg5Kh4W3l2OR1AEg1+nj2joCA4vzreUtnOVaY/JzeLlCLG
         pvIrFxmpkSjX8lx1IpELdW0S45VHUz0k1C50oJIld7CWelfA8taB/2rUxtVx8VgSj1YG
         z+oDayYPzQRXYVkqnD7tWngqBgQTZeL2IoinOREccHZVvinbDj0ED6+XCOVKPjrVnKuc
         QSU/5c5VkgnvNaJrvGAmdHsVWFeEbQDAsGn06UrToz30Pz++8ehaFxisXtr+GwO4Ecio
         bfsw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Pn+r46lj;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id d16si1180308qto.126.2019.03.17.17.03.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Mar 2019 17:03:45 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Pn+r46lj;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 4919521B88;
	Sun, 17 Mar 2019 20:03:45 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Sun, 17 Mar 2019 20:03:45 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=3DA8U0JuAXup7ms+uinV4GHOJ8keBBsE3LMsYr877sE=; b=Pn+r46lj
	QPFt2Mr6He5Um7gHJ4W9JLWGROl2IHommcPkLzy/o2og29A4mTzOBioH6TAsGeNk
	QPyIuhjHKASD6PsU++e9HE04h3XW1vzY031bAfy6hjKtIBJOPy0lxBBjrKs+xnmT
	PWhE/GxXiVn00MxZstjBRcJqKLq4JQADX9MB7rp55Jr3GtVUo+mDMe8uJg4N+oSo
	rTv1vYfGRKGAC/xZQF6+5G15JdfowCh+sAWpjhzSU+h6Ci3TvyU+5zyCgXcLe7Mh
	NGYE4Jx1SY6BBXhn0Y4SqF7U5ENlI5F0eXEiF8092/xZA1gVwjW5qDFwKj4JlR88
	kqYs3YGrcdtVKg==
X-ME-Sender: <xms:YeCOXNOvjupXkIyuUvtphvaWsm5hriC5E67KaTY_jRXquO0gggq0DA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddriedtgddukecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddukedrvdduuddrudelledruddvieenucfrrghrrghmpehmrghilhhfrhhomhepthho
    sghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepge
X-ME-Proxy: <xmx:YeCOXNa0FnSwpeCfrA8MVqEY6qHHOxZr4NFgjJ4vGCt5Jcdf21Sm1g>
    <xmx:YeCOXMP-uzsJA2W8khMJYwXorpTdIqM_b7Ckc2oAszpAcCXQokzXTA>
    <xmx:YeCOXLVD97V2HJTjWPlpzfv66FEJ7q1lFPf8fxsC3a1ks8n03cBrPA>
    <xmx:YeCOXPVBE6sbXwjjFij1Se6e1E6k_Yfa_RE62Ces4DVtppUUU71u4A>
Received: from eros.localdomain (ppp118-211-199-126.bras1.syd2.internode.on.net [118.211.199.126])
	by mail.messagingengine.com (Postfix) with ESMTPA id BCD9FE427B;
	Sun, 17 Mar 2019 20:03:41 -0400 (EDT)
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
Subject: [PATCH v4 5/7] slub: Use slab_list instead of lru
Date: Mon, 18 Mar 2019 11:02:32 +1100
Message-Id: <20190318000234.22049-6-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190318000234.22049-1-tobin@kernel.org>
References: <20190318000234.22049-1-tobin@kernel.org>
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

