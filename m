Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24F1DC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 00:03:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC1512086A
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 00:03:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="ssQMkIrB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC1512086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76C0D6B0007; Sun, 17 Mar 2019 20:03:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71FCF6B0008; Sun, 17 Mar 2019 20:03:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 572556B000A; Sun, 17 Mar 2019 20:03:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A8B86B0007
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 20:03:34 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id y6so13445516qke.1
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 17:03:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AeBIbLH/k+PlVuOhUlPjQBBvHXf9fNsgIcyOzJV+yJ0=;
        b=nOh1tsgp5VK4/ETA2MnTogP5Pey4PsSpWHtqYpu8zmH+41nKQFtd2+vVYZ9tixkd1E
         NDsarmLAiwKffKi6TKjJw8wUlfj6iqrnf9RASWCOBJ4ilIsuNkV3xus9VSnG417zU4MA
         TBlyH7+LSoLdYnn6G5VXetqs4mZZPNM6Xqfc6ZkDrCKmeoXjohSaZyOCR67SD4PbsW76
         +l+oD4GBgiKQCmbRXJ1+eoeLrTtf/Gzd0jfW+BCVKTbfC5A47yvtXR48FXHgMyRCp+/k
         U5G6ha1zSOu45iVqlXhTNUWnA0YkIqH3koUn/Cw/ZpLqgxhhCN19jy58wjjaSbby+Eqt
         PdiQ==
X-Gm-Message-State: APjAAAUDQRTZbmrAHe1t6UrzuXJhK5KcxBAka+EARik+daBf2q4cHAWI
	5uhHKhGqNfuB2XB9JUYXrWqbkEQqImsriIsVHaxuDojcY9/OgleKJKgR6SH7RYzdxDNmAwcsjUI
	MWbiQhJ/PKz9eugQ3jf1WtnVRS0prxOmyxNnMX4+whmyXkO6JFNK0j5LA58P6yjs=
X-Received: by 2002:a37:a650:: with SMTP id p77mr11158032qke.256.1552867413917;
        Sun, 17 Mar 2019 17:03:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyytxd1cVgQjQFXYdK8rVAQkzicV78MiWB8vRhP1v3dS3VEbIMXWy8CmjilmjuOZeU+BqDs
X-Received: by 2002:a37:a650:: with SMTP id p77mr11157988qke.256.1552867412746;
        Sun, 17 Mar 2019 17:03:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552867412; cv=none;
        d=google.com; s=arc-20160816;
        b=oHt0LQG0mA5i2KyFTGLp9jwwo+kqtM8FrH+cVqWXdTmJeg07qHBsEtRL955+RWDsLu
         3Ipw6rtRHQf9+ipY7Xf/C1u6DcwLHFFsuxNfJeSAqznHoA8rOVh9nZx/gjfwbc9SzFtn
         J1ibj2M2TA/w7DL2NDnRNjwIQpiNgJgMUOvH+cvtV9RktDMduBR9opvAgzCH4V6pgAf2
         E8MShL30rESnvxmZmb3tLz55yLT+LqG8UAI/CVsHJub0uU9vn7bedYs/2/k8R0z4057W
         nP1NcKPHyeESuB0wI14N36qQwx+K63YIhN684/m8Ift89vd6UAe7UKyGLk3+S03VcuRw
         uiSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=AeBIbLH/k+PlVuOhUlPjQBBvHXf9fNsgIcyOzJV+yJ0=;
        b=rjRUW4rvLZr3pHpiC+ZSjIOv3WMAkbNwXBEoa0Ypk6/bd4dvnZCnc3p5DwZ5CXlQJr
         EhcGX1sY/7soLb8G+NLCx8LezkiuJixyXyJ1PTHioA1bQUkK4i22oar1pGA8VunJspVU
         dKcEvBbZfPXOS+a5pSh1iI3guixeqiLeuvuMhiMIfg/RzN04lMZbN/Z4Mq1yjPMzYE9o
         K94HSfdft8ZGscVZQm9BpOJewH1WIhz5EvLFQQUvQF8+9Sp8k7yJB98mbtF1WlsMb4w2
         gD8KhG7w1/DtSGNdb5Ig6dVJ4Gk7Ej4eoVTMqqWbthta54k7IcD1FnUcX6NiYZgbW5nE
         Wr2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=ssQMkIrB;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id c36si659431qtd.352.2019.03.17.17.03.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Mar 2019 17:03:32 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=ssQMkIrB;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 62E7C2144B;
	Sun, 17 Mar 2019 20:03:32 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Sun, 17 Mar 2019 20:03:32 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=AeBIbLH/k+PlVuOhUlPjQBBvHXf9fNsgIcyOzJV+yJ0=; b=ssQMkIrB
	shXlcEPj1zP9UfU1fj0Oei9LBB0KeFE5A3iLgetR/WeVzb7Ui21UYJCUEt/zlmyG
	WD+edggAXX3g68bBpYjxNFFBekbcOljvZy1iIUd+Z8skU7tkqfeyUjng+GXNk4lT
	jskjvl50U/HHP/3WcEZjXUJIgDuMc/ua5bdMAWtuZ1uXKq5IqRyk6nde71StXtfy
	ghb3gact3LCB5wqjHC6BA9oniV0WxEGb9q9Qkk5iTk4k9kg1S3xJ6gJmguAlMSNd
	+4Q4XgEIglaNd+Iz3fS5hwxHkd7WUsO5lMJ46EbLXWSCrG29lXXLgj02j7S4mC2Z
	sjB1xFsQInYrrQ==
X-ME-Sender: <xms:VOCOXMjEUvcWtF3vhL9ifJ-oA0F1g7UfdjtvzyvTZ17FejjX8-xzQw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddriedtgddukecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddukedrvdduuddrudelledruddvieenucfrrghrrghmpehmrghilhhfrhhomhepthho
    sghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:VOCOXDeVWU8CcT_tj0UgmqIaOpC0lgDjt-FDTgU8jNO-ppGmm15FAA>
    <xmx:VOCOXBdmYsOiwoVCNkb44hq4nzJT6wiIyXEvYsf06RrAG_I-UdcaEQ>
    <xmx:VOCOXAencl0O4s9kniNtEfSEvREO4dc4B5-2y_zo5p5IjfvKm0RCAQ>
    <xmx:VOCOXHewi5PHD6yNt_vpEQgOFkf6jjvA6HnV341c-Vm5mLl8kAdIRA>
Received: from eros.localdomain (ppp118-211-199-126.bras1.syd2.internode.on.net [118.211.199.126])
	by mail.messagingengine.com (Postfix) with ESMTPA id E5B9CE4581;
	Sun, 17 Mar 2019 20:03:28 -0400 (EDT)
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
Subject: [PATCH v4 2/7] slob: Respect list_head abstraction layer
Date: Mon, 18 Mar 2019 11:02:29 +1100
Message-Id: <20190318000234.22049-3-tobin@kernel.org>
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

