Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01D15C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:58:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A86742190A
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:58:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="htKdKO8v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A86742190A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0D3A8E0008; Wed, 13 Feb 2019 08:58:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B250B8E0004; Wed, 13 Feb 2019 08:58:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 973AE8E0008; Wed, 13 Feb 2019 08:58:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0288E0004
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:58:45 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id f6so573398wmj.5
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:58:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZJ19SdNCKgDIE486SghXxp8EeRTbnWgedDgd49Ot8LY=;
        b=rOCyXrJ5edRybFI5HvuoAhZ2U9ffEDN6LHA0EUuNmqEy4iBBoXQsd1JIQAwm2bGkvr
         UIriduDGz3AOuEKcPfX/w2mMX20MpYJwks778mIehzX3ut9A+UXd9xDoBXtkmCqD5trk
         xN3qll8Kr2F/gpwvN5WP8DrFrzl5GLLrBehoyX7q1OoMp0WEZtUmdOx5x7k3P3s23geA
         QXTIYz5KeO3ij4BK2/6s1dU+IdoMn8d4XXEjKX8tgLNw/NkbilS2jlkOKLKIdm7gZfho
         6oalHjriYZGZQRzF9FQ0cRRWsUgVuie4ndW1aPkTs4zsNlURSdQZg+StQqhK1w9hHOFi
         tIxw==
X-Gm-Message-State: AHQUAuYfWTH/kYRMkWQbMqMtVryZ5Ak/8wpitRVsaebKUFQQcL1mW4hp
	KAGkpxMYmZp0ITrKW2Li8mJWZlGGsGbGQnPwwZuroK1P5Yh6FUFE11r9v7cfzlv25bcz1xpfabY
	oeH7d6baYXrn9Vx9C0R//lr2ksJJlrB3wAFI5omYiziiknQscibIvz1CXORkIDGUMNILSaGhWlv
	geGfHCtZLUJPr7mnWg/Wj7H3SWjwFtnpoCXfxSpkTJOhhXKOOUQ8If4G9CE3vPyJQ5B1CrqhLHA
	N2ephMocPQbqqdCg1rF7gZAitEQJtMjL3OX91Gip/jXSIN07Qo7/LYQCTgHHyx3OyhqpKXtuAQs
	2tYzeEsvaSxA8C0JY4ywQU/3/vQDcFU3Uxzih/KtnXe32mn9Tp1N9izj7j8Px8pGmiDDs7/9Ec4
	Q
X-Received: by 2002:adf:9083:: with SMTP id i3mr540493wri.124.1550066324822;
        Wed, 13 Feb 2019 05:58:44 -0800 (PST)
