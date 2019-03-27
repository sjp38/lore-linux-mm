Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62CFAC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 01:00:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 121EE2075D
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 01:00:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="U7dj3Cr5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 121EE2075D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B7BE6B0003; Tue, 26 Mar 2019 21:00:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9689D6B0006; Tue, 26 Mar 2019 21:00:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8328F6B0007; Tue, 26 Mar 2019 21:00:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C9176B0003
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 21:00:16 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id d8so13229803qkk.17
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 18:00:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=pZxffqpv2AkoRy7l1MYn8mOEK0pZUkSkYNUnR2f18Ts=;
        b=UWEGV74n8eeSMs4cXX5OkOBMZoMPZPkzBFtd8H4qLOvNxFkJcvHJpDsIVamtofFmWU
         uLH4zGtlNOS6eK5sgn2hUuY+j+N3TaL/4HfHCkAE3OCYO4ny8yGpDUT45Tma9KlURtSn
         ItCYPbiFoN01DVmcT/C7AJFoX5AY+ZEm1et8Nc7ntCz6s6kuWEk+iLeaOwX3Kfl2fWbq
         z/F1EsV9FvcSUnQM05G1MvKaj5No13yVlZx6QdIOhNB+ZLpjh3NGaIi7ncAzkcFwC9ij
         qhqM2GDTwcxxxIQlKjvkG+W7qAhLaxewoZwfZ9L5Cz+dbR4Zd0Zr14Vfsda5f3awbL6J
         WqUw==
X-Gm-Message-State: APjAAAXQY5rITtg9zUSriO5Ak/CQw2DWVzmZnyIlTH6una80bjWp+fRU
	VALEOJC+dDCNghpIoJtD1h9lkmz1KS4s7aVUDTqUPDN7Dj8J89ReretyJ0MYgZcG3yxNCEPcRMV
	t6Y3HsMrJQWEnQn5rErzx6YDhXI8zEQYDJxnXV+MjeAa1pQqIhaTBlg0PtphlysKRrA==
X-Received: by 2002:a0c:9528:: with SMTP id l37mr27835898qvl.243.1553648416115;
        Tue, 26 Mar 2019 18:00:16 -0700 (PDT)
X-Received: by 2002:a0c:9528:: with SMTP id l37mr27835808qvl.243.1553648414932;
        Tue, 26 Mar 2019 18:00:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553648414; cv=none;
        d=google.com; s=arc-20160816;
        b=GI0NsUq74s28eVDEQrg7puO92ELbU657Lv4HDBzuzuMsmS4Q23devF1TuxjDf/j4ll
         Bn8VzKKM9Q47d+1c9T86xRD4YMDBCesrcUf6dJgb8pYRy/5XGUsiIzZ6J+vberixX4+x
         6y346MaXt0YDOMPRHgXnPANCP/Ky03AX9Jofhd7TnYGprkqtPaBbX+xVvQp/tKh39sKg
         UtXE6Y3ZEi3ON+pxBR0BXKZA/JD3xt9nW0dAo9lgFs54MefkP5hGreJNsO+VOB5D9b0v
         wlsek56Z2Cvv7OrJoCQ2g9cQLKoJvmPKZAlPYK76rPuThg1FaHkTq3fEC6OOtjfyeBE1
         l4ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=pZxffqpv2AkoRy7l1MYn8mOEK0pZUkSkYNUnR2f18Ts=;
        b=a8S6OWYiCeWgLejHyu8B8A+hPQBtJpuB93XwRsm+U0EsGeA79a/Jg958pSzMiWKQo9
         fjFCDd2+1LSdcRLluqTbDVtY1P8wi9XzGj/WdJiJSXDiu/8dfouDs8FPPDC2EE4y37/R
         2QNZILT6mDjX0wj1DqyX4FqU+l8bR/K4K9ZXieyH8dgPy5ta6KVNNCQeWN00cqIpgc71
         e/QNypL/iKMHQW+4N1KMze0bW5GVFMaFdzVYiNTBbIxUZaoVtiQUi8cIHSs2I/GcJtPh
         uTXUqy78gTihyxNASqElm10MhK6aq9fdiymUpVJXx9dD1Y/gCBwS/ZbOP61tNoowDMt6
         L1/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=U7dj3Cr5;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i58sor24800045qtc.13.2019.03.26.18.00.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Mar 2019 18:00:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=U7dj3Cr5;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=pZxffqpv2AkoRy7l1MYn8mOEK0pZUkSkYNUnR2f18Ts=;
        b=U7dj3Cr53elo9aF+87clxge+HccjN2L7G7EmN+YbZQJEzwn1rZLsOecFkFfmh32iIS
         3OolISTsTDjaeGqpIGfYIeTQhUzj2zax/UQ5TfLl8LfYCASUnTnUjxH9AOcHm9t76B5j
         vfp1SzSqKeAL5zv4eQkDoS1PMTo+KArXgtJFxzQ0OYbQVDaKt364XEJRT44ACDiUMSbS
         1kYHA4gEp6RyrERzBVsyG3cBsm4LYQefYZsQldtyjDg0ose1Nm9IlAXLRhGWL1UF8kOk
         ICcHl8yyGZE+wdygbNGyNee3OEJaE+4g8djjqMl5LXKK4uMp6cA/dNqmwbEgjYvoTsIa
         DyAQ==
