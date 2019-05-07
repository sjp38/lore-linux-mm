Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 039B9C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:35:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B78B720989
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:35:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="iTyCt+hh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B78B720989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60E536B000E; Tue,  7 May 2019 01:35:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F0456B0010; Tue,  7 May 2019 01:35:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D3796B0266; Tue,  7 May 2019 01:35:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 196546B000E
	for <linux-mm@kvack.org>; Tue,  7 May 2019 01:35:42 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id n3so9520287pff.4
        for <linux-mm@kvack.org>; Mon, 06 May 2019 22:35:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fLTouJqe2+t1nkUs6x9/SDbzHch/kZom1Bk6vNsE7sY=;
        b=PrN/hL98oh0gUPZ5KzkMQwrks0MUgAc/Jt0DNs3X/ic1eK9h3d0XQ981QYmibkixZw
         /1cJtEs6o8bi0KU4n0BCkD8l270iOFBS2s7TRdNBjEpXkNojo1qX19L+bkrv96CERvSH
         09AtHo/Oa4O206p3rjVq2qsFlZRyU6Isw5190ZMicZrmUaW6nmFiO9ZCBVW4lV2wawZ4
         qcebbJe8/2tZ6hI6oCHqlVTIqUdPgmp0PFPdbSMhSvx1M81eIkJGjhwL9QMdLfkJQ0lZ
         gzxtcntOa4tO2JwbebcAXOUoIlaQkd4PiDJHjztXs27dU1J65mZSBmRh3SVIO21Ye3oP
         avhw==
X-Gm-Message-State: APjAAAX0dhpQ6mCuiFYz/vxh6/UM5FJ+PiLgV8P52GLTxbOtBU59SDmR
	GSCm5oUHQ4vfkcQ6a5DHl139kG62ZFR5LhNWJMM3IeTgdCrrAVin3OI24wYnwtnnzZWViyFNNCc
	JvFliRcUjDl4T4Bw9EXBxX/2rMTkpyg4KTEEEzpr9PhwIXF9SwC/dYFvySFz5krMYRA==
X-Received: by 2002:a63:8a4a:: with SMTP id y71mr37729818pgd.270.1557207341774;
        Mon, 06 May 2019 22:35:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxju2Lh9dacT7N8FVL2VJKbDgyR/k9yM44SA6jodSb3RexkfufH1jbZbOkU+KEV+VyAKtop
X-Received: by 2002:a63:8a4a:: with SMTP id y71mr37729760pgd.270.1557207341121;
        Mon, 06 May 2019 22:35:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557207341; cv=none;
        d=google.com; s=arc-20160816;
        b=cVckSZf3gp3S2rh3oqA7wN3GKrOdfBNySTjcym1Jszn5GaFqatJ8f1/sJXAXIa7oo+
         3anTgyJCOTVa5ZzGWU4qhsGaH+f/yE27Kv6XAnfxwzwKN0sGENNCAQA7xKBAOovg6uqu
         URLitZkIjEuxGb+KGljjfvyfDldLJPQNeo2ecl1RyyShcjGtTG6VasAAdvAtBqE/qlWo
         A3Hzi9P3CUoswDrY2cOF4Wr6WxhLFtFXAwwTgP6gmw3/y4IFELoaEFDuDJ5afpJUTAvb
         UtSbVzxWUrLIfE1hzlW6I8MADgY23wZ4F8jZVRxDlodOAAgWCZWl804kCeN/J8AzXEHl
         SOsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=fLTouJqe2+t1nkUs6x9/SDbzHch/kZom1Bk6vNsE7sY=;
        b=dMyzMQG6YDJyYPnwZyrEhPhwRf1y4oNRF4Alefs6Mdl9cEpFDgNiisHjLkOHs6WRjk
         NiBYWwzPzcCDjevzOlSY6s3yJJN1lJd8zWxL9DzVe/ofCZMW9xlXSoWjQs7K2U5U49UH
         n8mlcfOxH7Y8RkXCcyxDkKrxJFCGBtlpCKsd1l8IZsMBj2uO4HlYaPxD05CbJCnPxbJ/
         1SLn5mnKvROuJYT+aZxtW0Sw/a+++uKqUV6MN8e/C/r2K2TjShndraeoBmp24kMoNdP1
         QUvaxJqIFp5ColzY2O1mcZ1485PDuH+vUt5QPcN1xAUUkRUA+9BJ4c7cV27hOLMNjhM7
         ev7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=iTyCt+hh;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 17si19741836pfw.148.2019.05.06.22.35.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 22:35:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=iTyCt+hh;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E85EB2087F;
	Tue,  7 May 2019 05:35:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557207340;
	bh=BS8bQZGoB7uxBqsmLwt1/UFGaXwyTwZEytlGNIEdKnU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=iTyCt+hhs6WDmtMI27GEtirrF94M2dzJBG21bV7pKRoMyZwvzfdt0IrdEKf7521xO
	 LsWbUzjZ/+5pBbKmUYxrzFTErGpOfV5rvoDAtwpz+74akzA+kQa2pTXPy/IJFpOH9J
	 MdZtf/xco6k/fMksoHQil6jQtOxk9plagM56F9Tg=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 95/99] mm/page_alloc.c: avoid potential NULL pointer dereference
Date: Tue,  7 May 2019 01:32:29 -0400
Message-Id: <20190507053235.29900-95-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190507053235.29900-1-sashal@kernel.org>
References: <20190507053235.29900-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrey Ryabinin <aryabinin@virtuozzo.com>

[ Upstream commit 8139ad043d632c0e9e12d760068a7a8e91659aa1 ]

ac.preferred_zoneref->zone passed to alloc_flags_nofragment() can be NULL.
'zone' pointer unconditionally derefernced in alloc_flags_nofragment().
Bail out on NULL zone to avoid potential crash.  Currently we don't see
any crashes only because alloc_flags_nofragment() has another bug which
allows compiler to optimize away all accesses to 'zone'.

Link: http://lkml.kernel.org/r/20190423120806.3503-1-aryabinin@virtuozzo.com
Fixes: 6bb154504f8b ("mm, page_alloc: spread allocations across zones before introducing fragmentation")
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/page_alloc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index eedb57f9b40b..d59be95ba45c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3385,6 +3385,9 @@ alloc_flags_nofragment(struct zone *zone, gfp_t gfp_mask)
 		alloc_flags |= ALLOC_KSWAPD;
 
 #ifdef CONFIG_ZONE_DMA32
+	if (!zone)
+		return alloc_flags;
+
 	if (zone_idx(zone) != ZONE_NORMAL)
 		goto out;
 
-- 
2.20.1

