Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CA39C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:35:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 048C8217D9
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:35:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="JOEECtgZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 048C8217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE0F06B000C; Tue,  6 Aug 2019 17:35:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB87F6B000D; Tue,  6 Aug 2019 17:35:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CE336B000E; Tue,  6 Aug 2019 17:35:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 67D866B000C
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 17:35:09 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y9so49099763plp.12
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 14:35:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jokA7LFJlK7MmJayJoeFR/vkkgkud4lth4BGs3lbE0g=;
        b=hPuulVPnOr+Ng+vU3KMWGncy1qkRcCiQFDCZ9lGnzL3fEBjvwhPhhubd9WLx1ixRHp
         llL8Sy27inEk9+/jRrnOGAtOR/cUh4v1KDOg4D4Zab4nyUEoKNmsAyPERQu0UByrEhUq
         UHgtlAr2IIantLd1jskU6Auue1yQVMe9hQUvTxMZaob+4DhwIGJ2ppC9aVfI3LJJ0lDB
         nXvwQ5PlQE4QnpDvh3za6nqsZJpQU7t4Giv01xvbK1N8NaGzXGFmet/5+0cu35vf4y5e
         ZeMm9sP4KAq3foezRCksd66BvUBbBGYhvE9wmLWXZXU3asmOMb/CsRI9GSpCLhJBmQvP
         2QPQ==
X-Gm-Message-State: APjAAAWCjRHO4CNZZ3pLtvUN9+fb1LxBr51xBErrZGOohjaRc/gKfsfc
	Bly7JTeiYeyOYA60It3VN3P9JVkmO9LHUUdxlMztUIYKp3kBV0dGNod/tycsD+NYEjo0ZNAT52e
	XLgEiLRcgwCWpwiVZDSO6v5aOQIK8et57ZA69s0LezQyhVy1armjdhnsKopzTLDJlMA==
X-Received: by 2002:a17:90a:d983:: with SMTP id d3mr5133884pjv.88.1565127309074;
        Tue, 06 Aug 2019 14:35:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHdrgUmmJVEjJ1yTqs3+33XY/rnoVcQSJ4XbGSmErHLtt9KhjFtf4JppIjbX7EP56Xwr0B
X-Received: by 2002:a17:90a:d983:: with SMTP id d3mr5133822pjv.88.1565127308096;
        Tue, 06 Aug 2019 14:35:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565127308; cv=none;
        d=google.com; s=arc-20160816;
        b=vWc/TlqPOG6n17kUnR6OF/3wsDopdTDRSHcOGaB1f0y+j3xUIsZPR8N6yvUwsOxrHt
         GwodR6isO44T2Xu1K7kaxGtsPO0JGOcS/EKax/m2DBasl0BLIH2v5IwGcmSNCbTBTI8Y
         NzSvUemJe5B2aduO9DieFN1QAP8WY3SuQRpKzpdt1mZhjEi2KmexUJ32gLBDy2GsBWwm
         8vquzHjH/6dQxBcK/+Dqgx0l91WMz+DVmmTsZ7GaRooTWe833441x8IkzATi7il5sfjh
         DMZuCZuRT4520v3iQb7CFYG0dTG7KTYnOXxxrrXd5o0saoGwXwKidNIqqFt+LiL56VQ0
         082w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=jokA7LFJlK7MmJayJoeFR/vkkgkud4lth4BGs3lbE0g=;
        b=Z5IZlQG2lrh7lj7eb+i4F0No07UnvoyDh+o1nrUFcyRlD8sXlSKl1ea/eVNqgnjjXx
         niIS33Ux6f089qQRsvfoRyrwXf4ZNwRKD2EUWWXbmKp6XF88iU1Zcpk1LnBR/A5DSBel
         bjTQlAhItBjE0t2Q4E9upNoae/Z8k/7gEKSUh6IfUJxIJpXT0cT2CoFTzFQDnuUK+R9e
         AwLmGMh7RzVvmyHmh1izKh1nDM6mFWw6KkhFyQUTaJ5Rb/UQxCbh/4GA8FnxDgd0ZuAZ
         4yBm86adIWZcY8hO0PiFLtbrutRxXo/Ky75kIGemUhUM3xRe+bslwJZ9hF7uKUpFeGb1
         ZIIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=JOEECtgZ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d6si16109532pjc.7.2019.08.06.14.35.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 14:35:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=JOEECtgZ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8492E2089E;
	Tue,  6 Aug 2019 21:35:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565127307;
	bh=RJ/mBnQ9yApPExC7G9QkBrupCdlJeI8/8KL7fi+0rj8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=JOEECtgZbf89hAtxVEUkrgEIwEAgwWO8mT1nCBMPJpN7f+hFIAzoz6G4Cv1aobdBF
	 +yjYI9YhZzb8HZuyTO6Zj6CLIkhikJsufSFkEwGqB80aE6wBhUQ6e/C6+VDPftjiPF
	 xwfodfYyKN3Czg73YaRAQ6528VOCIaYCoAcI8Fyo=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Yang Shi <yang.shi@linux.alibaba.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Michal Hocko <mhocko@suse.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	David Rientjes <rientjes@google.com>,
	Matthew Wilcox <willy@infradead.org>,
	Qian Cai <cai@lca.pw>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.2 54/59] Revert "kmemleak: allow to coexist with fault injection"
