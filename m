Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76C1AC4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:06:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 262B5207E0
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:06:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="CIjqBdlg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 262B5207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB0F96B0277; Tue,  2 Apr 2019 19:06:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C640F6B0278; Tue,  2 Apr 2019 19:06:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B52A26B0279; Tue,  2 Apr 2019 19:06:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 90E206B0277
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 19:06:51 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id 18so15041904qtw.20
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 16:06:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gJ4aFp/Hf0v/GP1gn4YkY0hhZE2uSZfGmW1/JObfUr4=;
        b=G7n2FEWo978u9iZZw4ZtOlmo5RT+HDAxCSRZuYAVPeqQz9Vf7q7qNiJjNRqh6kQAL4
         7EIehuKCjabUBZlOLBnssRDKHN/ZuYkhDmtcRDdK9+r8nj2NJn1MxDx+JV9Nsi9wEXCf
         8OMONILLRMVeJ11ysgUZfgR03yj/iFtkSOU/CSmc0NUnvCSxArUhbWOAX7Qmo6nJO3YP
         D170c+hoqBN8T7B0htp8h02HAXwfXAbeH+3S7vRDGxDrHZReFsMb+GKOWlLISBpqmFmt
         kzU05dm+DVjS+DQmfsztrWHMTWoBkyLc/OJWXDFgrNoSkoCwRWXQFieY2/wNacPYtY+D
         dwxA==
X-Gm-Message-State: APjAAAUvkO9pojkgqECd1nvGfe//ZBu5xmR1s/WawluO7zgH6gStAJzp
	DSDmOzxkX59dmyaTk1w6OdrpUbhtndKD/o22IvBTUF+6U0L9y3kflJGHjNuxZdNhv4GHqjqokT5
	11C5LN+SHMI+MKn/8MACKunFoNmYszYELvxTbdJ2TESv5AFZ/rZxQPJfg9d19wWU=
X-Received: by 2002:a0c:d25a:: with SMTP id o26mr61259475qvh.78.1554246411354;
        Tue, 02 Apr 2019 16:06:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfPYSlakVER7dtdh9WPnsJT1QpWSosXxnUlBpTnndP23+mhIqTffq7bboM4rTqXRuCd8s0
X-Received: by 2002:a0c:d25a:: with SMTP id o26mr61259434qvh.78.1554246410603;
        Tue, 02 Apr 2019 16:06:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554246410; cv=none;
        d=google.com; s=arc-20160816;
        b=y8vqbgjZWh8ILrIYcuFDBRkXIuEyeSfoI3o8UFEoGKDWQ3vXkoGRi4xVJbWRP/BjU5
         KFiGlHUCI8WJfSR+zbLY8hueZeufALNXXDKOVkJqSqhO8KR4MZ7OTn7arg+An5eQw3PI
         59NPu1KLGIKSgYxT4pEiUfdEGV4QvUGrSmdKEwLZ5BdrH3Xm9sUyC42pttkJ611CKWsK
         ZMuervNOePoehMjoh3A37qHOkrQtT1wJ+KsWAbRif7PzHCGx2VlzBsnp+iIItXv+d619
         38cpf+MtpkGwBNEcotPDry4Ts4Q5OWM5Z/iUY68uprxfHZHmofN+4Y9she37QzxrkspY
         VgFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=gJ4aFp/Hf0v/GP1gn4YkY0hhZE2uSZfGmW1/JObfUr4=;
        b=eVkN3NN9dLyUHlU2xSyqZD/GrDljlNKDmMRVDs9fHzrKTScyQyc5JyfG9UcMg4R4IU
         Apdayw3sKUwX0mMmmb76yb0+HB6T/U839Y0aCGX5wMj4pJuH6q4HR8LccyhO2Mj/LdjP
         00t0eTBFptdZ3bTn8TsG0t/aHxuOs9q4rAC+AuIigSKjhCxrS0KtKCo2Y0pz8LD2QEGx
         MvXF+UYvRlfC1k1ea6pglUl3CdpTIIDnW1r664lBwYggaVZuQBcF3/un9NOon7Gcy4/4
         GmnQ0tTgy4Dk1Ki35cC3hIvriOslkTyJxIRdbYNxsvrp6idfGOh82UHp6wSnLxrX5O26
         FT1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=CIjqBdlg;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id l25si2125153qtj.228.2019.04.02.16.06.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 16:06:50 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=CIjqBdlg;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 545232208C;
	Tue,  2 Apr 2019 19:06:50 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Tue, 02 Apr 2019 19:06:50 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=gJ4aFp/Hf0v/GP1gn4YkY0hhZE2uSZfGmW1/JObfUr4=; b=CIjqBdlg
	4pZi6byHB2UOnB7lSDMnuzKYQtIxxkQFbQacRaQVuQ3COHrquyuDyQyrIPElSA5j
	yAbr6GDGctSOU3N9wHRj4GEGxa/QHIgio+rRGfIvhf2EAqP10uxD5BdddpWg5q71
	4PWX27lwB6Lp+zoVH+B5b6tgekX+zOVnHiCQgzm68W2uy2E47LNctUnSiqq6WDgs
	GxoBKz2KBbFxmSfnlNAliVJOI51HEY+jA3xpD8lvWA44E5DFEXSxosPOqYvvkdRy
	dO9keOl418HZFw/DoeJ2giYIxyOux/lUOE8XtVFAgMmp3UxsnO+0KJFjsgk9NqNY
	cPTJEQCmBfzrgQ==
