Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AB13C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 17:28:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E83321841
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 17:28:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Ty928puG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E83321841
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F8FF6B0007; Wed, 20 Mar 2019 13:28:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A9416B0008; Wed, 20 Mar 2019 13:28:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8990E6B000A; Wed, 20 Mar 2019 13:28:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6515B6B0007
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 13:28:15 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x12so3201567qtk.2
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:28:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=tSWuSdEcPYnHEfL0STXoy4MtzUjvAM2sSMLxODD5rr4=;
        b=FyTZBX66ZASkm8AEuG6NKuuWjtsUmEEFnETbjJFMmtvHQu8HURbblwMdiJSZIcNczb
         c/3yNG/X8MoSPtZANO2tzPs3avjSCZ3VYZWKKuUmgSBAN0fzskTnlIO5Q5XAzvKx8I3G
         LZ0Wr/3idZItQpbPgsZZNAzqPTSxs3jN0SMOj0aeyBtvqFzFuqrD4y/mbH8FWRhBv7Fa
         160QolESEcLDdfYbUuh1wQXZ4BELJgnh932PZrPxvnQ5TglLM+WzAexKRt/QsTdOMuhk
         W0tDy8XPuO4cBCienVpIZP1WXV+tYE35YnU6ddUrSa+U0N5eIPfRWC5bn4yAIq9ar5gR
         ALZQ==
X-Gm-Message-State: APjAAAXOCcvyothK8P3ksvOiF4GLdp7ZbILxqNK+yWc0vZtWB/bmSn2W
	VM14RBMy3wcXSNg7aCX1WMh+Klzp/J0ATIRzhAMKCeUDTWKHFdS5mppS4kxwjTpgZEqday5RoWu
	LI2c4z1Rrdi9RpkC7dongb5Q7ZdsuBHB5tl6W3LCP3dlRc3CVJWIIHIFxnuy7e2sBdQ==
X-Received: by 2002:a37:c384:: with SMTP id r4mr7339252qkl.306.1553102895117;
        Wed, 20 Mar 2019 10:28:15 -0700 (PDT)
X-Received: by 2002:a37:c384:: with SMTP id r4mr7339212qkl.306.1553102894362;
        Wed, 20 Mar 2019 10:28:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553102894; cv=none;
        d=google.com; s=arc-20160816;
        b=UyD0epHZAPQPwnW2F70qEd8JDaKDtrJg+N+tuEktR7R0h2i/5rTi9rbZo6YePAytBt
         9xHQQ4yFihnrY2s7niXD6/jj63rZGTDr8V2VCKDwCIlyoMNpsBvTegAYEY+IEewDO6Zh
         JvIP6myYaPi2Cd8UUChogkENaKyCPK4+dZoMuO+VqrMcAYXc5zBsJhtIF0gXrvIO9+EW
         BMBS/KClWcZnkmQlANoHEBiOe5oDngo/EZB7ZZLchE0xAck1cCV6IXRj39kaTD6cavSs
         zORRgXNRZsgW0/Uey2+swQwnebBpN+IZoGbbAZVmkJ7ds/VYrl4/6Tu753cOORql/4aB
         XTJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=tSWuSdEcPYnHEfL0STXoy4MtzUjvAM2sSMLxODD5rr4=;
        b=ph2E8X/nJB0X//5qnXXPUqj3JLyM7y5Cz81gzZ9svgFwHGjDildlLNL6/BZNEo3bVz
         kJ30haaq5Ta2ijQe5MnhD7ixsI2QW5KbDhWCq3Nk6OwSiSDTEaCRhjAoYPcxo2Fttzyl
         lUNDM5hSageavRDj4HihNtMHlu/RTl7A2ce17s0sif9hv5RTslSPXtSzl5r2Bdjfjh2p
         mTvS/WPhu9xOH24DV5mWO5zGZqdK+WmIiBI7qqjoN9PNWFQmN0b0KecOvjMblZx7maEb
         uqiitsCyt1mG7Ys3W5+e3c6jUUUC9IzdZBv2Ba4BwkhP6010jo0t6mlKXhRdiqFGlsbq
         lC4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Ty928puG;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t14sor2062170qki.69.2019.03.20.10.28.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 10:28:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Ty928puG;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=tSWuSdEcPYnHEfL0STXoy4MtzUjvAM2sSMLxODD5rr4=;
        b=Ty928puG0UE0fSO6SynDB4Fhl8Euko9ZNiFE5tZwWj6E351Z380XM6ZjlnTP/pvLHw
         /6XrcBKqvWxbQZ8YAka/vwBF1gfAUxrUO2jr2bSO2IANkjd51hlZt6jPOMOB/Sbl+eP2
         Xma+BCYo+vsrOzxK5jTSEE1HPtQ1VUquZJbMpu4ZJNEUlRVujl/aFWuYLOCf8rgx7lHG
         g5qAVfljauvNsd6mhBgtTcXBwOSv9tAJXzmiDUGgX7PuA4jsXIrjtfJtrtZVCgc8SmEq
         KE08m/Vo6MLvrXtunm7SExLxA+fRWRhs9YimaOfGbp6Zt4lAZBUFxBQqadT5aVHnNQMK
         J9tw==