X-Received: by 2002:adf:9083:: with SMTP id i3mr540454wri.124.1550066324046;
        Wed, 13 Feb 2019 05:58:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550066324; cv=none;
        d=google.com; s=arc-20160816;
        b=dj03Sz8podvpPinK31TY1WSpFuC31fIdc8T+BqGG3RNajTBe+Q4ZTKsqSy6Bl0wmEy
         0YQHnN4a9N2VAxLZppBtJ/4+4CkaaWMAbCVRkd8TDdc+8gi3ECWliElQSQ0U/TdvpIpc
         zQlTRDPYofTWPsmGo8BMnTrGjFywEKxo24xl8bq2L3ze5k8rGqOKdNtyLXCBPf8zIbxk
         iAphQfBl/45vG8NpPr0HvvQG6p9aQ4kPGDvYOHFDPYCecwFsjyHD+gF0BbnRp4gF/CIp
         vRXIDV4pXTGto9nzzLT+n4eWj9MfMuMaJ4SP27dEmOmiQ7kY4VutF4inHgD3PWOLfzMN
         Qwrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ZJ19SdNCKgDIE486SghXxp8EeRTbnWgedDgd49Ot8LY=;
        b=eCZPGlo7uT9AtJMkIfi0PbyFD19jNLbD6Q0c/vXfM2AmWbmQ0byLJk0EmQdaV3jGph
         pvfj2q6NDU91gbctt9ausR5FznkiI0Oa08rsTxc/g3pbbF4giEG+O3OCU+WMAoHFUjSz
         NBQW4AcXUmqJrIb8p4Tko5geOFG684xz68MCSA/x8sPreTiMCnaOiqwHbNdL85pe7nd3
         miV5jZzWS2NtA4PTJTJ+zI4oe6IKt1FP15or2Ijms9gU6yc6NKZtg/bMoT19ZcKO3NU3
         dm7AJQuJZOrVbFj4+jdkK1eVGYLxEJXjRX/x7+6DswwxzJUFYfY8INWDLucsBXCcPZy0
         ARqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=htKdKO8v;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g4sor3917406wmk.5.2019.02.13.05.58.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 05:58:44 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=htKdKO8v;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ZJ19SdNCKgDIE486SghXxp8EeRTbnWgedDgd49Ot8LY=;
        b=htKdKO8vBTjshwQ3AOXHQnliRn0Kc/VxXw/fuELJfZIt5p2O5gZSUsF3Jlhe0FkTeZ
         3M/UhAc0stoT14pdlauSdJf2FZTh0Sda9yQQCgez0E7owtrrPruZySyeFqqo69LLAa8H
         Q360545gVBI9qQ0ZQOYy0wij5E76UXsK6xgkZD+UHJID4L9I0q/hCt3G60FVtLZjmbnO
         45X4MQAtsfktah0kAQEZQVq2fT8Eoa6gR/MTOKnKgIlOj9Ols0BjUSyAfB1rhUGlXexd
         ZJQtEIYllF/hRJwCKNFLRog1j08jsXuRQHVzq18Mj/7Z883WDpVYDrnfrCElgy3Db0sh
         PWCw==
X-Google-Smtp-Source: AHgI3IZzwEwCq280Wk1OdXfBbHFirTmNRy3Kd9bMAGui2G/AoloTA3zMirRTtinqrouFWX4qc+C4Uw==
X-Received: by 2002:a7b:cc86:: with SMTP id p6mr438129wma.32.1550066323461;
        Wed, 13 Feb 2019 05:58:43 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id v9sm11195866wrt.82.2019.02.13.05.58.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 05:58:42 -0800 (PST)
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
Subject: [PATCH v2 4/5] kasan, slub: move kasan_poison_slab hook before page_address
Date: Wed, 13 Feb 2019 14:58:29 +0100
Message-Id: <ac27cc0bbaeb414ed77bcd6671a877cf3546d56e.1550066133.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.20.1.791.gb4d0f1c61a-goog
In-Reply-To: <cover.1550066133.git.andreyknvl@google.com>
References: <cover.1550066133.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With tag based KASAN page_address() looks at the page flags to see
whether the resulting pointer needs to have a tag set. Since we don't
want to set a tag when page_address() is called on SLAB pages, we call
page_kasan_tag_reset() in kasan_poison_slab(). However in allocate_slab()
page_address() is called before kasan_poison_slab(). Fix it by changing
the order.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/slub.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index f5a451c49190..a7e7c7f719f9 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1075,6 +1075,16 @@ static void setup_object_debug(struct kmem_cache *s, struct page *page,
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
@@ -1330,6 +1340,8 @@ slab_flags_t kmem_cache_flags(unsigned int object_size,
 #else /* !CONFIG_SLUB_DEBUG */
 static inline void setup_object_debug(struct kmem_cache *s,
 			struct page *page, void *object) {}
+static inline void setup_page_debug(struct kmem_cache *s,
+			void *addr, int order) {}
 
 static inline int alloc_debug_processing(struct kmem_cache *s,
 	struct page *page, void *object, unsigned long addr) { return 0; }
@@ -1643,12 +1655,11 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
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
2.20.1.791.gb4d0f1c61a-goog

