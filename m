Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07E4AC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:16:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3277217F5
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:16:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ajawxJI8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3277217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 679EA8E0012; Wed, 13 Mar 2019 15:16:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6283E8E0001; Wed, 13 Mar 2019 15:16:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 517868E0012; Wed, 13 Mar 2019 15:16:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2B98E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:16:12 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b15so3214209pfo.12
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:16:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/7wh80ojC3Qku9gbCedwkBZLV2i2JD5n0YkaTrYNDoo=;
        b=WPLYwN3hVewNKo60w/KGCvaKBhsMy2NaZqb0nO332lof4LH98gxCmKRPMI2lnCgaDU
         ylZHrfgewqweTID7SEko1n3Ffy8Aekih4HwOxWHvd0Azvt3U0A0V39x5CkNU1zPedS1J
         8OZ5ssuF1Y8+H4wk454SfWrG7ir/1l6sRGynU9AaFVJSVEIzn97SZhHwgVaMNRPMKXJt
         6nTda2oufdfH+ggRUJw3mExQLVlcmkOHt0eAxHTlbGVVKhWvVzxDbuw6nZ65mE2KPgNg
         BGidAa2puNb+96RVBKiqaKAGllm4InZgv1Pd4Kg5tqEqwO/1Waw6UwrywlcVDjRsLYgj
         w3DA==
X-Gm-Message-State: APjAAAUMeMMshPPYr+eHrn4PXGzVVHGJrWSi6ruT+d3zps5fGwuwGn3A
	nZoLYETa0CK2hrWDg11HTcVB7vAr44wRBm6HZ2gTN7164e4uCaEK8VSLk3hLsAg9RU4hKHZqJ6u
	j39DQkDq/uXx9jI9Fz1Q9jfniBWCOZhhsmmt8qClbW74H66oMqvr3cDiG9rS1ivbIbw==
X-Received: by 2002:a63:2a86:: with SMTP id q128mr14810074pgq.424.1552504571679;
        Wed, 13 Mar 2019 12:16:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxWRVevoUT0Zhe7BMvFT7469R6Sw895Fbpy1hqg35soDA8nSkU8XtERcrzccY6AV9Je7F/Z
X-Received: by 2002:a63:2a86:: with SMTP id q128mr14810015pgq.424.1552504570956;
        Wed, 13 Mar 2019 12:16:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504570; cv=none;
        d=google.com; s=arc-20160816;
        b=YJlkTspAfKLvGNnr01Ve4mHVoA5SLT6yjYH8byWMqcoJigJEQy9ZimIKfVB1GbjX3Z
         Ey2V/4z9Kg2n8Ijw4aRdI8R1QLTYHf88nQzN6OCVXb9I58GKXGTu8uEquejtsroY6/qK
         lefj2qz++3DFa3iElqElXuvVlorfajG7tmV4mHb5hVuUNfRY5Jqyy65sy7NMXIXsqGCn
         FMxSOE5DcUGb0SbAQGyTf0U2K1raDsBASoKb5n8Fyp8z9R+UV/mSqzQr5x4m2V+5jDeO
         q/d8i3wWerbahdy/fI/x2dOR7gHnmrRR5NuwSL2yzP1J+VaNMViD1/JUaNqEwD+qHJ2K
         Mc4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=/7wh80ojC3Qku9gbCedwkBZLV2i2JD5n0YkaTrYNDoo=;
        b=ummrWINBAYN5MXRomMUgsSYGPtU1ZD4fvU1Sa8By9GhJVGEk06jY14tYFg8Xp6KfHa
         AQGrHxA5dQuZePeAC3Nf6m7pTJgzKlgVhISvGPM2alfSg/GN4RoRAht8vJlmweCtWvlK
         vNodQwa4iVULAYrwkfHG64l5pvWG1Cl3OMdBcNoY36H2zc6wwq0ljRKAKJeJGP2csnu6
         /MUN5NfQ+3MGiY+iwDJ/tEUukvIUUxVMYDE6XTvY2BooWgBq6Sm9TPi2HlRn4cx6706m
         /uqU1LlQ4rV9XTw5Kg1GtWvini3J/+gCMNOhXPJFcXAbRCrPqFEoEFnhxPPVXVkRNWLM
         vorQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ajawxJI8;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g19si10599189pgk.300.2019.03.13.12.16.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:16:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ajawxJI8;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DEED8213A2;
	Wed, 13 Mar 2019 19:16:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552504570;
	bh=UepDjovFIr+6yJpnkmsAsF7ulrlMGkOgEZ/Ew1Fua4s=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=ajawxJI8UWRYYjuCdHl//7MCBOxUL/qp7hIjSOsL9zSkNiYVuTW0vZKqFPU3flDMb
	 D0sZ1ItyKLtUElEsTkdSjOawYxQa3HCY3NyqI+gICJDCGA+2SEJnyPns98aUZeOGsR
	 rkXLDdGURGQymqBqOqdxdc3xjzukOxBBKnXNQ/+8=
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
Subject: [PATCH AUTOSEL 4.14 22/33] kasan, slab: make freelist stored without tags
Date: Wed, 13 Mar 2019 15:14:55 -0400
Message-Id: <20190313191506.159677-22-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190313191506.159677-1-sashal@kernel.org>
References: <20190313191506.159677-1-sashal@kernel.org>
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
index 409631e49295..766043dd3f8e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2378,6 +2378,7 @@ static void *alloc_slabmgmt(struct kmem_cache *cachep,
 		/* Slab management obj is off-slab. */
 		freelist = kmem_cache_alloc_node(cachep->freelist_cache,
 					      local_flags, nodeid);
+		freelist = kasan_reset_tag(freelist);
 		if (!freelist)
 			return NULL;
 	} else {
@@ -2690,6 +2691,13 @@ static struct page *cache_grow_begin(struct kmem_cache *cachep,
 
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
@@ -2698,7 +2706,6 @@ static struct page *cache_grow_begin(struct kmem_cache *cachep,
 
 	slab_map_pages(cachep, page, freelist);
 
-	kasan_poison_slab(page);
 	cache_init_objs(cachep, page);
 
 	if (gfpflags_allow_blocking(local_flags))
-- 
2.19.1