X-Google-Smtp-Source: APXvYqwl4TaXQkcnOk0vHKSITH5fSKz32SoS1GojFCbNObWe52QerscJNR7oDPb0LKa+63PVnFPuJA==
X-Received: by 2002:ac8:29e8:: with SMTP id 37mr29212714qtt.153.1553648414651;
        Tue, 26 Mar 2019 18:00:14 -0700 (PDT)
Received: from ovpn-120-94.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id b3sm10821266qti.33.2019.03.26.18.00.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 18:00:14 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: catalin.marinas@arm.com,
	cl@linux.com,
	mhocko@kernel.org,
	willy@infradead.org,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH v4] kmemleak: survive in a low-memory situation
Date: Tue, 26 Mar 2019 20:59:48 -0400
Message-Id: <20190327005948.24263-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Kmemleak could quickly fail to allocate an object structure and then
disable itself below in a low-memory situation. For example, running a
mmap() workload triggering swapping and OOM. This is especially
problematic for running things like LTP testsuite where one OOM test
case would disable the whole kmemleak and render the rest of test cases
without kmemleak watching for leaking.

Kmemleak allocation could fail even though the tracked memory is
succeeded. Hence, it could still try to start a direct reclaim if it is
not executed in an atomic context (spinlock, irq-handler etc), or a
high-priority allocation in an atomic context as a last-ditch effort.
Since kmemleak is a debug feature, it is unlikely to be used in
production that memory resources is scarce where direct reclaim or
high-priority atomic allocations should not be granted lightly.

Unless there is a brave soul to reimplement the kmemleak to embed it's
metadata into the tracked memory itself in a foreseeable future, this
provides a good balance between enabling kmemleak in a low-memory
situation and not introducing too much hackiness into the existing
code for now. Another approach is to fail back the original allocation
once kmemleak_alloc() failed, but there are too many call sites to
deal with which makes it error-prone.

kmemleak: Cannot allocate a kmemleak_object structure
kmemleak: Kernel memory leak detector disabled
kmemleak: Automatic memory scanning thread ended
RIP: 0010:__alloc_pages_nodemask+0x242a/0x2ab0
Call Trace:
 allocate_slab+0x4d9/0x930
 new_slab+0x46/0x70
 ___slab_alloc+0x5d3/0x9c0
 __slab_alloc+0x12/0x20
 kmem_cache_alloc+0x30a/0x360
 create_object+0x96/0x9a0
 kmemleak_alloc+0x71/0xa0
 kmem_cache_alloc+0x254/0x360
 mempool_alloc_slab+0x3f/0x60
 mempool_alloc+0x120/0x329
 bio_alloc_bioset+0x1a8/0x510
 get_swap_bio+0x107/0x470
 __swap_writepage+0xab4/0x1650
 swap_writepage+0x86/0xe0

Signed-off-by: Qian Cai <cai@lca.pw>
---

v4: Update the commit log.
    Fix a typo in comments per Christ.
    Consolidate the allocation.
v3: Update the commit log.
    Simplify the code inspired by graph_trace_open() from ftrace.
v2: Remove the needless checking for NULL objects in slab_post_alloc_hook()
    per Catalin.

 mm/kmemleak.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index a2d894d3de07..7f4545ab1f84 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -580,7 +580,16 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 	struct rb_node **link, *rb_parent;
 	unsigned long untagged_ptr;
 
-	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
+	/*
+	 * The tracked memory was allocated successful, if the kmemleak object
+	 * failed to allocate for some reasons, it ends up with the whole
+	 * kmemleak disabled, so try it harder.
+	 */
+	gfp = (in_atomic() || irqs_disabled()) ?
+	       gfp_kmemleak_mask(gfp) | GFP_ATOMIC :
+	       gfp_kmemleak_mask(gfp) | __GFP_DIRECT_RECLAIM;
+
+	object = kmem_cache_alloc(object_cache, gfp);
 	if (!object) {
 		pr_warn("Cannot allocate a kmemleak_object structure\n");
 		kmemleak_disable();
-- 
2.17.2 (Apple Git-113)

