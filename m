Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E07EC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 06:08:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AEAB520830
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 06:08:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eygfbDeU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEAB520830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22FCB6B0003; Wed, 20 Mar 2019 02:08:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DEFF6B0006; Wed, 20 Mar 2019 02:08:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CD9E6B0007; Wed, 20 Mar 2019 02:08:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE9026B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 02:08:50 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id p127so1637980pga.20
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 23:08:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=NeLnaQy2JXvCqMZeoRJcNJrR7ttFYPoxWQX2uzdExW4=;
        b=XU59eznf2tOiwnEGcpt7Pl06E8vzbvfgoNCwR1xGi4puwmNH/F20RahMldqhLYdp0Y
         xOAvDLOvMCCtwf981R7vi7vDivfHNOILWTMh4yho1Q+cVtflrCpC/wYN5xihfECHRb0O
         rnbBIraekX4JI4ZBCgEUVBf6sc69WHfqeCkp4+ZxDSBk7IJKCbXqrLOISYabOzitnNt+
         haixeK5d5I8LARJDue42NrGeR64VU5mthFMuq5Lv0ULesTrb4LW7Nmpn/TRJ4P9lrv6M
         mDeQ0pkPFFcBCrPvYU8R+mMPwmAk2STuRwKmd5TMBYqxiFnmf+LbF7RNI/zv8RRFaNv6
         uvsA==
X-Gm-Message-State: APjAAAXJTm4kuAzyTvUAfGpGsZHbz3yb2PO1i2rbmxxWD27OgfaqF6h2
	fLRP8MjT147oo3L0mvnGT2kqAXKTIQOH+k6tom6/xjH7f0/OmghDvyqPchexUGASS/iMWjRnxCj
	t3wHc8hnBLWUiNRxuBh0duhLQyH8V64MZw2yrOoIGXC8qhKYYepEGnFM+/8i+HuNXaQ==
X-Received: by 2002:a63:b242:: with SMTP id t2mr5711632pgo.451.1553062130210;
        Tue, 19 Mar 2019 23:08:50 -0700 (PDT)
X-Received: by 2002:a63:b242:: with SMTP id t2mr5711545pgo.451.1553062128922;
        Tue, 19 Mar 2019 23:08:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553062128; cv=none;
        d=google.com; s=arc-20160816;
        b=Vi5IIsZQcQhoQTJt8FvXbaay1y2diVEK+wtngOrOvy/4JBhALw11uGd+uFh1a/Hc5y
         hRNabh4MHFbSMkvhxgJsBx2pSTOcWvVEnS5VnjoeFtexblQaAfXQ5nFBeLEsuDuHekw+
         MPCwV1m6yHM1SLbcYCFe6T61mGyND4dDSRTZkWECRFfHZxTYH3ZLu7CRMAtg+UFKO9au
         WnBETAhU0PCuH/8XzdqybhF8ZzyIPj2ORLPymsU5XCOL5c1PDjGZohtoPtufMXqYFhcG
         eW5kwlChKn0CqL2iprcG+IRUJeBGKsPNVrJkyZ7STV7fJ74gfQRiDAxInMZgWmxGGrV0
         sKsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=NeLnaQy2JXvCqMZeoRJcNJrR7ttFYPoxWQX2uzdExW4=;
        b=zty1003HxetUdem/br4pIcoTwTN88zkCSB2sjVxwCKOXU9kj1Bma4Ca8v982eJ2kl1
         SX9dDP/Ch7biGAPtZd5o2VR8dzkJ15MEbx5hJXge9bqA+04Lx+/CxwuTC3AB9vJ2O1u8
         GXAN2zAn5sH03K/PuaFmlEgOcl7W+BwBgzKo1J1r6IPecfqX/RFTjwKo6QkRmy/BN03b
         rNYDAtL23mYwsCdwS6m0+P1/MIqNPbqwnQdfiOMIaH0sQa73T6SLuAimy9GImCcdofh7
         dygtFb6wuOIhbXVc7wIZ7mfuPbTwx8bOp5eSaQyLKlmk65Al24E6W+mNOucIRqowU+uu
         +//Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eygfbDeU;
       spf=pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zbestahu@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o19sor929647pfa.65.2019.03.19.23.08.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 23:08:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eygfbDeU;
       spf=pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zbestahu@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=NeLnaQy2JXvCqMZeoRJcNJrR7ttFYPoxWQX2uzdExW4=;
        b=eygfbDeUqjrVv93ZqpsbFLv5H0WAw5ab5CSFC7satP+JzsSPngeEplvd0xt/n45Lhe
         A/9j/V0u5oIOZXshtdvNF4/1/cNGYOng4To1CobxnQysXkNBOlhi2syU2O7Z0Sm2gveB
         kPS5Rm+9dSnBBYP1Jsbj6rTlEGGpUxdFdLDHRePXiekWAzfEeLKRCaH2g8tDQPt5rbYC
         M2qofZpZGhihAZR4k/hc1Hi+K2B1DtmvvA2mXnEtiWVPxBIZp56nqqYzX1ai0OIxO5dg
         owbYCpGikaVfP8LoAM1EiXy3zm5tZUug6oK1VJjGe1hLuaNldoAhduC8iQ/LOAYX67Rz
         u/eA==
