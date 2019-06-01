Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D372C28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:25:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C61C8273AC
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:25:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="DGXicQ4V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C61C8273AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89CB46B02BA; Sat,  1 Jun 2019 09:25:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 826326B02BC; Sat,  1 Jun 2019 09:25:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A50E6B02BD; Sat,  1 Jun 2019 09:25:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2BF9E6B02BA
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:25:30 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d2so8221058pla.18
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:25:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xlUSJNUSuud7dA2K52Nt4537OvrwHh41t1oTIpozQng=;
        b=JMDjxGDa8gPRXlXkuzaYmDmppAnBFZSZVr70fWU4S7hVXrP0kzBJ7N72alqvMLjH/e
         pHqT9ewKcC6+mBO1JYAXwk9HzQFMja9rBp7Rpi+hQHrMo7eUvfUnKc6KP9AvuVMiU3/V
         urvvxb7uDU7Yy6hk3BM6d/uh0S0ZRv9GqL1wiq1UGSaEHSA0fafrkbnTCC3sHTtmZzMs
         yrwBo5fFNUxfIxax/eyh22kk9fP8SprQ4Cz4uSgECCjVVFpRjuISSDu1U5vonBMhcEXI
         Oy5KovcebhKnFN2Vd4YHkqw75J3AlkUXixzTGqT4vBR66/CmGS4NBYOOVz5Pqx24iMMc
         A1WA==
X-Gm-Message-State: APjAAAUuzJKIvNprTrjiINFpMrrDM52z9f/Ag1e8gAlO3xmGPmd6r25y
	6MtYSh1LhAK/m0nCGrQdMR7z5DEiZkOVGVJDBgxFD8l1AdBCiLxIXE9NkfhjUqGyqfxpgkWL2MH
	Q21pr5O7eHUDmxJFSG3gbV0LJCJuvGHTYBLdj85FQjCOX7bVFHVW0tWjSKhTD3F0OWA==
X-Received: by 2002:a62:65c7:: with SMTP id z190mr17311900pfb.73.1559395529790;
        Sat, 01 Jun 2019 06:25:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhDmD9ZYvm0Cw3iROeyY3lptea7SSgyHinKIsPj1/lxRPVBNobXCtlTMuT4xqj1HQ7Sj8N
X-Received: by 2002:a62:65c7:: with SMTP id z190mr17311831pfb.73.1559395529182;
        Sat, 01 Jun 2019 06:25:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395529; cv=none;
        d=google.com; s=arc-20160816;
        b=zh4IbJUCcpy91VUX44c3ql9TW2IjERIYKvE9WuBWw2uAZlsm7vCZazuepyNniZRhiW
         s7WZyAhGLd587LtI73tg9TC4l+o5NoifSva5llQdmtjcdFF0V3XPeQiumAdWtxiJS1UL
         mWDgTrpKX2iZp58ppcCIO0f/o+16oOYqVoFyxJQBYuz8xSnGVDaKHfMoJjkF87YQaqEQ
         EQPBqnBTa0rOTfZEymYLmMK4Vi7gKpevSbuRO4ruIttNAzHMOHo/HCaP/zNL6yT7gD4r
         fdUbF3H4un2O8zTrgwuJINuRcexGOZKdBr6OVMej/cvj3/Un4Ww8zw2Shzyvee4waT/6
         IlSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=xlUSJNUSuud7dA2K52Nt4537OvrwHh41t1oTIpozQng=;
        b=cAijUwQ/IEsdj5HGZ2uf/M/qYGKMnSD3+dM8SW9xHBEeU98fnSag6lfUlBmAI1XtMu
         luaRekhp4GdVP1TsRtyKqef49DEwBVpY5iqyw5swuuC1ZymfoQ0hvs6IQCtKjXNH8agc
         zgCFlkoChsu3EMXh1PSWDr8E7sn/02/2xDyR/F4ooaS7v8LmaPzhSRKjNoLNOcH/3fqG
         azjCIiNZw49E2bifQlAwkfKJWyCZSYAormevTOZXns73jYz+bPWZDxIBDbxw0mKEP4sT
         XfbIzsor6v+cGyNSajrp4w4KgK2sBXHQ1h+AKTImOshNjiKHy+N8gRu41B11nFC7siMe
         g6gQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=DGXicQ4V;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 92si10273960plf.299.2019.06.01.06.25.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:25:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=DGXicQ4V;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A3FE8273AC;
	Sat,  1 Jun 2019 13:25:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395528;
	bh=2gwOA4oXprxT5utFsmFxHJm6LeTnp8J00kQIUqH1TKQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=DGXicQ4V7Hdnq14PC3+r2NtPJNQcUo/K87bCRiCW7JdRPVfhwNT/3CmDHwcCNbdxk
	 NPY/Oh9mp2EvwXCilUwa54YbFRUM1h5OOeOl5YzZwFANuZbZg3TESI8daUJYC/+O4P
	 hNVJgLy6OkudECk6pqq/Afr7TSrBWBGI69bUuMmA=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.9 10/74] mm/slab.c: fix an infinite loop in leaks_show()
Date: Sat,  1 Jun 2019 09:23:57 -0400
Message-Id: <20190601132501.27021-10-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132501.27021-1-sashal@kernel.org>
References: <20190601132501.27021-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Qian Cai <cai@lca.pw>

[ Upstream commit 745e10146c31b1c6ed3326286704ae251b17f663 ]

"cat /proc/slab_allocators" could hang forever on SMP machines with
kmemleak or object debugging enabled due to other CPUs running do_drain()
will keep making kmemleak_object or debug_objects_cache dirty and unable
to escape the first loop in leaks_show(),

do {
	set_store_user_clean(cachep);
	drain_cpu_caches(cachep);
	...

} while (!is_store_user_clean(cachep));

For example,

do_drain
  slabs_destroy
    slab_destroy
      kmem_cache_free
        __cache_free
          ___cache_free
            kmemleak_free_recursive
              delete_object_full
                __delete_object
                  put_object
                    free_object_rcu
                      kmem_cache_free
                        cache_free_debugcheck --> dirty kmemleak_object

One approach is to check cachep->name and skip both kmemleak_object and
debug_objects_cache in leaks_show().  The other is to set store_user_clean
after drain_cpu_caches() which leaves a small window between
drain_cpu_caches() and set_store_user_clean() where per-CPU caches could
be dirty again lead to slightly wrong information has been stored but
could also speed up things significantly which sounds like a good
compromise.  For example,

 # cat /proc/slab_allocators
 0m42.778s # 1st approach
 0m0.737s  # 2nd approach

[akpm@linux-foundation.org: tweak comment]
Link: http://lkml.kernel.org/r/20190411032635.10325-1-cai@lca.pw
Fixes: d31676dfde25 ("mm/slab: alternative implementation for DEBUG_SLAB_LEAK")
Signed-off-by: Qian Cai <cai@lca.pw>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slab.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index d2c0499c6b15d..9547f02b4af96 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4365,8 +4365,12 @@ static int leaks_show(struct seq_file *m, void *p)
 	 * whole processing.
 	 */
 	do {
-		set_store_user_clean(cachep);
 		drain_cpu_caches(cachep);
+		/*
+		 * drain_cpu_caches() could make kmemleak_object and
+		 * debug_objects_cache dirty, so reset afterwards.
+		 */
+		set_store_user_clean(cachep);
 
 		x[1] = 0;
 
-- 
2.20.1

