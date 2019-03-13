Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDD7EC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:17:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 747AE2184D
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:17:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="v3k1m/Z7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 747AE2184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 259448E0014; Wed, 13 Mar 2019 15:17:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 208D08E0001; Wed, 13 Mar 2019 15:17:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11FC78E0014; Wed, 13 Mar 2019 15:17:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C67788E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:17:26 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u19so3271127pfn.1
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:17:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oDmw3i69mGH6D08DC7Bf8ACvPTacz8TJxBAoXmNvO3k=;
        b=EhKC6rFxRtRCK8S/k355amPrxN+UEGPwRr9WPKjBYRbXP3vzCyHsr1OhAjXGMItjU8
         RhvcrMInE5qXIIZZR/qmvKg2a+1z1idWqce6pnIudcVYXelQkd26Rg44aUC03NtNC95o
         sSwgr2Xqhjo6mxh1ARt0YgxJlMOiXmwwbuqe1+JdKayYp+OlW3dKR4IdWn9SdKHeQpUi
         wKY+4RS4nP5Zp9VmL70fy7MO/PYjBYmevQus7U5V031T0CZfQzdXb92H4jdFP3LRv98V
         383UZkvYPLOun69FLGAXDa6I2GTW//lEeyJGOCFPFuup7rt9cyNIMYnMnr6Bb/tTAOaK
         Q0rg==
X-Gm-Message-State: APjAAAX1H/SWMx5znkKNiKyaErbm0K/r4v7EAKhaclzyelEOwtdv/Lx6
	XAjV2zCePijfrYmlQaUUGMtzYoFTy/2WuvPXe+c/t4SOmmsV7P3ZRkiehUHGWmUcqZRjvQbbxaM
	lbR822an/poUajBIagIFFizsWZJd4TxCuLtUVB7AlWjI4oh6LxqsgfKuWhOyN/dEbnA==
X-Received: by 2002:a63:5720:: with SMTP id l32mr41702529pgb.268.1552504646482;
        Wed, 13 Mar 2019 12:17:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAZneFhM90bOHGaDkC2JgmgDBR0idgm5tdRv4rkatOszV+Enf2CH4JVcql/BN3KgAcF+un
X-Received: by 2002:a63:5720:: with SMTP id l32mr41702457pgb.268.1552504645678;
        Wed, 13 Mar 2019 12:17:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504645; cv=none;
        d=google.com; s=arc-20160816;
        b=OexWtkZv1y4Dlk63cph3Oc+J6BLxyj7wfgMVKPmEAph/xswtQgh9tyLSEIcUKSJvBV
         mWCrgF5oT+6/Sx2OjFr4j48OpSow7/E09XT+UTTMqjsp+dwKWdIRDNFQEMMICP0d4CUg
         xvDrbyyUG05lmK9Q/hmx2+T4dsd5t9ikIeriUnDtCUZcxHFeC4An+fVbmE72cSWRAQZ0
         +ok4G1r+HJZaFtFLs2C+Tk7YSvNdIYpEEmGMy7GjDbTBAuzBdTQjUVFm3d8gDnT93RPL
         +B/zlxNGOIXZXwmC1slbkgLG4Xr7a11kGkV+i1Fmeq0DKmxC3UqxUcev2eobOpzUmctY
         d4zQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=oDmw3i69mGH6D08DC7Bf8ACvPTacz8TJxBAoXmNvO3k=;
        b=bPiFP6heWXJz7yF+nCC9/EbOoAWOnbnVN7c6gaP3iaAN0ny60m7kaDxWi5eyM1FiFE
         z8JsW1BG3uIQHt5/mCnYGI/l6De2x5mA1Vl2jYSSMTfD/4bVBR9D8DwT8ZmriOgPD3OS
         4wtLlZL4h8WJisxsXXXA4L/1JyKkFyp8WCOcRwRQAOfbtWZnd1+MV0DynWyEw+OCyOIg
         k3TB1aKFAT2l7WlSRDks/mad0+jnUF8+Aw7+Pk/bQSIW/XBH7K2v2dfy7vGIC4bTZcD0
         eHRls/UU+SqVVblhGvwNLA1IrZ1fhHwavYlaTFYu5ZhV0Fz0YMDCTulFFGrW+AKN4Kaj
         q/Vw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="v3k1m/Z7";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k1si9345574pgo.417.2019.03.13.12.17.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:17:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="v3k1m/Z7";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2409421850;
	Wed, 13 Mar 2019 19:17:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552504645;
	bh=vdUzQVMHuWLFyvgnxQAmlA5Jt7STWLWQI6bJeBv0km8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=v3k1m/Z7v6Yril3rVjYX2+4MQ+iTjZhwkw5Q7tEIDVC3GFIwF8wyPX6D6oY/HvTyN
	 BOk5iZZV8RuoDAMKbgvXW0pUGOgc9Y2h2sxnlqJQ1IqRn+RMzf7zg9vXWuQ8JEO5RV
	 Iegjel3V4PaV7Lb/cEcVTc/nAsIkP2YU68TM9tPg=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christoph Lameter <cl@linux.com>,
	David Rientjes <rientjes@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Kostya Serebryany <kcc@google.com>,
	Pekka Enberg <penberg@kernel.org>,
	Qian Cai <cai@lca.pw>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.9 12/24] kasan, slub: move kasan_poison_slab hook before page_address