X-Google-Smtp-Source: APXvYqyK2CZlv053DCsaW8OksVtrufjjLQDzme1i1iZALAmVJkyBIlX7c210R99n7nCj7ZQOaeXniw==
X-Received: by 2002:a62:6f06:: with SMTP id k6mr5959747pfc.257.1553062128515;
        Tue, 19 Mar 2019 23:08:48 -0700 (PDT)
Received: from huyue2.ccdomain.com ([218.189.10.173])
        by smtp.gmail.com with ESMTPSA id j24sm946371pgl.58.2019.03.19.23.08.45
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 23:08:47 -0700 (PDT)
From: Yue Hu <zbestahu@gmail.com>
To: akpm@linux-foundation.org,
	iamjoonsoo.kim@lge.com,
	mingo@kernel.org,
	vbabka@suse.cz,
	rppt@linux.vnet.ibm.com,
	rdunlap@infradead.org
Cc: linux-mm@kvack.org,
	huyue2@yulong.com
Subject: [PATCH] mm/cma: fix the bitmap status to show failed allocation reason
Date: Wed, 20 Mar 2019 14:08:29 +0800
Message-Id: <20190320060829.9144-1-zbestahu@gmail.com>
X-Mailer: git-send-email 2.17.1.windows.2
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yue Hu <huyue2@yulong.com>

Currently one bit in cma bitmap represents number of pages rather than
one page, cma->count means cma size in pages. So to find available pages
via find_next_zero_bit()/find_next_bit() we should use cma size not in
pages but in bits although current free pages number is correct due to
zero value of order_per_bit. Once order_per_bit is changed the bitmap
status will be incorrect.

Signed-off-by: Yue Hu <huyue2@yulong.com>
---
 mm/cma.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/mm/cma.c b/mm/cma.c
index 5809bbe..6a7aa05 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -367,23 +367,26 @@ int __init cma_declare_contiguous(phys_addr_t base,
 #ifdef CONFIG_CMA_DEBUG
 static void cma_debug_show_areas(struct cma *cma)
 {
-	unsigned long next_zero_bit, next_set_bit;
+	unsigned long next_zero_bit, next_set_bit, nr_zero;
 	unsigned long start = 0;
-	unsigned int nr_zero, nr_total = 0;
+	unsigned long nr_part, nr_total = 0;
+	unsigned long nbits = cma_bitmap_maxno(cma);
 
 	mutex_lock(&cma->lock);
 	pr_info("number of available pages: ");
 	for (;;) {
-		next_zero_bit = find_next_zero_bit(cma->bitmap, cma->count, start);
-		if (next_zero_bit >= cma->count)
+		next_zero_bit = find_next_zero_bit(cma->bitmap, nbits, start);
+		if (next_zero_bit >= nbits)
 			break;
-		next_set_bit = find_next_bit(cma->bitmap, cma->count, next_zero_bit);
+		next_set_bit = find_next_bit(cma->bitmap, nbits, next_zero_bit);
 		nr_zero = next_set_bit - next_zero_bit;
-		pr_cont("%s%u@%lu", nr_total ? "+" : "", nr_zero, next_zero_bit);
-		nr_total += nr_zero;
+		nr_part = nr_zero << cma->order_per_bit;
+		pr_cont("%s%lu@%lu", nr_total ? "+" : "", nr_part,
+			next_zero_bit);
+		nr_total += nr_part;
 		start = next_zero_bit + nr_zero;
 	}
-	pr_cont("=> %u free of %lu total pages\n", nr_total, cma->count);
+	pr_cont("=> %lu free of %lu total pages\n", nr_total, cma->count);
 	mutex_unlock(&cma->lock);
 }
 #else
-- 
1.9.1

