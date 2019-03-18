Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87746C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 00:03:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AA8920896
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 00:03:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="pCd6G5/s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AA8920896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9E636B0008; Sun, 17 Mar 2019 20:03:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4CD96B000A; Sun, 17 Mar 2019 20:03:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B143F6B000C; Sun, 17 Mar 2019 20:03:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 91CDF6B0008
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 20:03:38 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id b1so14801635qtk.11
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 17:03:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NJ63LCCLaSV3iAE8Jn20nHVAI3AvEK5t29Xi1XCFI+c=;
        b=WzXEDA6v67CTJvUY5VQkJiMnQHCEVQ1mP7o0Qj1JhW8mkmsYMwNvz1BJd+PSRb+ZbY
         RPPCKcqDdgnPIeRgL38WqcST9ceOWm4HWb/2PlfGi4ZASe0V8HtDYGoD2Q/sxY5Lpyv5
         5CwwGUNqKxFwp0YKGhidZJh7EzjnUiknUtgjKyJ7Cy5D5m5DbLNKrYg+ypJuGS5W6++Z
         iVZC4X5g6PG21MD9+fREV2v5uhIqw/EDPJ1b8x6FO7DiD80aFeUe64uc1j/6NGmii+Bt
         +xoIWz3v/fhmEjX+NaUUyUbn9W3bA+RFs5YynxyLSE+lNpbzPBNTxhUeRWAZKA/Kecot
         ugaA==
X-Gm-Message-State: APjAAAUWwqCXv4ZqAAUXgrGpuVYMAb0ADyRwm5W9bkMYgCic/RwBGu8U
	TYrKqIIWBZMnc7SsnvTUV9bkNEQ06JKnSQZ4AQL5OE4JmaX60lGZUhHCal4YfBowOO7solt44fQ
	HUT2UU19Wk3K2QHFDrrmWNjNQ1ABWv9j6EbisgYvb6KbckGtSgaUjfX0DhRVv4Zw=
X-Received: by 2002:a0c:9599:: with SMTP id s25mr3417455qvs.119.1552867418273;
        Sun, 17 Mar 2019 17:03:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxuCk5jjXt6e44q1guBFndnjupGXeIZvoarDgiVnoWBnevqEgz09EcB8a+Y9Imv4+1if1Ha
X-Received: by 2002:a0c:9599:: with SMTP id s25mr3417386qvs.119.1552867416810;
        Sun, 17 Mar 2019 17:03:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552867416; cv=none;
        d=google.com; s=arc-20160816;
        b=C8cFQaSsjLMhCQGF3/HnATrv1wjbzHtL6G/x0z4VDv4dVOHtY3X5kB6GOELCbDygks
         IB287EOP5tECJh6vlb8B5hI0MNo6Sox3cUcPSuZoGDtBCXdvUTvotbeCLLZ0ybQEW3iN
         nDf37VR9YiPh9Sz9JzUIS0gouWDI5i73qZ1Jenu1crC3F4xtkQ4rtUtDFrF0DH4zMolC
         zX3kpB2BgMFHHyati7r9AJXEkB120lNDPexjsSW5TCuGfpJIAYXdjkNXm38G6i+CmyQS
         hF5dlzURrQzGlqKu6w7klcqQ+b4WC9dyTgDydaFV+Mnfd3WtPc3VjQkWo6ZfkbupKME+
         Oyjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=NJ63LCCLaSV3iAE8Jn20nHVAI3AvEK5t29Xi1XCFI+c=;
        b=DTIdo3cJpMClxxGhHusA9BwxuEtLv1WlzANVemVFJ31zDPrM8Ujs+0YpH69wP0Yf99
         q3D4KcGMxlxXKG9ESg00Ru/dpy1K7BlDHLSakL9FFtJxF9kyDA60XjSkF0o4PaebvahH
         SaYNy/Mrj5kolSof5Ech8TEqY5ObAXMrJWWrd+WrDAqFW06mvhq9eb+z4bZfg1oVBxTR
         +xR1rtbRCrFmIpEoC1j4qk399NwhCDypFsWCI7V8/MGc9wRU7ZgtsUh/wRD4a0s8SDgZ
         T0PoANcB1whJ1J45HgY1BCN6pmKpTBXzutcNLHnExfKXxYtLwuNMhCS90pOR/fEh9bfZ
         OOjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="pCd6G5/s";
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id u69si5208197qku.123.2019.03.17.17.03.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Mar 2019 17:03:36 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="pCd6G5/s";
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 85C5621B74;
	Sun, 17 Mar 2019 20:03:36 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Sun, 17 Mar 2019 20:03:36 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=NJ63LCCLaSV3iAE8Jn20nHVAI3AvEK5t29Xi1XCFI+c=; b=pCd6G5/s
	IXk6xU7bwSgPoncwBnY1rz9JSIIm3jsaPiDopQmEidYawkMK7P22Yrh69Lic82j/
	u29QWAJD0OVZ8ushlWC8j0Thl3bkX5t5WMeaBnvCjqgMG+E5CyUJceEHcgUch/vc
	tGUIA62xBGG942nyd9+f6PSF8ZrshTW04TVDPINKTivdbCeH671z63whT70e3tZQ
	OFKz+eOKCFkdaMKaOaT8BgDbV8il3f5757Pc/kv+n9BUVWTWnS6qYJJ2lMn6XMaG
	A5FK8BG9a9aIruxIjUYNEreotCLHsdRrgUlBLVcPCUitvd1X+ocgIvRp8y9YQ50a
	JmqbHTnrplbvdA==
