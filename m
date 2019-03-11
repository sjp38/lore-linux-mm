Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 780E5C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:56:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BB522175B
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:56:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Leoz/kHg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BB522175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABB3A8E0004; Mon, 11 Mar 2019 15:56:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A41AD8E0002; Mon, 11 Mar 2019 15:56:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BE138E0004; Mon, 11 Mar 2019 15:56:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4AF058E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 15:56:29 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a72so219748pfj.19
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 12:56:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=y+T7LaAVSOaaMtB0bKbeXpLrdjJpCnhx0hvktBiv7Zo=;
        b=s5Eje8rGd7WxgaRwc7ZjLiJA3XHIXZe8x+QqT1ytwdcD7MEis1t3V1KOHLPfj/v27/
         OzXFHm9mHnouaS+SQjhU5w/GxLghEaZEj2die/UZu7FiE78KoVGNt0tk8quC4AemYDwp
         R/5AFhCIhmHQ6SSOTtQEHzYnnACZhsW7glKs1Jd4ugsD+MAFLxGXO8jl4rDieIjVbR3M
         PkBcGURqpI3SFqjEg4fqa3FLpTGK+U7QxJMXFdOZJ9ztC3b/x+My/hB7xQWWRJ3jE35D
         FSuPfioACoizXlcBhunm+umXuicUwtis5WcXJEBIO0sxkDV61uBoecomnSEvbuJX36jG
         tE2A==
X-Gm-Message-State: APjAAAV9Zq496d+X2a1nMqRn8I7bk0V5ll0AAX7U5WZoCSVYc/gIV7kk
	lksBlH4wvHoBGo72Jlj85kRyw7PjUT6zks9FcRc/Xo5RstiuEVTzVMDp0EUs1DMfHbNaJfYPVLs
	b5r03UOByGOZcqVMiJPXoX3iyN56kfqEoJh7LuOuPI2jOTJE893oTZNKjGvkwPWe25g==
X-Received: by 2002:a63:8b43:: with SMTP id j64mr14162593pge.332.1552334188951;
        Mon, 11 Mar 2019 12:56:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybqQ8Wk8fO6/atP+nlA7//NchLgcWW0yLK9n3C4GgK9ns3BEa+HI/TfwshXBxAm43tsIbr
X-Received: by 2002:a63:8b43:: with SMTP id j64mr14162532pge.332.1552334188191;
        Mon, 11 Mar 2019 12:56:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552334188; cv=none;
        d=google.com; s=arc-20160816;
        b=0S9oaU2SPMZ7SYB0A8PTFgM6RjLR0Pd0Rita6MN553CTQwmg4QMPhE25MkmeVKkaRb
         d/VRfAa3F7/c/2DENv6AksZubpuVtQKKCIum5dKZyKcTL0KsykUIRxv5RbFJjDWp6Awp
         2dj50f4zzt86mNqTcMUPNo18NGE3wGGG6fqFzOGcaeIsghu4mOypjo2DOi0cR7kh4Zcp
         PK1ABonk9MTqQNRDaB2AiXVDAS5RgXnbSsdyYAlHu/L+Len9D/G46I5mhdAF3pGSzv7F
         bsBeStXikQQK0ihIs6oYg3KXUpQX/WkasIO3y77utV0eX+W7rqFscyOPmFD1Q7cMKuf6
         XwDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=y+T7LaAVSOaaMtB0bKbeXpLrdjJpCnhx0hvktBiv7Zo=;
        b=I8Fx5IlY/tdYDCnN5/76pW9rdnGAekXXOF8gQn8ukwzQuq+FjABMZecJwFNQEGQpwm
         SlZSa5CKP36aGV0VMBNM877ePpPkyk5RzeT1hr8lXfoRuAE8IWq6E+t8Z95k05ZMSkE1
         PIsbXFBnRou+3n+dcVPZ45nlil75TUAUj6RSd6QLn/edWH5yNVr/1C/g+GW/oiwp7IOR
         xzGrd8GU021ZA9aCZUTqGu+Rsvnh+fHpoVkFFoia/kRxf0IcDCkyL9viKHvmb+aIKfMt
         FeTlOp4fGbPJJPLVuNhA/qPjZlqL3v57DUc7OZPYEv0jAeNjRCHNQz1e/QbHqasgkbiG
         4EvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="Leoz/kHg";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r74si5772275pfa.249.2019.03.11.12.56.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 12:56:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="Leoz/kHg";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BEC30217D9;
	Mon, 11 Mar 2019 19:56:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552334187;
	bh=96fweznMXPE/vh0EMoHo+TkT1UGQCGtN3rh9Yv7tpSo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Leoz/kHgmSSe5RpF1YxH3yBxxFzWIXP/BguDUFaqDMXvEd8opesJkwh/sSACwEMrC
	 OURQ7EAW4kYKWbawdjRelpXz1HOpSQG8ndLfra6oRnarIxyjOqmVbelhKIHTp1BGx9
	 lMqo6WbVfiSy7Qa7tdUUwYARmtmrznMtAHzbIWBw=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Pasha Tatashin <Pavel.Tatashin@microsoft.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Yang Shi <yang.shi@linaro.org>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.20 38/52] Revert "mm: use early_pfn_to_nid in page_ext_init"
