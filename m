Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B6B8C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:59:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BCFE2087C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:59:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="QBH6syJo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BCFE2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B78878E0007; Mon, 11 Mar 2019 15:59:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B28578E0002; Mon, 11 Mar 2019 15:59:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A17998E0007; Mon, 11 Mar 2019 15:59:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4FF1B8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 15:59:01 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j10so238757pfn.13
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 12:59:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=i5FKjuIDqJhHLGPoVt8yH+Oqcq46L3DHW4Hhsovkn1c=;
        b=a7W4VgBf5zRDh54kedeiOhPlEhUa6jUjHsDgIAiw1eaP2wMrPoa/msujPB3sderVL7
         tdoBNndiNrE3wZhzqFSLO/NtIgGvRj5tn40TaaT1/MRDnhx7uRrPnVi4yKxLCXXMOEUy
         AByz7c9XhsKG3G7u/cPx+tpR63c6+SuIKqmKQoFCINBWW36LgYbN8TBcFKeuHEhMxz2h
         XWyZksjMMviU9T425ZSCJAsDhTg07LqBmKx0nsZrlNE/yS+crJIefXufWz3w0wcnTXxR
         8WxqPmWBeEU2yZE9TIaeGuFz+IcGLUf3T3bc6IcCuGPoEiqCn1+nLWz4+TKODsjWyl69
         CN4Q==
X-Gm-Message-State: APjAAAX6wGGBqx8ObEQ8p2WdCnZ4b6pba7TTUVjGu2FW1fYD2/O+Kozj
	miPDZT6AUWKoldZDGJrZjdq1zLfmRRzBWIlw2NcAaIpcSKMInE6QZduQuG6lZZiruli6Mu4gPOR
	SYDgVAGQW8VxcVZGEbPWrMxGnfq/lV8lvl4uY/kW7yyULt5FQSxyehyfu1B84VqhPRw==
X-Received: by 2002:aa7:8390:: with SMTP id u16mr34236162pfm.63.1552334341004;
        Mon, 11 Mar 2019 12:59:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw87VrRtT8EYHi2851XbQRYBVTNUWN0405YtnYUAMVigmNtHy2rTnk9ieRfRckXkfukuqFp
X-Received: by 2002:aa7:8390:: with SMTP id u16mr34236133pfm.63.1552334340299;
        Mon, 11 Mar 2019 12:59:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552334340; cv=none;
        d=google.com; s=arc-20160816;
        b=axUSTnQjqym8EmBzq/EPIQHb7Du1es7DEY76vyavt360Aqow8m7PDkF4X3IxUHOJA4
         9GThJs2qLgj5486HpKECixTla5Cf+dfa6U5A4NTYNFimMJvsXA01+wBiY5K3u69aC4SB
         4mKsvXLMshvt4k6tJtdEa4U+WOF7sQD07aOP3k8CwrueGC1SRILuNBfWK1kctgOG+TWv
         ecy30BWQki4lwaSsU3QL2QdUws7mD383oJAmLemn2pxT2adSyCPBHL3CgVd6vE7xxXJ4
         MSJiQYV7S1luEhlsxQN971PO1BTy36Sbt2ubu1szp6hbK02dc9flozyM/0v6EQho0uK5
         y52A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=i5FKjuIDqJhHLGPoVt8yH+Oqcq46L3DHW4Hhsovkn1c=;
        b=vZ7LqLG4q43+lGoukEN67P5tPiQc4nY7Ffi3bV3FdJwjcW5UsxrARmaPAt/myKVWwL
         X4dUr3kV/MpJxEwP208FhU33Fm99zVLpYi5PBbvsA6v2/+sre1SBqkZUXhI07gh5vxJa
         eo3Y5woA3Ej1fhTWXOvmOgkOul/Fn4ylaL0enJ651CQhshNM3JFGIJV2PSF8vE/q1Egb
         6MB3efPHhyn5/VBpY9xyO7F1hVTpFKHSvkTC/uazH2x32MStuDwAlqjbnOfDfwyh7XjH
         6WXR6217Dgfd1Bw2tf7j8K2MI2nDHoAYpac5DJSeTiKWhCf6f8sr0sgiaFt8cF9PT9i/
         25rQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=QBH6syJo;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 34si2192281pgw.570.2019.03.11.12.59.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 12:59:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=QBH6syJo;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D7E182087C;
	Mon, 11 Mar 2019 19:58:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552334340;
	bh=F0DsVGrPQvtkMT9gqaDZ9OMep6tnhjr4jAft+91ziBw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=QBH6syJobRjMK0u0JH7OEsU1n+kgMsBvi4bfaIDsE34gUdf+USpEOgrejWiZGFgI2
	 FQdhoOQOEBstpfAl1O/IUagBN1p1qZ3rxrJBgrRDvj3loIvKVxy1zUXYB9PhN5J0rr
	 7aGLL38d+0XWrPUZeMANuMAhDf94qEyDB+GmGr0M=
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
Subject: [PATCH AUTOSEL 4.14 21/27] Revert "mm: use early_pfn_to_nid in page_ext_init"
Date: Mon, 11 Mar 2019 15:58:18 -0400
Message-Id: <20190311195824.139043-21-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190311195824.139043-1-sashal@kernel.org>
References: <20190311195824.139043-1-sashal@kernel.org>
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
index c4a45145e102..3d3d79c5a232 100644
--- a/init/main.c
+++ b/init/main.c
@@ -663,7 +663,6 @@ asmlinkage __visible void __init start_kernel(void)
 		initrd_start = 0;
 	}
 #endif
-	page_ext_init();
 	kmemleak_init();
 	debug_objects_mem_init();
 	setup_per_cpu_pageset();
@@ -1069,6 +1068,8 @@ static noinline void __init kernel_init_freeable(void)
 	sched_init_smp();
 
 	page_alloc_init_late();
+	/* Initialize page ext after all struct pages are initialized. */
+	page_ext_init();
 
 	do_basic_setup();
 
diff --git a/mm/page_ext.c b/mm/page_ext.c
index 2c16216c29b6..2c44f5b78435 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -396,10 +396,8 @@ void __init page_ext_init(void)
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

