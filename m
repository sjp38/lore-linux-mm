Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 525AAC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:58:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11657222B1
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:58:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="LZuoEBFV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11657222B1
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70C578E0006; Wed, 13 Feb 2019 08:58:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F0F78E0004; Wed, 13 Feb 2019 08:58:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48F768E0006; Wed, 13 Feb 2019 08:58:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id E61078E0004
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:58:41 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id f4so895230wrj.11
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:58:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xu9/37gH7GsD7XGP+9mY66oknw0IDCzNaIitxBdfe0s=;
        b=jsjJdVuiaOPGCklx9bhkleye3ga5AMKY4qdyZa3ybev1YyTiakVQCfoDCdjqtksyL7
         LSCOtfbFDtclUe/5w7zrdsCLYSiRtBZ/MF4Zg1o36PaQO40lXF8iPZa0Ybr29QGS7KvH
         nzKNirShen1FbF6lh8yHBJtz9DkHr3i1SF7/JAzPND6dFRZTP76AJeV9t1Gr+bjWd0wn
         uysDCqtHlxp0hKq54rvkunVIXmAtvBxsG1GU4/YO97FQSKVhzRJzyMvhK9d3q/ItzM/J
         Rk/OxVU9Gub3plwtcjOgt3UOSb83oimhT++V2OM66UuKblCQ04oo/XQGRhZTJ7kG+WBR
         kJZg==
X-Gm-Message-State: AHQUAuYbpHRJEfm7cx+rwomjWmKQwVBIUgZFGNQezxEMhBcO7Kq1WlgJ
	Ba1g6JArEpTpVqCY8SjW4sNcfw2kvdNQjL2n15tkWHX490wPXRiAzUUeszD+kidOJl0fVe4s3+x
	i2UG87t+FaHqMZbv0svZQvZUjY3v9y/l1llyNZd/ElB9AHlaJuHC59gf8tsgJYi3F9jmtX8W4gs
	6mXjIWPuFVhgVTJEPOjHJvgb/WY4/3lzZhP2JX/wvJApvbF5e3WBagmsybtubLox0a7Rt8wUYO5
	3XDxPbfiXvBI9WKRZq+2k+w+MGNWMMfIyXjfybvjojEZ41T/BhSRACKMquzRndwmvXYR5JHAOQz
	2r4B5YPQWADV6wxQjC5oAB/i9o1hY5WbDT7rawiNeHwhJs/524JXm6cSXMRolXHTGz2jBxhyUpS
	t
X-Received: by 2002:a5d:5042:: with SMTP id h2mr558010wrt.12.1550066321462;
        Wed, 13 Feb 2019 05:58:41 -0800 (PST)
X-Received: by 2002:a5d:5042:: with SMTP id h2mr557969wrt.12.1550066320605;
        Wed, 13 Feb 2019 05:58:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550066320; cv=none;
        d=google.com; s=arc-20160816;
        b=a63m3YYEOYIORY1bRZkWd/D/zB6kqK7kwFC/fEp6T6v3ZQaoxaUhoTxE/rre+eJI8G
         aQBt9i4zwyzu6hTGh1BlQcbox3wHChvhK2G1hiRnTiUsn8Z4xA4cxJCQjsvFuCFapboR
         bCBFvXmfkBlG9gWnJlJSYBc7Qg45GrhHx1uk6Traww3OqXF5e5Eth2d21b0+dbO7vUqo
         MvOIsL3FOXu2Wmdcx+pCWenRpE7zqVGZVtn6mMxkbdM7mnwMfyTg+lKwoAUty61nNnE7
         dqcYptHScPz/KZn6MjfXSPeauEMS/W8vMjwzm3IzR/eblgs+B201RE7bYHkBaHdQ+lPf
         DWRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=xu9/37gH7GsD7XGP+9mY66oknw0IDCzNaIitxBdfe0s=;
        b=MxmOiqR/+KAoTVt+a86ACiQPgvWGsWHmBq7MDrBjjgxgDVWEDdAxHM5zHbHHmCzA7/
         MnG05kfpYeFybh25VFMymP7SfUWOvVngTnBNtuXfyrYJcgiIlQgxOA1ZY/mTaHd8OXo3
         Dp6CQ5g9W+6qLfTJ2+OZJVH44hrA1ntd4YW8tUOXQ7NJG/usdWiESsHjgholeEDkcbQx
         bqp4FEW/a177gedg47jH3dLnBdQ+hAeOYS2afYUm8q79yGK4otpzPKpLNXHA6lmCCryg
         mtFcPsvfkj5fxVc1HxaGtQ+7J84efefvuD9bNL7OKMCsgZQ6LyOSyJNkK1Sv7BTckUJg
         UCzw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LZuoEBFV;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l23sor4019733wmc.28.2019.02.13.05.58.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 05:58:40 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LZuoEBFV;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=xu9/37gH7GsD7XGP+9mY66oknw0IDCzNaIitxBdfe0s=;
        b=LZuoEBFVaWnAkKQXjENcMdC3sNGWcdA3HmBu8uls/pLTXjoBa2auXv/R80mygqnJQK
         +SvuJyoS3RyiqUvljTK731WoOBraKMvm6D7Ej1H743G6t7ktuiXiZnPZ744s2D7m4blq
         YsPq91p3hRdIGpL64p86i0Zmw0/8MuTO7L5usonaP4RP0hzKXLLRg6SWUHk+GxH5mzF6
         nEOg3Q7g/RhGy5whyZE7hQLMEdyr+kpaB9E7eB/EB8r10C5v2/1R+XGFej1BMSkovI23
         Njrmc4/xiClA2MC9bLpqQFPYw8oovAHIcLvHhDmRkbxPAvK5ByKy6i5x2WkPLbxGYv4N
         efiA==
