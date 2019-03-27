Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C80AC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:11:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C64DB2054F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:11:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="cq8+pGZp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C64DB2054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D9F46B0280; Wed, 27 Mar 2019 14:11:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 660236B0282; Wed, 27 Mar 2019 14:11:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 504006B0283; Wed, 27 Mar 2019 14:11:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0E8F56B0280
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:11:30 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id b11so14671748pfo.15
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:11:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=q7KJhYHTP34l6BTZS/pMkiPJ4G3XhwRer136mt/Cyzw=;
        b=Cm9PZjeyCec1Ku7kUP9C+EQwyunA5KsC/R3ESiihaRoUiuirqRxVwP3xr4MSXtRcZp
         eX1LBy5lBfBSOETJFos7D7GEZ5uKFNLuIxOUa8ckPSHW0YrsPzc5Ees1x8C+sHODMy6z
         U9ggM6o8V8YebgJTvLPsBDl5a+t2NrYuMCWgP4SJ8yy/ICndMgp5Xwcpvjj1eBXn9E63
         MqLtW1oqPnz1A5WdRmIOBorI40BaRQXC5Wt1lLE6uWInjo+/bz3Jd+tlkMXUiQzADLiD
         6YRvU7xXufZSLhu1ccYQ3HC6LdZJcia7ZHEYRC6Ce+YplR1zih10w8vMjxYtfMmu9BHe
         PNGw==
X-Gm-Message-State: APjAAAXrwSztceSGqcm6tTp519AmHyZr3BkvxSYkctXFWONJ0gt3gjc3
	VaZnqkUceknsydeq8zDFZsNk4ZU+do9l91F/uJFKLCVB9boc0pR5CPfvan+U5H6hktQaWevCqB1
	TYwRdRItmkEzExa0AB3PS3LuSrwWObLBwgXz/Hz5vwRILHSMXVAz9+/0gjL0qCr9Ubg==
X-Received: by 2002:aa7:8443:: with SMTP id r3mr36205303pfn.143.1553710289733;
        Wed, 27 Mar 2019 11:11:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6sDeaFu1NC5l4jtBXfD1oPuVeXl+U3bYww0c1fG5XUNCoRS31avpHByoEJLpjW1J0xbmv
X-Received: by 2002:aa7:8443:: with SMTP id r3mr36205219pfn.143.1553710288894;
        Wed, 27 Mar 2019 11:11:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553710288; cv=none;
        d=google.com; s=arc-20160816;
        b=lwg/NvjaEBQBOuGK+1+G0R8GH6U4ePEEH97w6+WZULZ/rllYdwa1gQlhxC6t/yePzk
         httvSeeAVi8O1elnkCr/F1KfwoY3AeKktJRF/n30Z+TI0MI2zLpSszz5SAThTof/GBQk
         DyRoflaP/69+5Y70AxsH9Z1zjO6DcG4LpAEPMrPLp65lKeS+MSmkCnleN+8g6+gyUv8c
         Pd03PE2WJJsV8fgL+MiL8+4c9sIR3xiHMgFR3j+xy1yFA4uuJvY5uZF/PLoNw1nmYyV7
         a9NmCvBKepZo/gukFXkI1+nhmHnMWY0WzFay7mHtBc0sDC2BNwk/JoZtXr0DsSGMUQV2
         qoeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=q7KJhYHTP34l6BTZS/pMkiPJ4G3XhwRer136mt/Cyzw=;
        b=oMu1fYiv5Gg1fGjB2OtZC8gMwTaYBz7C9JdFPtaLCEPZBgXCOwCc2gJiMVtW8cQ+i9
         oyg1DVK9vB9SGvs9lWCSRZGMTGYXjPT/S/ilz8DlJIH9s1aRf5ZvonJDc1+kp9wdgcyK
         +NreUb0X5sEifG5Z+Qd1peEs9TQAtgZtDZprmyYxmzQ36Zs+yHAZjtyTujn93McVSLsV
         4PBdOO3CvSxcomtmS1rgO1vi1iPB0sjaxszh8IeCBqLzzT2qGG8DnVeX1gPaV8gDXuUr
         1IBDPThycLJWBjvCkaZo4H4Mk7M+B8OfWjt6dXJeKE81K8i/2K4oxIXoeewFWKRXOcDn
         ttkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=cq8+pGZp;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q12si8440235pgh.594.2019.03.27.11.11.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:11:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=cq8+pGZp;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C092521738;
	Wed, 27 Mar 2019 18:11:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553710288;
	bh=In4g8WKq3yq3+ez6Cbi8hQEYwyw9mHFFvzbieuzPwsc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=cq8+pGZpwBcX6kxLSRApF/diqbi633+0l176kq62mIXiatXjWmlY9rXleSHScjBNz
	 CxMQ6HzWIxKJCgt+uvOrSAL1HTDXHgqk75pmTXYKqwWK1RVrZphLLgPW1DYayXKn7S
	 MAbvbwyWG6qLp0ve9BOHp82i40QrYTtS1M5Qwup8=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 034/192] page_poison: play nicely with KASAN
Date: Wed, 27 Mar 2019 14:07:46 -0400
Message-Id: <20190327181025.13507-34-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327181025.13507-1-sashal@kernel.org>
References: <20190327181025.13507-1-sashal@kernel.org>
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
index ef99971c13dd..8e6932a140b8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1922,8 +1922,8 @@ inline void post_alloc_hook(struct page *page, unsigned int order,
 
 	arch_alloc_page(page, order);
 	kernel_map_pages(page, 1 << order, 1);
-	kernel_poison_pages(page, 1 << order, 1);
 	kasan_alloc_pages(page, order);
+	kernel_poison_pages(page, 1 << order, 1);
 	set_page_owner(page, order, gfp_flags);
 }
 
diff --git a/mm/page_poison.c b/mm/page_poison.c
index aa2b3d34e8ea..6cfa8e7d7213 100644
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

