Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E09AC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:58:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A288207E0
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:58:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="v/FPUkyA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A288207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F194B8E0009; Wed, 13 Feb 2019 08:58:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECAFA8E0004; Wed, 13 Feb 2019 08:58:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D934A8E0009; Wed, 13 Feb 2019 08:58:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7D0BD8E0004
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:58:47 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id q126so974037wme.7
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:58:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=72pG1JXx9pTwwdTmZ4N/9abSJyq1vghQRBkOj2XfeKw=;
        b=lZTrKL6NL0Z5AyrjN5jRN5w5crCfYDxR+kbpMUHzyau5t+yaZKj8jHNR4IGamjiqAi
         +b5gSlxM8yf57d/SeG7iTi0Ajq78y61Md+v2B26QKINRcv4lIlWsbp9hYIlDdhpQi5iA
         vOb1/Nz5E00FF1UoLXkfHsGJVspPMyigsUr091Mi6TcW5nN9auYlZ+Nr0J33xF+kC4tP
         35v7/4Be8ToLRpU2J7EFzzPPBPoWGr6G2N+PDRH3hAIyISIt0ulj6JsfigJrsOfnfhz7
         Tk1ifXDiDWFe6PAb4NebS/S/n7xrWfkrsQZrRyNP+dTYRcky2Aerzf2SPT91E5PLeY2y
         gjOQ==
X-Gm-Message-State: AHQUAuZspOH2bVHV3jVEh0L3W93M7YiSPa7HRJLNNET8J3mEi9gzjM2o
	LpET8+w3A5G7KsSdHUo5ojBdWH6Q/mHCX2+B4yWNcH+iJTBtUo6zR4q4Lc2ORtufiJCNQt2WMXV
	cnpWFNqKrLIzT1j9K5f1rroE7WG1D+aREGkYTrX6WE8mGsj11iLKYNxpeFBW/66dQuUJzN9Iz3P
	eKgyKxJXAXd5n9G8TNHuG+9CFUWpJF3f9uI5W10ujfh3o2pwXhxWlTMOxvwXPHB5ul7pmzNmQ6F
	lhI8ZUUKu6ubvVIhHsrPp7IxZtCuUiMBgBv9mMqiGzRp6gZSEF22Qbru+J2BwUU94TdTRDXAmOj
	i/M6Pu3PgGKcl59KmOj7ixiSW1WiknC+0SrQMlYFd7kmkL4bzc3dP0J0iCOsUeRVjNxvFnh093t
	5
X-Received: by 2002:adf:efc2:: with SMTP id i2mr557319wrp.44.1550066326965;
        Wed, 13 Feb 2019 05:58:46 -0800 (PST)
X-Received: by 2002:adf:efc2:: with SMTP id i2mr557268wrp.44.1550066326044;
        Wed, 13 Feb 2019 05:58:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550066326; cv=none;
        d=google.com; s=arc-20160816;
        b=cIVVmSSyeGiXqUz01XkI53qob1IN9DcxeFZ94vumoBJ4FtXO+Bzv0VnvGX4AlY2AlE
         r30ZTLH/YYyj82RyTHCqnx2tw4GfWRACxoryANdLfbmsffu686BPAXZ9sx3JPkM9/W2z
         blPAKEZZgN73bx7AOdcdq7rgiCPK/IWyFMKr9rbgabTIGbedcxK55DtKg3gOOI7zY537
         /Jf2Xuki3d139vgSZ+0asBlkbD4PvnLIvOftXgy1norUtwF/jdonAQTsjFfQGAv98E3M
         snaQ/kRL/R7KcyZK+fc63ysbu/Y26N+K0zHsrW5vs+LFnMUPzBCzKeZ0VN6dQzyTI67R
         /knA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=72pG1JXx9pTwwdTmZ4N/9abSJyq1vghQRBkOj2XfeKw=;
        b=Nve/aGn5KlwnFTtgiToO9OQOaZlePXhe8MABi50BCTjrgVUVqcmmZCaa/p3nXL43Wp
         osp4o+E+J39UlGoi3nF2+MjTcsgEAZgsUhfB/Qim7xvBsaD8BcdHBzY7kBsP+eajq9sy
         p2h0cO7qhZ33206HevMB1v8DeY1T3bE1lrhqebhYj0lMFtud3KP9n/jvdem08NyC3jw4
         CqAFFz0qW2GCuRcIXwInLXE3s4mh+CKihp1qJy/k21LW/0GcbfsZqx7CCjAyDz/bchJY
         fWrUHiSeCQrSQtN2u0gx97oTltXJa+rb5mFUbUtLeQqlAk08pilVAUPRfb4hpV6fVxbZ
         JGbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="v/FPUkyA";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h9sor1349619wrs.5.2019.02.13.05.58.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 05:58:46 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="v/FPUkyA";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=72pG1JXx9pTwwdTmZ4N/9abSJyq1vghQRBkOj2XfeKw=;
        b=v/FPUkyA+O8nQlrSyFo2Do+uc3abWZyy1VkLzISNPUV32Z/g2SLr6DHt8F+aP9bCca
         X2sNVYq2Mqqq8c4uFELjHM1pNYrSQZrmWsTqpS/+W0+iqYB1rcMY2GrZOVdPmvBcbP/3
         TIuUgcggk7jOZIwAgIkAqMisw0W50xiT50cphfZzTkQ2G5LO/8PFp9yGtIX8z1FDtrfz
         5V3QXmRkOhUlo00MvEKLq0FWK99shrVA2r3UxY28O6wNA+OSaq9GYNIN0lofvzfZaEYB
         3RivTm0ZInQzS2WCLBpGCahZRFX00KCUTqm1Q4ZU/LpgjOmS6s3zupxYOq/uEpYz2SNu
         7IsQ==