X-Google-Smtp-Source: AHgI3IYJPHef5SXRQikCmTo4N6D/LQvbU/67LalinnNI2TP41Ugpf9msJPWIIiTh0Rkcfztcv7jCLA==
X-Received: by 2002:a7b:c205:: with SMTP id x5mr442568wmi.3.1550066319928;
        Wed, 13 Feb 2019 05:58:39 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id v9sm11195866wrt.82.2019.02.13.05.58.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 05:58:38 -0800 (PST)
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
Subject: [PATCH v2 2/5] kasan, kmemleak: pass tagged pointers to kmemleak
Date: Wed, 13 Feb 2019 14:58:27 +0100
Message-Id: <cd825aa4897b0fc37d3316838993881daccbe9f5.1550066133.git.andreyknvl@google.com>
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

Right now we call kmemleak hooks before assigning tags to pointers in
KASAN hooks. As a result, when an objects gets allocated, kmemleak sees
a differently tagged pointer, compared to the one it sees when the object
gets freed. Fix it by calling KASAN hooks before kmemleak's ones.

Reported-by: Qian Cai <cai@lca.pw>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/slab.h        | 6 ++----
 mm/slab_common.c | 2 +-
 mm/slub.c        | 3 ++-
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/mm/slab.h b/mm/slab.h
index 4190c24ef0e9..638ea1b25d39 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -437,11 +437,9 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
 
 	flags &= gfp_allowed_mask;
 	for (i = 0; i < size; i++) {
-		void *object = p[i];
-
-		kmemleak_alloc_recursive(object, s->object_size, 1,
+		p[i] = kasan_slab_alloc(s, p[i], flags);
+		kmemleak_alloc_recursive(p[i], s->object_size, 1,
 					 s->flags, flags);
-		p[i] = kasan_slab_alloc(s, object, flags);
 	}
 
 	if (memcg_kmem_enabled())
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 81732d05e74a..fe524c8d0246 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1228,8 +1228,8 @@ void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
 	flags |= __GFP_COMP;
 	page = alloc_pages(flags, order);
 	ret = page ? page_address(page) : NULL;
-	kmemleak_alloc(ret, size, 1, flags);
 	ret = kasan_kmalloc_large(ret, size, flags);
+	kmemleak_alloc(ret, size, 1, flags);
 	return ret;
 }
 EXPORT_SYMBOL(kmalloc_order);
diff --git a/mm/slub.c b/mm/slub.c
index 1e3d0ec4e200..4a3d7686902f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1374,8 +1374,9 @@ static inline void dec_slabs_node(struct kmem_cache *s, int node,
  */
 static inline void *kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
 {
+	ptr = kasan_kmalloc_large(ptr, size, flags);
 	kmemleak_alloc(ptr, size, 1, flags);
-	return kasan_kmalloc_large(ptr, size, flags);
+	return ptr;
 }
 
 static __always_inline void kfree_hook(void *x)
-- 
2.20.1.791.gb4d0f1c61a-goog

