Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78C2AC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 05:32:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AEE12087C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 05:32:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="TSUpdgdJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AEE12087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 595688E0005; Thu, 14 Mar 2019 01:32:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 520368E0001; Thu, 14 Mar 2019 01:32:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39B4E8E0005; Thu, 14 Mar 2019 01:32:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0C8318E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 01:32:14 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id q12so1267908qtr.3
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 22:32:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sj6M4OpXGBRvDdAJeVq0+fK1eLMRQBJtoq/YI75189Q=;
        b=r1OWAg3zRqgvk+yry6cT0b//1LcPLrhugNtTQOsGvhdk62l6dY91YKfpRNUUJGwsS8
         yRIzvRHcFlZ0niwXi6TF7UPohgrZWrow8hYpmIFDYx6E5qUpnG4uI0UtsPbQFRZu6S5P
         KU1FaMwdRu3GrBH5g0uTWQc3MQRebJyoey8YsUyoyp4ZwNjBh5MdEMUnskr2Mc7IHDUb
         0KHydEZKj8DJxG8HL1+aR5LohxWBH5OhnKt9/9z1XI7qNH8O1oYkuXPyF4Ja6SU/i5g1
         SywYhEQpDjm3OkKxBvcKlTsIFdVWVpMqCyrj6eqsprxQrr/kCCigksMh4lOkSwoCuKbL
         ZTcQ==
X-Gm-Message-State: APjAAAXM0/GNe6GkX5O2szvrL6pud77lSLYtyShN4pc+zNyctIUz3Es3
	hewjMZB9cAWC72URFWMTxLLB1za5W04g5CtnnT7ur6GqhxwJ6o3Hn6RONQDdNr8i7FK5Fzt8mqt
	OibBSwOL0fiaOFja2cx4dKKr/ctzkXEnXH22ZK1NmlSVTRBW311snH4ZGoDlXZ68=
X-Received: by 2002:ac8:1be6:: with SMTP id m35mr14490248qtk.258.1552541533843;
        Wed, 13 Mar 2019 22:32:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4SDK+kFUiHgSfrtyLeZ3nquANOksA1u6iqlSQ5yi+DOpfFVqhqoCnUrXcX3iorP7Ieya3
X-Received: by 2002:ac8:1be6:: with SMTP id m35mr14490219qtk.258.1552541533120;
        Wed, 13 Mar 2019 22:32:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552541533; cv=none;
        d=google.com; s=arc-20160816;
        b=y2wOfEXTUn9wXvL16RgI6JjFY/3G4s4ZFD3JMVUC4WAI5hoF9vJ0nW8nSNl5J4Tyyt
         OZ3MIUmziiHSiR2SX06/jyupxNgMV1TmYbmNqG/TTVFDG5hUq5fyMWSyP5l/tiFJxzzE
         dxMBoPoum/V4dShwAp4AUpVnAPvj5gOo6uNeCNqxllN3RePjGnbBhHNwNRoW+v6tFRFF
         gHN9+vkg17CH7FFHalYr0ejSDtODRZZ2mqbLFsi1hO17Ub+qV7vMEoHqAB2PPT35MuM7
         nCNlj+bhaoDvi//Pq9szelGInJxaU0sW49YnZL72sq8OM9gABUa07WSHQ5lb5ScruK/w
         vbpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=sj6M4OpXGBRvDdAJeVq0+fK1eLMRQBJtoq/YI75189Q=;
        b=SNqGl4Eh35wbZUe2ZAQalrvKmykjpU3NOsCY0DhKebpihpw0m4QzxvpCEtFIf9+EfU
         +/7VV2QUhzEBa7h9RjwqHYOQIJK3xhneFbCUfkZnV8Ida9nQ89pDH84PDi+pQKgxs9rO
         3+s0MwtCNbnSxGvLdXq1ealupJNNRURmjdRjZdIMh5CCgp8o19F0N+eO9oEwuwQ5x7JV
         U3/SSXCxMR5uls4n3AylkDZZAI3/kcUv+4O9HpHOgACqiutBPXfVDlBWspJH+IB2HEsg
         +KlKI/iNgTIYFA5RXJill6nOJMV3Q8lqC2kNv+s3sC9iPXvA4pqjLj7Xmm1ZIQ7UYwef
         cQww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=TSUpdgdJ;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id d131si473464qka.201.2019.03.13.22.32.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 22:32:13 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=TSUpdgdJ;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id D451E214E0;
	Thu, 14 Mar 2019 01:32:12 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 14 Mar 2019 01:32:12 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=sj6M4OpXGBRvDdAJeVq0+fK1eLMRQBJtoq/YI75189Q=; b=TSUpdgdJ
	U3GaOh+0VR06/UhiUqmiX9hT+6ZjnnXKAd/Js9+MTL0QgE1EHJdHHK2qiVbaKqz+
	9x/aceEGdIi5Zx7jY0XgDwspMLIXFwIfN1fCI7XImr8D9a9K4ZgsSYi77c6i93+6
	Ne30IQLGZ8vdDHvEYK2BFfQdGZwgvVs5UcGp5qQiiRecuE5qAvK/2pzWolFGTbAV
	oA8l06zPSt2HkHj8SJDWOqf0noK8QjPFzw49MmzYcV8mYQbEBBVmWD78jWlTCCk8
	TOwjKGiJ38u6yR/RusWV0dMP7X6q7SW4jHeHuNRv10Dyv9UXLraivrZe7fksUEAL
	RbDhew6o9XGaLw==
