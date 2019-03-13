Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D626C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:11:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13217217F5
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:11:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="bOU2LxVp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13217217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5FB98E0003; Wed, 13 Mar 2019 15:11:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE6CB8E0001; Wed, 13 Mar 2019 15:11:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 987AA8E0003; Wed, 13 Mar 2019 15:11:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 520608E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:11:37 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d2so3247642pfn.2
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:11:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WLtfyjbYwZW+ZPLWGPFWUvVo/1Ppl6CC9qHgChQ7Xho=;
        b=aVjs2/nrUfcTln/NtDBs7EAXIGc/hjJ2NWRNbVulyjk46wZle20Gu9+UZOLovoRx94
         9bPQDE504N0bzriyrFOozNxil9OLhQ1CKVC23Srv1Deivh2fR8M4bW/JV8SpFB5Awdcd
         ZojzeLKAUEEeHr/SV3q4bOBFwo4ss++lDTgDjAO883y+8DWTI3Mwh5tZh0umjoE5EhEN
         Syl0Yye0VeQVJF2GhU6+3tBZ08LpGJaCA5lkDmPrfo1QMZ18gg24zwnjcIOKWfE+s6KE
         wwKatRulOZYPcOeEGwztDXro3RAMOg6uZqJwp/v25v2Aqux7201s2e/eB4bz3b2xeZoz
         WIoA==
X-Gm-Message-State: APjAAAW+DgQDE3MXiccd0Q3LFTysAmg0fMPppgNOmA+ZH1ZfOABRpcuH
	K4dBWaflouKIjq7YhD1v0BZY+zAHcyR9b+m5EYSh6VQGaCpUV8q5Gj4vKIyJMTMGOUIzTWASpIA
	deSIIUYAnARxe4KOA7HBBqPLIuqwUSnQhl7zemgx5UYUhC+a1QZkFDycI+Xf4ZSv+Kw==
X-Received: by 2002:a17:902:b20e:: with SMTP id t14mr46222927plr.97.1552504296776;
        Wed, 13 Mar 2019 12:11:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfzDMLBCXpPE2QsGE5ZG52CppcYzLNV5DepsfbAxop6q84AujULm1qjqZYtBY5du87UFsj
X-Received: by 2002:a17:902:b20e:: with SMTP id t14mr46222869plr.97.1552504295974;
        Wed, 13 Mar 2019 12:11:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504295; cv=none;
        d=google.com; s=arc-20160816;
        b=s4HnaVxu0osGw05vkLZAkeybUZzjOptDSYQd6jnS9Cs0Wv+OYLfrdBHQOiexgzUb0d
         QYOZ4NPObOkMn1q+nrSQ2dATw2PGM2Zfa7LSfxpwGyWRz/rHCiA6o9aWc8v9WrDhiSeq
         Ctnqne/W7c0P9tYikEOk4dFKVj3Zj43ZcMbSnVqI+LhxPBfRIqQh88rZS+U+4QdOSDXw
         Gvv0+0GSRNBBkbkA4iqReNcDFrnbpUd6Kgjl7hnIX5zk6J7aC3nVF9376UcejN8vX5c4
         aXmo7C06q9cB7pT4e0g5wzuJFNAC4B/AiddNJfHuTZlDtc1jH8mF1ZNdo1pRckbtLKQR
         UY4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=WLtfyjbYwZW+ZPLWGPFWUvVo/1Ppl6CC9qHgChQ7Xho=;
        b=K6CDw2qvpo9zCrMp3wiC7aAipHR7M5h6yosUbuPCnOSnrXUQZ2m19x3Qw6F4xLW1KS
         OrzkMRqUSnONhxeIelXG+vnOiQtxgIirAZ+Bg2r8KnzhuzOsL7bR7C83HiLogPm3XN/n
         eD6OwQmo9BS8eXaqsffQ826hI+6XRyJ2v0+XyqrjjT/JTdauxSLzD1C/Zncq+/nGllBg
         ngxBJTYxYu46ti1YU86XNaNHZeQuXnNW6HJlOZo/29s6iUcLcrHMh8WnJJmJk7V/wwKj
         8iCWQxwVD/eA5jVyAO1ty6+gCGth5nlZjIZh7P/80KXDH8oKxwrvsT1tldBHtmlnUFLT
         H+3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bOU2LxVp;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t134si9859300pgc.467.2019.03.13.12.11.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:11:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bOU2LxVp;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 76C2D2075C;
	Wed, 13 Mar 2019 19:11:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552504295;
	bh=BFMiFCb16F7+mfsZq3oOVj05LTsKXjadZiB9F30QfHA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=bOU2LxVplTTdlxMQHlWHeAlHxhN5R6qO2fIcr3vsy8RO3Y1bcfgPqGYhoKOfVpHAE
	 PtqdDKHxsJUKoixTdPU9WpRPlQPduL21gJRXuRulOd64wMobb9gKPMiVpqee7aevkS
	 VbXBHuQOBcUAG8QGXOH1LBtXSpD3pW8uvxe1vPi8=
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
Subject: [PATCH AUTOSEL 4.20 34/60] kasan, slub: move kasan_poison_slab hook before page_address
Date: Wed, 13 Mar 2019 15:09:55 -0400
Message-Id: <20190313191021.158171-34-sashal@kernel.org>
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
index e3629cd7aff1..d1e053d48f46 100644
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
@@ -1640,12 +1652,11 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
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

