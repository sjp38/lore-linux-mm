Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D698BC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:17:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A3A9217F9
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:17:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="LstWPQv/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A3A9217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A33E6B028E; Wed, 27 Mar 2019 14:17:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 326FF6B0290; Wed, 27 Mar 2019 14:17:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CA8C6B0291; Wed, 27 Mar 2019 14:17:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id CEDC26B028E
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:17:18 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id x5so4832165pll.2
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:17:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=N5btegiK5lDfDm0kZmkVHI0AgK2Om7Pa4RuTJ5s7ExY=;
        b=PPDPiSw4QaIh4YqDKMY3Yqp2HjKdMjw42II1lWnYnbEa70XDGm3oKlZ5RTNasWc0ek
         1pDkJ6SY2fkhj4Md0GxuroKaQa6MwRIAx8c/DNH5Zy88aDyvzlCkHuhNzMOHh9w5gVFE
         imztH+c6wLp7IvdIz/c7lIlPjy/sLt1YUqQBj+ic9KuWnGCeMAKXELgn/+3A+hpCO3iB
         /OBzTw2ixE7Juowb23zwkYX2IWU6G7RLM48ZWTGW0WB9AGfxovqbUSoacf9Ns1UFCQOz
         1JF4gNn7HRxj+8xor3el83gKHoqhMsnXqcn2N6ap3U+AQbVbxGxWoX2pAsxrIolGUhij
         iGhA==
X-Gm-Message-State: APjAAAUISWfnbZpn93V+auwBhKJ4fLO3K6AfMjvwXvXmqsM93As9pdZG
	whfBCbzfWIISRy1qm+qVwrcJp2Z9pKvwlE92+I0AN7LoU9xSl7TcL4mVy4mun/CHRnwZ9453xzT
	mp0uzqO223Vhem4lyBg1bUTuagklRjadRt4VSkNFvu0PSFpOGwU2rN2mEFObDDstbCw==
X-Received: by 2002:a63:5c66:: with SMTP id n38mr35674913pgm.15.1553710638511;
        Wed, 27 Mar 2019 11:17:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2Az65ZV+rdO1g4KUifwoVt89KrcP5Y5pniaK0Enw2+R0eSLCSFS8aZK/xIkGhyh72Ffgl
X-Received: by 2002:a63:5c66:: with SMTP id n38mr35674867pgm.15.1553710637789;
        Wed, 27 Mar 2019 11:17:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553710637; cv=none;
        d=google.com; s=arc-20160816;
        b=ggHuirVHnIZxuS0+JjBZaCVhIO69Spmx5bYqs53CSDL8U4vF4rqX2kubuwWQROAPNn
         dXyee1vhZdxpbyulFiFUUPxg/pE0pa2nw47Kpd1THBR9ySbJeG4mulnnMv62MZZa87ZC
         cMU2vvHERFipgFXRArKDjxJghCCGwB+rJass/tBX/Fs5elloZzRkkIfBdY0omNoYxlAO
         p3kXzLp7Pw+ESp9FDP24s2/82HqlXvUdQipbKzWGl0+Omk1Mkfsmr1yxcA5VSSxmp8GM
         s7n5TLWxjl1jEOrN5zJ1aiAOywdwWwpE0dGCveIy3dp3Q3vOwAQkCBFWuKCgtSq1de+T
         Jqbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=N5btegiK5lDfDm0kZmkVHI0AgK2Om7Pa4RuTJ5s7ExY=;
        b=O0tx8N29ZEsRLe6sUV/jPRT8uRrolZSLpgPvBjr/DVVHKdz7BcTuu/Pz06+RuW392A
         4mT+F/CSS7yzzFKf+oqVaVV1x80NiMWw1JddUGVsKynZpjJ5DybU9uqijBjsqgfbFWNi
         jkFiuSQy8je0q00P5nIGYhMkwIpQIkXbVoGaof8Fe9lwN+RDYQsW5HDN79awNtRaQDYS
         nKm2ScT5q0sMgzJvyazOhtb7B1eVjrYlT0lbCUmMoNNb0WjQYvA5I8qEvT5kBmaBj+fZ
         U0qKX68v7cPuNvwaZC8dtXNogK16t9vg8IjgzvrMGAr5z49S+dqqFWgub/y0g3Ff6K5h
         qpsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="LstWPQv/";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i8si17890143pgs.568.2019.03.27.11.17.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:17:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="LstWPQv/";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A1648217F9;
	Wed, 27 Mar 2019 18:17:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553710637;
	bh=wlisCwGqbsC50RKfaPld+vJS7bs/zRV7GyW4ebagwKY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=LstWPQv/3uVOR5qW7WwIUsPtZZ9y92Wruz2wYU8IBt3f+3JuaQBsAg/MjwXuJecOB
	 3lfG1dWMUA32zp7Ob/U4NXZAO5wJBJ+qBibmmP7kBCtN46ag40KdK8raB7IetjsrFu
	 y4tkO8obm3BdZ0t6i72xzNZxJ8wxiO9887O78O3A=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 024/123] page_poison: play nicely with KASAN