X-Google-Smtp-Source: AHgI3Ia8YJ65gI15fHc64dlpvyIVgpUQffLxwgRbwKBMOlnrlali2Rni0LlhcKEeodCN68fd3eD1yg==
X-Received: by 2002:a05:6000:1107:: with SMTP id z7mr492470wrw.87.1550066325440;
        Wed, 13 Feb 2019 05:58:45 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id v9sm11195866wrt.82.2019.02.13.05.58.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 05:58:44 -0800 (PST)
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
Subject: [PATCH v2 5/5] kasan, slub: fix conflicts with CONFIG_SLAB_FREELIST_HARDENED
Date: Wed, 13 Feb 2019 14:58:30 +0100
Message-Id: <d32495edd0fbef075ff7082dc691294b5477cec3.1550066133.git.andreyknvl@google.com>
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

CONFIG_SLAB_FREELIST_HARDENED hashes freelist pointer with the address
of the object where the pointer gets stored. With tag based KASAN we don't
account for that when building freelist, as we call set_freepointer() with
the first argument untagged. This patch changes the code to properly
propagate tags throughout the loop.

Reported-by: Qian Cai <cai@lca.pw>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/slub.c | 20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index a7e7c7f719f9..80da3a40b74d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -303,11 +303,6 @@ static inline void set_freepointer(struct kmem_cache *s, void *object, void *fp)
 		__p < (__addr) + (__objects) * (__s)->size; \
 		__p += (__s)->size)
 
-#define for_each_object_idx(__p, __idx, __s, __addr, __objects) \
-	for (__p = fixup_red_left(__s, __addr), __idx = 1; \
-		__idx <= __objects; \
-		__p += (__s)->size, __idx++)
-
 /* Determine object index from a given position */
 static inline unsigned int slab_index(void *p, struct kmem_cache *s, void *addr)
 {
@@ -1664,17 +1659,16 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	shuffle = shuffle_freelist(s, page);
 
 	if (!shuffle) {
-		for_each_object_idx(p, idx, s, start, page->objects) {
-			if (likely(idx < page->objects)) {
-				next = p + s->size;
-				next = setup_object(s, page, next);
-				set_freepointer(s, p, next);
-			} else
-				set_freepointer(s, p, NULL);
-		}
 		start = fixup_red_left(s, start);
 		start = setup_object(s, page, start);
 		page->freelist = start;
+		for (idx = 0, p = start; idx < page->objects - 1; idx++) {
+			next = p + s->size;
+			next = setup_object(s, page, next);
+			set_freepointer(s, p, next);
+			p = next;
+		}
+		set_freepointer(s, p, NULL);
 	}
 
 	page->inuse = page->objects;
-- 
2.20.1.791.gb4d0f1c61a-goog