Date: Tue,  6 Aug 2019 17:33:14 -0400
Message-Id: <20190806213319.19203-54-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190806213319.19203-1-sashal@kernel.org>
References: <20190806213319.19203-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yang Shi <yang.shi@linux.alibaba.com>

[ Upstream commit df9576def004d2cd5beedc00cb6e8901427634b9 ]

When running ltp's oom test with kmemleak enabled, the below warning was
triggerred since kernel detects __GFP_NOFAIL & ~__GFP_DIRECT_RECLAIM is
passed in:

  WARNING: CPU: 105 PID: 2138 at mm/page_alloc.c:4608 __alloc_pages_nodemask+0x1c31/0x1d50
  Modules linked in: loop dax_pmem dax_pmem_core ip_tables x_tables xfs virtio_net net_failover virtio_blk failover ata_generic virtio_pci virtio_ring virtio libata
  CPU: 105 PID: 2138 Comm: oom01 Not tainted 5.2.0-next-20190710+ #7
  Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.10.2-0-g5f4c7b1-prebuilt.qemu-project.org 04/01/2014
  RIP: 0010:__alloc_pages_nodemask+0x1c31/0x1d50
  ...
   kmemleak_alloc+0x4e/0xb0
   kmem_cache_alloc+0x2a7/0x3e0
   mempool_alloc_slab+0x2d/0x40
   mempool_alloc+0x118/0x2b0
   bio_alloc_bioset+0x19d/0x350
   get_swap_bio+0x80/0x230
   __swap_writepage+0x5ff/0xb20

The mempool_alloc_slab() clears __GFP_DIRECT_RECLAIM, however kmemleak
has __GFP_NOFAIL set all the time due to d9570ee3bd1d4f2 ("kmemleak:
allow to coexist with fault injection").  But, it doesn't make any sense
to have __GFP_NOFAIL and ~__GFP_DIRECT_RECLAIM specified at the same
time.

According to the discussion on the mailing list, the commit should be
reverted for short term solution.  Catalin Marinas would follow up with
a better solution for longer term.

The failure rate of kmemleak metadata allocation may increase in some
circumstances, but this should be expected side effect.

Link: http://lkml.kernel.org/r/1563299431-111710-1-git-send-email-yang.shi@linux.alibaba.com
Fixes: d9570ee3bd1d4f2 ("kmemleak: allow to coexist with fault injection")
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
Suggested-by: Catalin Marinas <catalin.marinas@arm.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Qian Cai <cai@lca.pw>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/kmemleak.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 3e147ea831826..3afb01bce736a 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -114,7 +114,7 @@
 /* GFP bitmask for kmemleak internal allocations */
 #define gfp_kmemleak_mask(gfp)	(((gfp) & (GFP_KERNEL | GFP_ATOMIC)) | \
 				 __GFP_NORETRY | __GFP_NOMEMALLOC | \
-				 __GFP_NOWARN | __GFP_NOFAIL)
+				 __GFP_NOWARN)
 
 /* scanning area inside a memory block */
 struct kmemleak_scan_area {
-- 
2.20.1