X-Google-Smtp-Source: APXvYqzheRklgsnMnTk39gR30DOhmUawStPG7DBb0YaR6Dg6rFjs7Gthgo8LLCFuzhjs7G5S/2dM3Q==
X-Received: by 2002:a37:b386:: with SMTP id c128mr7311385qkf.330.1553102894068;
        Wed, 20 Mar 2019 10:28:14 -0700 (PDT)
Received: from ovpn-120-94.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id f189sm1447324qkb.79.2019.03.20.10.28.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 10:28:13 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mgorman@techsingularity.net,
	daniel.m.jordan@oracle.com,
	mikhail.v.gavrilov@gmail.com,
	vbabka@suse.cz,
	pasha.tatashin@soleen.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] mm/compaction: abort search if isolation fails
Date: Wed, 20 Mar 2019 13:27:52 -0400
Message-Id: <20190320172752.51406-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Running LTP oom01 in a tight loop or memory stress testing put the
system in a low-memory situation could triggers random memory
corruption like page flag corruption below due to in
fast_isolate_freepages(), if isolation fails, next_search_order() does
not abort the search immediately could lead to improper accesses.

UBSAN: Undefined behaviour in ./include/linux/mm.h:1195:50
index 7 is out of range for type 'zone [5]'
Call Trace:
 dump_stack+0x62/0x9a
 ubsan_epilogue+0xd/0x7f
 __ubsan_handle_out_of_bounds+0x14d/0x192
 __isolate_free_page+0x52c/0x600
 compaction_alloc+0x886/0x25f0
 unmap_and_move+0x37/0x1e70
 migrate_pages+0x2ca/0xb20
 compact_zone+0x19cb/0x3620
 kcompactd_do_work+0x2df/0x680
 kcompactd+0x1d8/0x6c0
 kthread+0x32c/0x3f0
 ret_from_fork+0x35/0x40
------------[ cut here ]------------
kernel BUG at mm/page_alloc.c:3124!
invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
RIP: 0010:__isolate_free_page+0x464/0x600
RSP: 0000:ffff888b9e1af848 EFLAGS: 00010007
RAX: 0000000030000000 RBX: ffff888c39fcf0f8 RCX: 0000000000000000
RDX: 1ffff111873f9e25 RSI: 0000000000000004 RDI: ffffed1173c35ef6
RBP: ffff888b9e1af898 R08: fffffbfff4fc2461 R09: fffffbfff4fc2460
R10: fffffbfff4fc2460 R11: ffffffffa7e12303 R12: 0000000000000008
R13: dffffc0000000000 R14: 0000000000000000 R15: 0000000000000007
FS:  0000000000000000(0000) GS:ffff888ba8e80000(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fc7abc00000 CR3: 0000000752416004 CR4: 00000000001606a0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
 compaction_alloc+0x886/0x25f0
 unmap_and_move+0x37/0x1e70
 migrate_pages+0x2ca/0xb20
 compact_zone+0x19cb/0x3620
 kcompactd_do_work+0x2df/0x680
 kcompactd+0x1d8/0x6c0
 kthread+0x32c/0x3f0
 ret_from_fork+0x35/0x40

Fixes: dbe2d4e4f12e ("mm, compaction: round-robin the order while searching the free lists for a target")
Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/compaction.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index 6aebf1eb8d98..41cec13c4c9c 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1245,6 +1245,10 @@ fast_isolate_around(struct compact_control *cc, unsigned long pfn, unsigned long
 /* Search orders in round-robin fashion */
 static int next_search_order(struct compact_control *cc, int order)
 {
+	/* If isolation fails, abort the search. */
+	if (order == -1)
+		return -1;
+
 	order--;
 	if (order < 0)
 		order = cc->order - 1;
-- 
2.17.2 (Apple Git-113)

