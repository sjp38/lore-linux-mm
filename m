Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB99EC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:21:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70D5521738
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:21:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZJ16+x4X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70D5521738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEAED6B0294; Wed, 27 Mar 2019 14:21:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9E016B0295; Wed, 27 Mar 2019 14:21:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B164B6B0296; Wed, 27 Mar 2019 14:21:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0DD6B0294
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:21:07 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id n63so14682501pfb.14
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:21:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QgKYrHiwrZYYUY3ApXPIoKEED15yHe/2dZq+nuD4Ujc=;
        b=O8j9914CpwPd1tc8pnmVOScrc1sJ7kr8Xclt+UsmlPG87KVO4OtEWhVl85K1wjCiR9
         PtH5HSUctTS05WNSm8mWNp4zC/j1xTXwqpxYou4Mi+gSRNlCN7obbr2lOF4eRB2P2bp4
         6gge2b8mZUpIbBol1q/8CAMvD64QESwVd9D8jXX4a5kcqLm+yGVoAqrmfpe2EIzJBF+5
         2o4yOjOEq5Dsdilu2JGlUo55vF+whLPf7yhxaf6k56OFEcitNGcMJAJSNN+9J8Sg6aKj
         om4vy2SbvekjuixgQNHQyd41XPQ6JlT/wkUbSgg2jya2Wy/XgzLdPhSiy1cxO6orlVZk
         9zmw==
X-Gm-Message-State: APjAAAWtzvMAJ52IiBTUaO+52R3rcga3AHMSdbjetT9iF7LStl+CVFav
	U3larmF+AHx6TLpjewwSrqgcjIsKp/t076t/DriYV80tY4pd6kppcDz2LnZr3iGxPdF+EsKq3JA
	lFdu/07zZ7FMUOnV7gcNtgWF0Y6vaNlWy4NcnnLm4PQCQi60Zkt3mojojXsZFWkCmqQ==
X-Received: by 2002:a62:7603:: with SMTP id r3mr36940651pfc.32.1553710867143;
        Wed, 27 Mar 2019 11:21:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpRnwutj414UOTFBYxmm/sc6+YTCiBIyzX3WLO3dBHvi2K1wVpM9k0bD/u4rERRJlXab9s
X-Received: by 2002:a62:7603:: with SMTP id r3mr36940595pfc.32.1553710866428;
        Wed, 27 Mar 2019 11:21:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553710866; cv=none;
        d=google.com; s=arc-20160816;
        b=W13wcYNKU3j44vdY90fznDba4MmlNxhW7QTFOmJ8oc1NMbe2qlfyVLa24MZN+vArv2
         x1wVKDalZS2PmMo81JzZBkICbkz5JW3LpHFYDWuR1RZc2bkUjeR/WWgF7cH5yOTNGsnK
         LM9hbQS4GTqDaZZxxz9z0hsZTJOgl/kjW/p/V/e2lK0hiUpIhF7sxvYBJgMZws/SJL2a
         NJ0RMViehoydMX3tKyZGFgVFL9a7bv5au+1/owE0FTLF+8pTqFvmY2Kraajq76Hd04c4
         ss8a6prRal1iMgv/HXppDYmGKNqi8rpa3pFANVmFBqvjJxuc/hgF/qTVg4fHGw6BtpNo
         qD2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=QgKYrHiwrZYYUY3ApXPIoKEED15yHe/2dZq+nuD4Ujc=;
        b=dQIe9PraSCnoTclSx3Wpa1Z619oKApmLU0hKEO/MNbDwCpa+6hUiPPgZpz1aZg13hO
         wfzDgek2KYfL6/Q6LQVBNzJ8m1RDgshjySwgMV7J7bpQ6YwbASVQQdbt1m19Fu3tYK2+
         t+Xv+IokPFwJyup5AMwXy4qPFcRoFcaZmYM/r4RxGQISyrAJfRFisccYL2uQv85LID3V
         SsjHJGyrTBfL4wISDuCgC0Kfs8zU0pScI/eH5E1upXe9taOsb6G4+xH12UEJOvdy3Mds
         UTekZzhY+OAl7aLCrsWyu0J6QAh/4I968Lr7vSUr59wv0FGhnpC2LsDMcrnlq0fTMHlQ
         57/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ZJ16+x4X;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o6si7410018plh.186.2019.03.27.11.21.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:21:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ZJ16+x4X;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CE4FA20651;
	Wed, 27 Mar 2019 18:21:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553710866;
	bh=yydLH4pFYt7J7Oz/YD1nkgWHEuHm4AUgTA3iT764s1A=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=ZJ16+x4X9+Xr0KANdy52RAiPPzoHwj8/zu/JgJEzlA+tFQyaODcrIFTM+mXQbsQY3
	 DUFXZkwS6eBz1GxaNx+T3IVZP8YrTrkW/OhKQLkwTjPJDMNhO67b3yMZYyL1R6RLY8
	 sGHphdYQCQUJjkxm1S9UHDF24vUBkBab6CIYMrEc=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.9 13/87] mm/slab.c: kmemleak no scan alien caches
Date: Wed, 27 Mar 2019 14:19:26 -0400
Message-Id: <20190327182040.17444-13-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327182040.17444-1-sashal@kernel.org>
References: <20190327182040.17444-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Qian Cai <cai@lca.pw>

[ Upstream commit 92d1d07daad65c300c7d0b68bbef8867e9895d54 ]

Kmemleak throws endless warnings during boot due to in
__alloc_alien_cache(),

    alc = kmalloc_node(memsize, gfp, node);
    init_arraycache(&alc->ac, entries, batch);
    kmemleak_no_scan(ac);

