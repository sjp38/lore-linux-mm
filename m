Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 303B9C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 20:33:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0A0F2190A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 20:33:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="sUDzCgc3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0A0F2190A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0439A6B0003; Wed, 20 Mar 2019 16:33:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F35456B0006; Wed, 20 Mar 2019 16:33:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E22C76B0007; Wed, 20 Mar 2019 16:33:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id C04806B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 16:33:53 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id r9so22219117qkl.4
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 13:33:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=AaIGgQ6l0pg6MA+6fDH4Ohm3I1c+gTXhunmzDnC08GQ=;
        b=R33sGuqIUN7NnKyxM2hVceelBfBhQFhsLoYci7cy26oYdom22GYhQkTwyBBtlDPQIA
         qffmv26wGFwD/GQByHroS68FYjUWOKCECRry/fERyTltgnO0ERYe0tl6VedOVptLuR3N
         vOrbnMEQCjICtBOC1JlZ1KnII6IN8GxEpAFAXgKenCGcFpPVubPirDbbjiHSk95zUOtT
         xMWgs20eKvo7IPwDUXJZflk8Olf1O2zAB51rSKTXTUpdBLy7810AhdJLhlqnvQsvV964
         JCgH1uVykhdJFQqZZQOdx6vRU5IpRQi2VngEJQfsFAuC/RKU0RjK3DBRKl1QIDBdcStX
         gPMQ==
X-Gm-Message-State: APjAAAVlYU09XSKJeWh/aX2+MYvhONEeB5ZoM1io/cFh1klIgznRG3zJ
	PRcHdNP1Cr6Ap5vtihLUI+wYCbRJu8f35QlnKqPGX4sj1C8CBgpTkuvWqKYPRuwAAZVKmTOl73O
	rGHa7ACLOy6QGEoZyPwr0437s1D/rv46lqBlIAVN1mQdXtDvv8B/tkhYDXiHe9rXdqQ==
X-Received: by 2002:a37:9e0d:: with SMTP id h13mr8247376qke.135.1553114033487;
        Wed, 20 Mar 2019 13:33:53 -0700 (PDT)
X-Received: by 2002:a37:9e0d:: with SMTP id h13mr8247309qke.135.1553114032308;
        Wed, 20 Mar 2019 13:33:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553114032; cv=none;
        d=google.com; s=arc-20160816;
        b=O30swSaykdW6ph4/j8tO0nqZR2mGY72VnjtCz6oy21fkFiFborsw6BKYTzCkyg/2OR
         yEwc/iyk8sGaK6xdtOkaMwn1DVOkwKjYELO1wmeXJw7IZX3des9qAOsuqtM4AkCiMmJT
         EYOgIhvuilknx8YZU5AZQPobuLep0FGl3ADpUBBFk8cVkOlXeRUXRO2RfpcXPT0X5Z2U
         Gk1hHxMBTgrOU1ukkhBaI4YHnPcZnw+LEtFAyNvaDkWHZ9bKBT1zMzL837agBVLzpdkC
         vqDdzz4loVpuVtTnCn9yezrGxEVq5LPqMlTqmdykAdZbQXB7GC54fPRg5eDEr08hlOxl
         inaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=AaIGgQ6l0pg6MA+6fDH4Ohm3I1c+gTXhunmzDnC08GQ=;
        b=K9vuRfYfYRjBXbK16HWeAblBoq4HIeHrzneR21JkYeu5QBew3ZzSJjCdHWHvH3ie5p
         hgkbYHCCn/da17xmWFxuNo1Lq2NwmWTylzzY4mbmUprt2+UxP0h0z+2/1wyAkEVdy4L0
         /Xo+SRxrlb22PTu3u17hb2mKCC3AlrAcM+JssyrEbNJinKjO2v6wUKUE4sYEWTugocKx
         9cU6/PBXRuMFx3CoZbZUdzIfOWZxdWBxRAFU/qVWo5dFemT4FsIzmRQGCrrBt+1UxkUZ
         zXHwuxmkRgvBRR7oKdTI2L6YvhBmQ8fy34qVCbY/ZZXoMOBK5mN+EOIG0CnkOsTNKRLN
         gtDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=sUDzCgc3;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 192sor550120qkh.23.2019.03.20.13.33.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 13:33:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=sUDzCgc3;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=AaIGgQ6l0pg6MA+6fDH4Ohm3I1c+gTXhunmzDnC08GQ=;
        b=sUDzCgc3g92zkPjp5gZaZsgMuUoKcHlZ+BerWXrs4Tun7VHg2liJUyZdDUJnbmPsJQ
         06U3Vj8H93WY78f9zi2h/VUxscRkk4oLad5dy+D8J1hLUd+fZ7oAE0yOl8b2XZwNZ0Hh
         da7o6hPLVxFtra69mx1b+/EV9/xHT4o+aPVc0hErHbvEVZ8mtcz9F3EyhvfMe0KdyGNI
         C/udn1N+uX0H4h1uvJtmzC288wB5Vh/QeU6jMwUxIPE1I9LnoXq91oYwZx2FMe9TdVC6
         BXQ1a0eIT8rLU9+rwzKkaHGxFyER9BapoVuK3NwHVJQdeoVYqAE4kwDAfkz5N4K32750
         2PVQ==