Date: Wed, 27 Mar 2019 14:14:48 -0400
Message-Id: <20190327181628.15899-24-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327181628.15899-1-sashal@kernel.org>
References: <20190327181628.15899-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Qian Cai <cai@lca.pw>

[ Upstream commit 4117992df66a26fa33908b4969e04801534baab1 ]

KASAN does not play well with the page poisoning (CONFIG_PAGE_POISONING).
It triggers false positives in the allocation path:

  BUG: KASAN: use-after-free in memchr_inv+0x2ea/0x330
  Read of size 8 at addr ffff88881f800000 by task swapper/0
  CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc1+ #54
  Call Trace:
   dump_stack+0xe0/0x19a
   print_address_description.cold.2+0x9/0x28b
   kasan_report.cold.3+0x7a/0xb5
   __asan_report_load8_noabort+0x19/0x20
   memchr_inv+0x2ea/0x330
   kernel_poison_pages+0x103/0x3d5
   get_page_from_freelist+0x15e7/0x4d90

because KASAN has not yet unpoisoned the shadow page for allocation
before it checks memchr_inv() but only found a stale poison pattern.

Also, false positives in free path,

  BUG: KASAN: slab-out-of-bounds in kernel_poison_pages+0x29e/0x3d5
  Write of size 4096 at addr ffff8888112cc000 by task swapper/0/1
  CPU: 5 PID: 1 Comm: swapper/0 Not tainted 5.0.0-rc1+ #55
  Call Trace:
   dump_stack+0xe0/0x19a
   print_address_description.cold.2+0x9/0x28b
   kasan_report.cold.3+0x7a/0xb5
   check_memory_region+0x22d/0x250
   memset+0x28/0x40
   kernel_poison_pages+0x29e/0x3d5
   __free_pages_ok+0x75f/0x13e0

due to KASAN adds poisoned redzones around slab objects, but the page
poisoning needs to poison the whole page.

Link: http://lkml.kernel.org/r/20190114233405.67843-1-cai@lca.pw
Signed-off-by: Qian Cai <cai@lca.pw>
Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/page_alloc.c  | 2 +-
 mm/page_poison.c | 4 ++++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 40075c1946b3..923deb33bf34 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1764,8 +1764,8 @@ inline void post_alloc_hook(struct page *page, unsigned int order,
 
 	arch_alloc_page(page, order);
 	kernel_map_pages(page, 1 << order, 1);
-	kernel_poison_pages(page, 1 << order, 1);
 	kasan_alloc_pages(page, order);
+	kernel_poison_pages(page, 1 << order, 1);
 	set_page_owner(page, order, gfp_flags);
 }
 
diff --git a/mm/page_poison.c b/mm/page_poison.c
index e83fd44867de..a7ba9e315a12 100644
--- a/mm/page_poison.c
+++ b/mm/page_poison.c
@@ -6,6 +6,7 @@
 #include <linux/page_ext.h>
 #include <linux/poison.h>
 #include <linux/ratelimit.h>
+#include <linux/kasan.h>
 
 static bool want_page_poisoning __read_mostly;
 
@@ -34,7 +35,10 @@ static void poison_page(struct page *page)
 {
 	void *addr = kmap_atomic(page);
 
+	/* KASAN still think the page is in-use, so skip it. */
+	kasan_disable_current();
 	memset(addr, PAGE_POISON, PAGE_SIZE);
+	kasan_enable_current();
 	kunmap_atomic(addr);
 }
 
-- 
2.19.1

