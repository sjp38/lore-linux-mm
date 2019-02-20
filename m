Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF98BC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 12:45:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE9BC2183F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 12:45:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="X6HuAhFz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE9BC2183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E6998E0010; Wed, 20 Feb 2019 07:45:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 971078E0002; Wed, 20 Feb 2019 07:45:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77BAC8E0010; Wed, 20 Feb 2019 07:45:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0908E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 07:45:39 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id j44so10388398wre.22
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 04:45:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fQB33hyusb/Aumyn6Q8kWmHk/TEqVmhId57aQJXdZ/s=;
        b=K7pUWCDnEYfgJIKmQZy316U1la515FQtDThFLIjyV88Ffxhmp/5g/xmN9WzspZj5O4
         fo2A0pjSx/2U9BSPdxcZJve8A/ya2BESIyfnJB2BbkcCGPRnYAUWSFNRpVV2UWoNor1y
         TJ+APaJdeFLcK7sML3/SeQTQFcitqXzmapGtnUs5yK/sf7A2r0oc4CYH7v1LV1VAqGMO
         W7Riq2MDSjGE+0PzP1tnzr7IydpYogOIrBJ7M1Ye57wCjHhOm5PqbLpJgg7ugR3FXZQk
         LScRGilABLWy9RMibQVlELE2gxZzA8YGN8g/TIMTzQtnKKjxqAmi6vlNx3kbUIZuQfwf
         edqQ==
X-Gm-Message-State: AHQUAuaSEDlqybQQWkUsCDN88U60aq90SMhYRWJtM7wsHZYnToQ2c0YK
	4mn1tr60RrzrYnRXiLUYsJ0ky4jK9K5ZjgFBTZ7UDl2VhvDh4eLzAfda1cmbufHNRuqp8qntAVZ
	X1D694/8RMrIDaFOjt8zYAUcdMvmAdCuo2Rt//64ASEtHFmc6mWqqpPR+fDmw+QL/n7y7ySxKeD
	VtJREH4uza0G7vWARKhXdJQ61DL4tYdjzF+KyY05DFhDGPHaPtGD4BxjUUf7SFoZL2y7iG8nOhP
	OQ1BS869wCUxl2LjX4/v8uve6GQRUvkbYBlPcaPs9+SC4+EVW5+y2Y/5eTa7Q0lDVOW/IQ8cO8S
	9OmVJ5qIRRwnTf0/MdAk/LvvZ9E7VMLNUTM5hoKjRQ+DPkS6WMMxROOur48QaCTC9Vs3STzUcIE
	o
X-Received: by 2002:a1c:7906:: with SMTP id l6mr6329195wme.83.1550666738623;
        Wed, 20 Feb 2019 04:45:38 -0800 (PST)