Date: Mon, 11 Mar 2019 15:55:02 -0400
Message-Id: <20190311195516.137772-38-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190311195516.137772-1-sashal@kernel.org>
References: <20190311195516.137772-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Qian Cai <cai@lca.pw>

[ Upstream commit 2f1ee0913ce58efe7f18fbd518bd54c598559b89 ]

This reverts commit fe53ca54270a ("mm: use early_pfn_to_nid in
page_ext_init").

When booting a system with "page_owner=on",

start_kernel
  page_ext_init
    invoke_init_callbacks
      init_section_page_ext
        init_page_owner
          init_early_allocated_pages
            init_zones_in_node
              init_pages_in_zone
                lookup_page_ext
                  page_to_nid

The issue here is that page_to_nid() will not work since some page flags
have no node information until later in page_alloc_init_late() due to
DEFERRED_STRUCT_PAGE_INIT.  Hence, it could trigger an out-of-bounds
access with an invalid nid.

  UBSAN: Undefined behaviour in ./include/linux/mm.h:1104:50
  index 7 is out of range for type 'zone [5]'

Also, kernel will panic since flags were poisoned earlier with,

CONFIG_DEBUG_VM_PGFLAGS=y
CONFIG_NODE_NOT_IN_PAGE_FLAGS=n

start_kernel
  setup_arch
    pagetable_init
      paging_init
        sparse_init
          sparse_init_nid
            memblock_alloc_try_nid_raw

It did not handle it well in init_pages_in_zone() which ends up calling
page_to_nid().

  page:ffffea0004200000 is uninitialized and poisoned
  raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
  raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
  page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
  page_owner info is not active (free page?)
  kernel BUG at include/linux/mm.h:990!
  RIP: 0010:init_page_owner+0x486/0x520

This means that assumptions behind commit fe53ca54270a ("mm: use
early_pfn_to_nid in page_ext_init") are incomplete.  Therefore, revert
the commit for now.  A proper way to move the page_owner initialization
to sooner is to hook into memmap initialization.

Link: http://lkml.kernel.org/r/20190115202812.75820-1-cai@lca.pw
Signed-off-by: Qian Cai <cai@lca.pw>
Acked-by: Michal Hocko <mhocko@kernel.org>
Cc: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Yang Shi <yang.shi@linaro.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 init/main.c   | 3 ++-
 mm/page_ext.c | 4 +---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/init/main.c b/init/main.c
index ee147103ba1b..5def2b073b9c 100644
--- a/init/main.c
+++ b/init/main.c
@@ -695,7 +695,6 @@ asmlinkage __visible void __init start_kernel(void)
 		initrd_start = 0;
 	}
 #endif
-	page_ext_init();
 	kmemleak_init();
 	debug_objects_mem_init();
 	setup_per_cpu_pageset();
@@ -1147,6 +1146,8 @@ static noinline void __init kernel_init_freeable(void)
 	sched_init_smp();
 
 	page_alloc_init_late();
+	/* Initialize page ext after all struct pages are initialized. */
+	page_ext_init();
 
 	do_basic_setup();
 
diff --git a/mm/page_ext.c b/mm/page_ext.c
index ae44f7adbe07..8c78b8d45117 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -398,10 +398,8 @@ void __init page_ext_init(void)
 			 * We know some arch can have a nodes layout such as
 			 * -------------pfn-------------->
 			 * N0 | N1 | N2 | N0 | N1 | N2|....
-			 *
-			 * Take into account DEFERRED_STRUCT_PAGE_INIT.
 			 */
-			if (early_pfn_to_nid(pfn) != nid)
+			if (pfn_to_nid(pfn) != nid)
 				continue;
 			if (init_section_page_ext(pfn, nid))
 				goto oom;
-- 
2.19.1