X-ME-Sender: <xms:XOeJXHSkCT9nnNDxNco8BxiT6BzRP-lhb1-r-lxomDzQvDcin4HV1Q>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrhedugdekgecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedu
X-ME-Proxy: <xmx:XOeJXNoUnTDEupa0Xn4oeuGFV95svUdh6R07YlAgR4pE1aW58HvcQg>
    <xmx:XOeJXFYF4kt_UN3Fok6W3fTt_vVbqvfsu3Wjc_7wsd5kEWmye2leAw>
    <xmx:XOeJXITYUrsUTLxVpaEDctTFxTTybIQwCZIhaHNtkoaHr3QEFrP5wQ>
    <xmx:XOeJXHERyhLfvf-Iv4c-SniqugI407BgdWEoYM4Su0A9gXRb07Fkgw>
Received: from eros.localdomain (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id 43937E415C;
	Thu, 14 Mar 2019 01:32:08 -0400 (EDT)
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
Subject: [PATCH v3 2/7] slob: Respect list_head abstraction layer
Date: Thu, 14 Mar 2019 16:31:30 +1100
Message-Id: <20190314053135.1541-3-tobin@kernel.org>
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

Currently we reach inside the list_head.  This is a violation of the
layer of abstraction provided by the list_head.  It makes the code
fragile.  More importantly it makes the code wicked hard to understand.

The code logic is based on the page in which an allocation was made, we
want to modify the slob_list we are working on to have this page at the
front.  We already have a function to check if an entry is at the front
of the list.  Recently a function was added to list.h to do the list
rotation. We can use these two functions to reduce line count, reduce
code fragility, and reduce cognitive load required to read the code.

Use list_head functions to interact with lists thereby maintaining the
abstraction provided by the list_head structure.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---

I verified the comment pointing to Knuth, the page number may be out of
date but with this comment I was able to find the text that discusses
this, left the comment as is (after fixing style).

 mm/slob.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 307c2c9feb44..39ad9217ffea 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -268,8 +268,7 @@ static void *slob_page_alloc(struct page *sp, size_t size, int align)
  */
 static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 {
-	struct page *sp;
-	struct list_head *prev;
+	struct page *sp, *prev, *next;
 	struct list_head *slob_list;
 	slob_t *b = NULL;
 	unsigned long flags;
@@ -296,18 +295,27 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 		if (sp->units < SLOB_UNITS(size))
 			continue;
 
+		/*
+		 * Cache previous entry because slob_page_alloc() may
+		 * remove sp from slob_list.
+		 */
+		prev = list_prev_entry(sp, lru);
+
 		/* Attempt to alloc */
-		prev = sp->lru.prev;
 		b = slob_page_alloc(sp, size, align);
 		if (!b)
 			continue;
 
-		/* Improve fragment distribution and reduce our average
+		next = list_next_entry(prev, lru); /* This may or may not be sp */
+
+		/*
+		 * Improve fragment distribution and reduce our average
 		 * search time by starting our next search here. (see
-		 * Knuth vol 1, sec 2.5, pg 449) */
-		if (prev != slob_list->prev &&
-				slob_list->next != prev->next)
-			list_move_tail(slob_list, prev->next);
+		 * Knuth vol 1, sec 2.5, pg 449)
+		 */
+		if (!list_is_first(&next->lru, slob_list))
+			list_rotate_to_front(&next->lru, slob_list);
+
 		break;
 	}
 	spin_unlock_irqrestore(&slob_lock, flags);
-- 
2.21.0