X-Received: by 2002:a1c:7906:: with SMTP id l6mr6329155wme.83.1550666737708;
        Wed, 20 Feb 2019 04:45:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550666737; cv=none;
        d=google.com; s=arc-20160816;
        b=LTTYel4yCsqfSjhuvQn+cc/bFy/DUlyDy5EEerjKy2i84Jx2W+KXSnU0yaqmdFWS1y
         8VmWW36Hx0FYxWc8U7DfQ3/OtFfi0S/mgzo2rmgdEKnPC1nQosGBmS6+fk1krRt/nzZW
         vggcKpVTRJIjRmgkBNMreXyvgT8kTDnygzy+IyDwKCjm1AyI18DXmw6faDNeS15QXxam
         sA8BW874N0Fik53F9YRDAMXN8RnnHTmx6QuMxjbERV3e+6lyZc3n4w3tNazi+sUXas/J
         346Vj1GlN3ykLEDI/b00Bpp/xlOBo8Gr+5hCCAFcx0wzgmcfbmEn8Xrq8ZObXr7p95HL
         A2mQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=fQB33hyusb/Aumyn6Q8kWmHk/TEqVmhId57aQJXdZ/s=;
        b=UYdDF+mqJBopXb8vLkMKmxUF29lK1QFizeC/ua+mO7qDeelX/bi6Blv6x0iBjTinKA
         YfwNdxqrqsfgCrwCm6Ygx87XfTJOfO192MPDg2gVUSxK7np05yRiQ9TLtyEETLugoJqj
         OX9drnJPYNBVJyS+AT8ufL/h37HyxZ4mQ64srF8WM/yn1UDRUu5boALWG5mTLqWOlvVQ
         3Vp1SxBtVqps9yuuw7KHUtV3m+METIwsao3IIRULGJFiE6oPVIP0B3iamc+hlsOc8g+D
         lZIEXgNEZQaLqpTaHFEJ0LyIgDKGz9z/308HubdJ8GkfawamG9wXskWIN4zOTIDpXTsz
         tkfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=X6HuAhFz;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n15sor3588638wmc.23.2019.02.20.04.45.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 04:45:37 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=X6HuAhFz;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=fQB33hyusb/Aumyn6Q8kWmHk/TEqVmhId57aQJXdZ/s=;
        b=X6HuAhFzVyDsIJPV/pL41HvGaDjlO0vTjXr2OZYAtADiu/Lz72YRfW1+XD9Kdt1DGo
         ghaPVtBevuMsjzRo5NRUgcGyU1fFMsSNZ/LRvovoxzUvGIVFHnqrcxEMrJ6T5B5iZY2S
         hGCTxP/7qnF8GV1WG/B+RacmVNJAHrbTmi3UPnWjdWHBHjUZ6cNdUqkGBBhFTJW+I22Q
         wnNLhzebb6NpoY+sHoNkDH45qrl5ETQMktoHEyMw9VhTZCXBjQONgHOi9gp8rEUMp9w7
         4CzMQhjHcfURWYGvo2aRaj1na8HB27pSa4QKQO39LnpskYbUWfDhfVukRRSU3jECiRUP
         qDPA==
X-Google-Smtp-Source: AHgI3IabI55h01GTJOovj1LFUoTaAv7IadDL/Z17sRBOfQGy3+UYf/86H6vdZ96ggIYEFKXQhNkZ0g==
X-Received: by 2002:a1c:5581:: with SMTP id j123mr6011804wmb.10.1550666737166;
        Wed, 20 Feb 2019 04:45:37 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id f196sm6378889wme.36.2019.02.20.04.45.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 04:45:35 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 3/4] kasan, slab: make freelist stored without tags
Date: Wed, 20 Feb 2019 13:45:28 +0100
Message-Id: <dfb53b44a4d00de3879a05a9f04c1f55e584f7a1.1550602886.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.rc0.258.g878e2cd30e-goog
In-Reply-To: <9c4c3ce5ccfb894c7fe66d91de7c1da2787b4da4.1550602886.git.andreyknvl@google.com>
References: <9c4c3ce5ccfb894c7fe66d91de7c1da2787b4da4.1550602886.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Similarly to 680c37ae ("kasan, slub: move kasan_poison_slab hook before
page_address"), move kasan_poison_slab() before alloc_slabmgmt(), which
calls page_address(), to make page_address() return value to be
non-tagged. This, combined with calling kasan_reset_tag() for off-slab
slab management object, leads to freelist being stored non-tagged.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/slab.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index c84458281a88..4ad95fcb1686 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2359,7 +2359,7 @@ static void *alloc_slabmgmt(struct kmem_cache *cachep,
 	void *freelist;
 	void *addr = page_address(page);
 
-	page->s_mem = kasan_reset_tag(addr) + colour_off;
+	page->s_mem = addr + colour_off;
 	page->active = 0;
 
 	if (OBJFREELIST_SLAB(cachep))
@@ -2368,6 +2368,7 @@ static void *alloc_slabmgmt(struct kmem_cache *cachep,
 		/* Slab management obj is off-slab. */
 		freelist = kmem_cache_alloc_node(cachep->freelist_cache,
 					      local_flags, nodeid);
+		freelist = kasan_reset_tag(freelist);
 		if (!freelist)
 			return NULL;
 	} else {
@@ -2681,6 +2682,13 @@ static struct page *cache_grow_begin(struct kmem_cache *cachep,
 
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
@@ -2689,7 +2697,6 @@ static struct page *cache_grow_begin(struct kmem_cache *cachep,
 
 	slab_map_pages(cachep, page, freelist);
 
-	kasan_poison_slab(page);
 	cache_init_objs(cachep, page);
 
 	if (gfpflags_allow_blocking(local_flags))
-- 
2.21.0.rc0.258.g878e2cd30e-goog