Kmemleak does not track the array cache (alc->ac) but the alien cache
(alc) instead, so let it track the latter by lifting kmemleak_no_scan()
out of init_arraycache().

There is another place that calls init_arraycache(), but
alloc_kmem_cache_cpus() uses the percpu allocation where will never be
considered as a leak.

  kmemleak: Found object by alias at 0xffff8007b9aa7e38
  CPU: 190 PID: 1 Comm: swapper/0 Not tainted 5.0.0-rc2+ #2
  Call trace:
   dump_backtrace+0x0/0x168
   show_stack+0x24/0x30
   dump_stack+0x88/0xb0
   lookup_object+0x84/0xac
   find_and_get_object+0x84/0xe4
   kmemleak_no_scan+0x74/0xf4
   setup_kmem_cache_node+0x2b4/0x35c
   __do_tune_cpucache+0x250/0x2d4
   do_tune_cpucache+0x4c/0xe4
   enable_cpucache+0xc8/0x110
   setup_cpu_cache+0x40/0x1b8
   __kmem_cache_create+0x240/0x358
   create_cache+0xc0/0x198
   kmem_cache_create_usercopy+0x158/0x20c
   kmem_cache_create+0x50/0x64
   fsnotify_init+0x58/0x6c
   do_one_initcall+0x194/0x388
   kernel_init_freeable+0x668/0x688
   kernel_init+0x18/0x124
   ret_from_fork+0x10/0x18
  kmemleak: Object 0xffff8007b9aa7e00 (size 256):
  kmemleak:   comm "swapper/0", pid 1, jiffies 4294697137
  kmemleak:   min_count = 1
  kmemleak:   count = 0
  kmemleak:   flags = 0x1
  kmemleak:   checksum = 0
  kmemleak:   backtrace:
       kmemleak_alloc+0x84/0xb8
       kmem_cache_alloc_node_trace+0x31c/0x3a0
       __kmalloc_node+0x58/0x78
       setup_kmem_cache_node+0x26c/0x35c
       __do_tune_cpucache+0x250/0x2d4
       do_tune_cpucache+0x4c/0xe4
       enable_cpucache+0xc8/0x110
       setup_cpu_cache+0x40/0x1b8
       __kmem_cache_create+0x240/0x358
       create_cache+0xc0/0x198
       kmem_cache_create_usercopy+0x158/0x20c
       kmem_cache_create+0x50/0x64
       fsnotify_init+0x58/0x6c
       do_one_initcall+0x194/0x388
       kernel_init_freeable+0x668/0x688
       kernel_init+0x18/0x124
  kmemleak: Not scanning unknown object at 0xffff8007b9aa7e38
  CPU: 190 PID: 1 Comm: swapper/0 Not tainted 5.0.0-rc2+ #2
  Call trace:
   dump_backtrace+0x0/0x168
   show_stack+0x24/0x30
   dump_stack+0x88/0xb0
   kmemleak_no_scan+0x90/0xf4
   setup_kmem_cache_node+0x2b4/0x35c
   __do_tune_cpucache+0x250/0x2d4
   do_tune_cpucache+0x4c/0xe4
   enable_cpucache+0xc8/0x110
   setup_cpu_cache+0x40/0x1b8
   __kmem_cache_create+0x240/0x358
   create_cache+0xc0/0x198
   kmem_cache_create_usercopy+0x158/0x20c
   kmem_cache_create+0x50/0x64
   fsnotify_init+0x58/0x6c
   do_one_initcall+0x194/0x388
   kernel_init_freeable+0x668/0x688
   kernel_init+0x18/0x124
   ret_from_fork+0x10/0x18

Link: http://lkml.kernel.org/r/20190129184518.39808-1-cai@lca.pw
Fixes: 1fe00d50a9e8 ("slab: factor out initialization of array cache")
Signed-off-by: Qian Cai <cai@lca.pw>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slab.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 354a09deecff..d2c0499c6b15 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -566,14 +566,6 @@ static void start_cpu_timer(int cpu)
 
 static void init_arraycache(struct array_cache *ac, int limit, int batch)
 {
-	/*
-	 * The array_cache structures contain pointers to free object.
-	 * However, when such objects are allocated or transferred to another
-	 * cache the pointers are not cleared and they could be counted as
-	 * valid references during a kmemleak scan. Therefore, kmemleak must
-	 * not scan such objects.
-	 */
-	kmemleak_no_scan(ac);
 	if (ac) {
 		ac->avail = 0;
 		ac->limit = limit;
@@ -589,6 +581,14 @@ static struct array_cache *alloc_arraycache(int node, int entries,
 	struct array_cache *ac = NULL;
 
 	ac = kmalloc_node(memsize, gfp, node);
+	/*
+	 * The array_cache structures contain pointers to free object.
+	 * However, when such objects are allocated or transferred to another
+	 * cache the pointers are not cleared and they could be counted as
+	 * valid references during a kmemleak scan. Therefore, kmemleak must
+	 * not scan such objects.
+	 */
+	kmemleak_no_scan(ac);
 	init_arraycache(ac, entries, batchcount);
 	return ac;
 }
@@ -683,6 +683,7 @@ static struct alien_cache *__alloc_alien_cache(int node, int entries,
 
 	alc = kmalloc_node(memsize, gfp, node);
 	if (alc) {
+		kmemleak_no_scan(alc);
 		init_arraycache(&alc->ac, entries, batch);
 		spin_lock_init(&alc->lock);
 	}
-- 
2.19.1

