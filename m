Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AD03C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:11:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3C302184E
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:11:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="dnGvUOBy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3C302184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9638C8E000D; Wed, 13 Mar 2019 15:11:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EB8B8E0001; Wed, 13 Mar 2019 15:11:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78E4E8E000D; Wed, 13 Mar 2019 15:11:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2EF4D8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:11:51 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id p9so3209308pfn.9
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:11:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IiJQCRYaGRhFgOIweSzPyVuWURp6thxugB4m+P+RWZ4=;
        b=VilmGwqDpUQlQWishgb3IlLqX5JNRB1/lV1IpU0Wqq+k7h3CdinaxpaT/lo9TEWLE9
         d9022CGkRVsplPgWk/dQTAL2Lfa0xDAZ1DmXgNw9yl3tKHsyR9L4j9SnK8UmWfvHNA3z
         Detc+NL7KPIolbK63GaRiT6rp1RIwjW7WWKAbXH9SLktaSg/2aCP7e36TC8jjAluzP/O
         xrZu/eIrHtfRCpDGm+kmCR81a5KWfsL61MbbiViONwFEE/mLNg3rRtWOjOz63UXyhAMc
         /YFr3RvlBRYXVDtbuc8I9x/bcuGw6NsC26RqNkC2YFQh2u1uEd0I+ey9AVa/8l3Xx7hD
         OE8A==
X-Gm-Message-State: APjAAAUaQ/piTJuku8AbKTRSG1LSmfUckVGJfvnU9TIM+sn3Wh/Qk1nH
	L7Zzxkv3w0cn7u1kjwGfCBP3aEXjgEmBTnmWJxSoARN2BGn7ZfES0EA1TpKJ7YEy1HzjwWNm8el
	NHVMOesU/uabHPj2JuAWPgXRwpp1giOeZWsrqysadzU9ppDrw64hnnTgEzQAKmXqdMA==
X-Received: by 2002:a62:4299:: with SMTP id h25mr45225931pfd.165.1552504310816;
        Wed, 13 Mar 2019 12:11:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUMV4PvX/h0DW+X7YMkFn8q25a1kjWLyq2/8/45C92Lx+Bwct/uPR8zhjRope43EW9KzyK
X-Received: by 2002:a62:4299:: with SMTP id h25mr45225878pfd.165.1552504310136;
        Wed, 13 Mar 2019 12:11:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504310; cv=none;
        d=google.com; s=arc-20160816;
        b=O+6AlNqTvDwNBnspJLKSsKFVDDHx+pH2f9ezqL9OSPzBzRHrUOHRJUJwtLfqiazi2Z
         GBFwsAXqBWGJtNg6DaLeXkivfwYmnseZHMCIX62LCkGpaj+x/a1XlOvRSWQrSBRCw3uX
         070ZSg0NmcbtOsQqkqldfCqmZ3X84qM7JSYusXIr6sogX5b12oFLHV0uYMq3h0hpoO9J
         1nrn9Uig2tluKeunWKixDNv597hroVGdJfgZjrKhppydnPIiuCpYAcd5Vp9ILTZ5Oc7f
         k6I9W5M5ozGsPMqAqHmw0yJBK9BtgtnyJCEWcid06qT/IHiOckmmjZ3SgqGOLoGtb07Q
         JA+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=IiJQCRYaGRhFgOIweSzPyVuWURp6thxugB4m+P+RWZ4=;
        b=GQjRuRZ9z1Ff1sVlMxpmeKZBKLq6HF3koNPrUkD668kvnMXKi1JaME3MHjFNaz1DyE
         Uowl9PahQ0JU3/T6nTVesK0O9AWTUDMUYqWeWfxM5cw4JQkxe5WDNhkCgAAqROLLtZAA
         GErQ+N9Zdb0V6NH/Eu8Ze8KXgO1WpR9NYwTDSfFkRv/mcisktaudNm5/bKucEEKBDzKe
         4FfrTnvQ+IAp3vyYEfml8qx0G36ya+L5JroP4n9kgq11efj2OdfTjbxwKyLttJWiXuBO
         tKaT2H8w3mTfXs+MkwTazYglSPjbuHCyPVMWQfw5gCh5442vIQPzclLT37FetLWXtjUv
         9iVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=dnGvUOBy;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a20si10569919pgw.64.2019.03.13.12.11.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:11:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=dnGvUOBy;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4EA13213A2;
	Wed, 13 Mar 2019 19:11:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552504309;
	bh=3GT+9B2z4QYam/gzFSmgOQrgzOiFBtJq+nV5XdgLzmA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=dnGvUOByVOhcs8WnogHwEIO8jEfui3jB1HBcbLEZoEKJYPXtDT9VBQ5HSiZAQbcN5
	 GNcQChQRz3kVoyGObhcRuPo9zc5iHsF5KvxXZg57eJ9d8HNgSDD84gkTbNk75qsVJF
	 +C4lo+hdL2vr8Y0uoT91T2BmARBsWtXeShc8u3LY=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.20 39/60] kasan, slab: make freelist stored without tags
Date: Wed, 13 Mar 2019 15:10:00 -0400
Message-Id: <20190313191021.158171-39-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190313191021.158171-1-sashal@kernel.org>
References: <20190313191021.158171-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrey Konovalov <andreyknvl@google.com>

[ Upstream commit 51dedad06b5f6c3eea7ec1069631b1ef7796912a ]

Similarly to "kasan, slub: move kasan_poison_slab hook before
page_address", move kasan_poison_slab() before alloc_slabmgmt(), which
calls page_address(), to make page_address() return value to be
non-tagged.  This, combined with calling kasan_reset_tag() for off-slab
slab management object, leads to freelist being stored non-tagged.

Link: http://lkml.kernel.org/r/dfb53b44a4d00de3879a05a9f04c1f55e584f7a1.1550602886.git.andreyknvl@google.com
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Qian Cai <cai@lca.pw>
Cc: Alexander Potapenko <glider@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Evgeniy Stepanov <eugenis@google.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slab.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 05f21f736be8..b85524f2ab35 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2381,6 +2381,7 @@ static void *alloc_slabmgmt(struct kmem_cache *cachep,
 		/* Slab management obj is off-slab. */
 		freelist = kmem_cache_alloc_node(cachep->freelist_cache,
 					      local_flags, nodeid);
+		freelist = kasan_reset_tag(freelist);
 		if (!freelist)
 			return NULL;
 	} else {
@@ -2694,6 +2695,13 @@ static struct page *cache_grow_begin(struct kmem_cache *cachep,
 
 	offset *= cachep->colour_off;
 
+	/*
+	 * Call kasan_poison_slab() before calling alloc_slabmgmt(), so
+	 * page_address() in the latter returns a non-tagged pointer,
+	 * as it should be for slab pages.
+	 */
+	kasan_poison_slab(page);
+
 	/* Get slab management. */
 	freelist = alloc_slabmgmt(cachep, page, offset,
 			local_flags & ~GFP_CONSTRAINT_MASK, page_node);
@@ -2702,7 +2710,6 @@ static struct page *cache_grow_begin(struct kmem_cache *cachep,
 
 	slab_map_pages(cachep, page, freelist);
 
-	kasan_poison_slab(page);
 	cache_init_objs(cachep, page);
 
 	if (gfpflags_allow_blocking(local_flags))
-- 
2.19.1