X-ME-Sender: <xms:WOCOXMDtgJbU231kGnLLfSMfV_j8Q5-T-QUUB4bCpnrUGwu7mX72WQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddriedtgddukecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddukedrvdduuddrudelledruddvieenucfrrghrrghmpehmrghilhhfrhhomhepthho
    sghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepvd
X-ME-Proxy: <xmx:WOCOXMBqT8dBlqKlhHyriGce3wK1ySenV7K6rneGo-N_Kd7dfQy11Q>
    <xmx:WOCOXLoJLiphiWyhQiLY9z2kkBe8WKT3I_35ssKpZVLzAMhe3i5q3g>
    <xmx:WOCOXAAoQDST5s-Y_aZqCJsLricpgxVe9iJCNY4XFyihTbg1jA3ViA>
    <xmx:WOCOXOnGfetuCDmAaKYYNiOOqQLRmKHCqYWLINtwxcxxDSCpkOAlrw>
Received: from eros.localdomain (ppp118-211-199-126.bras1.syd2.internode.on.net [118.211.199.126])
	by mail.messagingengine.com (Postfix) with ESMTPA id 1A615E427B;
	Sun, 17 Mar 2019 20:03:32 -0400 (EDT)
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
Subject: [PATCH v4 3/7] slob: Use slab_list instead of lru
Date: Mon, 18 Mar 2019 11:02:30 +1100
Message-Id: <20190318000234.22049-4-tobin@kernel.org>
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
slob.c before and after this patch is applied.

Steps taken to verify:

 1. checkout current tip of Linus' tree

    commit a667cb7a94d4 ("Merge branch 'akpm' (patches from Andrew)")

 2. configure and build (select SLOB allocator)

    CONFIG_SLOB=y
    CONFIG_SLAB_MERGE_DEFAULT=y

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
 mm/slob.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 39ad9217ffea..21af3fdb457a 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -112,13 +112,13 @@ static inline int slob_page_free(struct page *sp)
 
 static void set_slob_page_free(struct page *sp, struct list_head *list)
 {
-	list_add(&sp->lru, list);
+	list_add(&sp->slab_list, list);
 	__SetPageSlobFree(sp);
 }
 
 static inline void clear_slob_page_free(struct page *sp)
 {
-	list_del(&sp->lru);
+	list_del(&sp->slab_list);
 	__ClearPageSlobFree(sp);
 }
 
@@ -282,7 +282,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 
 	spin_lock_irqsave(&slob_lock, flags);
 	/* Iterate through each partially free page, try to find room */
-	list_for_each_entry(sp, slob_list, lru) {
+	list_for_each_entry(sp, slob_list, slab_list) {
 #ifdef CONFIG_NUMA
 		/*
 		 * If there's a node specification, search for a partial
@@ -299,22 +299,22 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 		 * Cache previous entry because slob_page_alloc() may
 		 * remove sp from slob_list.
 		 */
-		prev = list_prev_entry(sp, lru);
+		prev = list_prev_entry(sp, slab_list);
 
 		/* Attempt to alloc */
 		b = slob_page_alloc(sp, size, align);
 		if (!b)
 			continue;
 
-		next = list_next_entry(prev, lru); /* This may or may not be sp */
+		next = list_next_entry(prev, slab_list); /* This may or may not be sp */
 
 		/*
 		 * Improve fragment distribution and reduce our average
 		 * search time by starting our next search here. (see
 		 * Knuth vol 1, sec 2.5, pg 449)
 		 */
-		if (!list_is_first(&next->lru, slob_list))
-			list_rotate_to_front(&next->lru, slob_list);
+		if (!list_is_first(&next->slab_list, slob_list))
+			list_rotate_to_front(&next->slab_list, slob_list);
 
 		break;
 	}
@@ -331,7 +331,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 		spin_lock_irqsave(&slob_lock, flags);
 		sp->units = SLOB_UNITS(PAGE_SIZE);
 		sp->freelist = b;
-		INIT_LIST_HEAD(&sp->lru);
+		INIT_LIST_HEAD(&sp->slab_list);
 		set_slob(b, SLOB_UNITS(PAGE_SIZE), b + SLOB_UNITS(PAGE_SIZE));
 		set_slob_page_free(sp, slob_list);
 		b = slob_page_alloc(sp, size, align);
-- 
2.21.0