X-Google-Smtp-Source: APXvYqy4ygr9/xFHWmOkEa7gumgHQNm9Ra0ihtvJ5bWpOtSJ5zM6W8U9kmJykElEjNpBdlRfZ/KMog==
X-Received: by 2002:a37:5d06:: with SMTP id r6mr8206494qkb.148.1553114031984;
        Wed, 20 Mar 2019 13:33:51 -0700 (PDT)
Received: from ovpn-120-94.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id t12sm2094634qkl.58.2019.03.20.13.33.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 13:33:50 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mgorman@techsingularity.net,
	vbabka@suse.cz,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [RESEND#2 PATCH] mm/compaction: fix an undefined behaviour
Date: Wed, 20 Mar 2019 16:33:38 -0400
Message-Id: <20190320203338.53367-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In a low-memory situation, cc->fast_search_fail can keep increasing as
it is unable to find an available page to isolate in
fast_isolate_freepages(). As the result, it could trigger an error
below, so just compare with the maximum bits can be shifted first.

UBSAN: Undefined behaviour in mm/compaction.c:1160:30
shift exponent 64 is too large for 64-bit type 'unsigned long'
CPU: 131 PID: 1308 Comm: kcompactd1 Kdump: loaded Tainted: G
W    L    5.0.0+ #17
Call trace:
 dump_backtrace+0x0/0x450
 show_stack+0x20/0x2c
 dump_stack+0xc8/0x14c
 __ubsan_handle_shift_out_of_bounds+0x7e8/0x8c4
 compaction_alloc+0x2344/0x2484
 unmap_and_move+0xdc/0x1dbc
 migrate_pages+0x274/0x1310
 compact_zone+0x26ec/0x43bc
 kcompactd+0x15b8/0x1a24
 kthread+0x374/0x390
 ret_from_fork+0x10/0x18

Fixes: 70b44595eafe ("mm, compaction: use free lists to quickly locate a migration source")
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/compaction.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index e1a08fc92353..0d1156578114 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1157,7 +1157,9 @@ static bool suitable_migration_target(struct compact_control *cc,
 static inline unsigned int
 freelist_scan_limit(struct compact_control *cc)
 {
-	return (COMPACT_CLUSTER_MAX >> cc->fast_search_fail) + 1;
+	return (COMPACT_CLUSTER_MAX >>
+		min((unsigned short)(BITS_PER_LONG - 1), cc->fast_search_fail))
+		+ 1;
 }
 
 /*
-- 
2.17.2 (Apple Git-113)