Date: Wed, 13 Mar 2019 15:16:35 -0400
Message-Id: <20190313191647.160171-12-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190313191647.160171-1-sashal@kernel.org>
References: <20190313191647.160171-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrey Konovalov <andreyknvl@google.com>

[ Upstream commit a71012242837fe5e67d8c999cfc357174ed5dba0 ]

With tag based KASAN page_address() looks at the page flags to see whether
the resulting pointer needs to have a tag set.  Since we don't want to set
a tag when page_address() is called on SLAB pages, we call
page_kasan_tag_reset() in kasan_poison_slab().  However in allocate_slab()
page_address() is called before kasan_poison_slab().  Fix it by changing
the order.

[andreyknvl@google.com: fix compilation error when CONFIG_SLUB_DEBUG=n]
  Link: http://lkml.kernel.org/r/ac27cc0bbaeb414ed77bcd6671a877cf3546d56e.1550066133.git.andreyknvl@google.com
Link: http://lkml.kernel.org/r/cd895d627465a3f1c712647072d17f10883be2a1.1549921721.git.andreyknvl@google.com
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Evgeniy Stepanov <eugenis@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Qian Cai <cai@lca.pw>
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slub.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 131dee87a67c..979400b1a781 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1052,6 +1052,16 @@ static void setup_object_debug(struct kmem_cache *s, struct page *page,
 	init_tracking(s, object);
 }
 
+static void setup_page_debug(struct kmem_cache *s, void *addr, int order)
+{
+	if (!(s->flags & SLAB_POISON))
+		return;
+
+	metadata_access_enable();
+	memset(addr, POISON_INUSE, PAGE_SIZE << order);
+	metadata_access_disable();
+}
+
 static inline int alloc_consistency_checks(struct kmem_cache *s,
 					struct page *page,
 					void *object, unsigned long addr)
@@ -1269,6 +1279,8 @@ unsigned long kmem_cache_flags(unsigned long object_size,
 #else /* !CONFIG_SLUB_DEBUG */
 static inline void setup_object_debug(struct kmem_cache *s,
 			struct page *page, void *object) {}
+static inline void setup_page_debug(struct kmem_cache *s,
+			void *addr, int order) {}
 
 static inline int alloc_debug_processing(struct kmem_cache *s,
 	struct page *page, void *object, unsigned long addr) { return 0; }
@@ -1584,12 +1596,11 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	if (page_is_pfmemalloc(page))
 		SetPageSlabPfmemalloc(page);
 
-	start = page_address(page);
+	kasan_poison_slab(page);
 
-	if (unlikely(s->flags & SLAB_POISON))
-		memset(start, POISON_INUSE, PAGE_SIZE << order);
+	start = page_address(page);
 
-	kasan_poison_slab(page);
+	setup_page_debug(s, start, order);
 
 	shuffle = shuffle_freelist(s, page);
 
-- 
2.19.1