X-ME-Sender: <xms:CuujXP5wvjOORhWbALn8X7kRxEfWYYDP2ZdIP7mbukmjiU4z7tEv9Q>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtddugdduieculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhgggfestdekredtredttden
    ucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrh
    hnvghlrdhorhhgqeenucfkphepuddvgedrudeiledrvdejrddvtdeknecurfgrrhgrmhep
    mhgrihhlfhhrohhmpehtohgsihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghruf
    hiiigvpeeg
X-ME-Proxy: <xmx:CuujXHzN6F5dMaIpB1JZsoxx_82sIwQzv7ObtK8YF4VgPnojH2JzHQ>
    <xmx:CuujXPcYNgzQKVbcRbGk6x9UVlmgb6UZj5n44PaP-_P_gV3_RC8jtA>
    <xmx:CuujXPqZmaCMSNXT1jSveh68Ps6dWSrKzH3VhMFdUFSJ709f_3Mz7A>
    <xmx:CuujXImWCC9G3lu0wRDPeVf5C-OEGImC_TuAiCoi8e2DPySbzT1USA>
Received: from eros.localdomain (124-169-27-208.dyn.iinet.net.au [124.169.27.208])
	by mail.messagingengine.com (Postfix) with ESMTPA id B549E100E5;
	Tue,  2 Apr 2019 19:06:46 -0400 (EDT)
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
Subject: [PATCH v5 6/7] slab: Use slab_list instead of lru
Date: Wed,  3 Apr 2019 10:05:44 +1100
Message-Id: <20190402230545.2929-7-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190402230545.2929-1-tobin@kernel.org>
References: <20190402230545.2929-1-tobin@kernel.org>
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
index 329bfe67f2ca..09e2a0131338 100644
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
@@ -2267,8 +2267,8 @@ static int drain_freelist(struct kmem_cache *cache,
 			goto out;
 		}
 
-		page = list_entry(p, struct page, lru);
-		list_del(&page->lru);
+		page = list_entry(p, struct page, slab_list);
+		list_del(&page->slab_list);
 		n->free_slabs--;
 		n->total_slabs--;
 		/*
@@ -2728,13 +2728,13 @@ static void cache_grow_end(struct kmem_cache *cachep, struct page *page)
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
@@ -2843,9 +2843,9 @@ static inline void fixup_slab_list(struct kmem_cache *cachep,
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
@@ -2859,7 +2859,7 @@ static inline void fixup_slab_list(struct kmem_cache *cachep,
 			page->freelist = NULL;
 		}
 	} else
-		list_add(&page->lru, &n->slabs_partial);
+		list_add(&page->slab_list, &n->slabs_partial);
 }
 
 /* Try to find non-pfmemalloc slab if needed */
@@ -2882,20 +2882,20 @@ static noinline struct page *get_valid_first_slab(struct kmem_cache_node *n,
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
@@ -2910,11 +2910,12 @@ static struct page *get_first_slab(struct kmem_cache_node *n, bool pfmemalloc)
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
@@ -3415,29 +3416,29 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
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
@@ -3475,7 +3476,7 @@ static void cache_flusharray(struct kmem_cache *cachep, struct array_cache *ac)
 		int i = 0;
 		struct page *page;
 
-		list_for_each_entry(page, &n->slabs_free, lru) {
+		list_for_each_entry(page, &n->slabs_free, slab_list) {
 			BUG_ON(page->active);
 
 			i++;
@@ -4338,9 +4339,9 @@ static int leaks_show(struct seq_file *m, void *p)
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

