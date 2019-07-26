Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B6D4C76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:45:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D81A122CF8
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:45:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="a4XUxIEJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D81A122CF8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 762F58E0002; Fri, 26 Jul 2019 09:45:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 713E76B000A; Fri, 26 Jul 2019 09:45:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 603B48E0002; Fri, 26 Jul 2019 09:45:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B3A2F6B0006
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 09:45:56 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 191so33220189pfy.20
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 06:45:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nAo9QA+oZvetyJFoBlgdakWF8aacOpq1iJJqhJoRCrk=;
        b=Lc21E/tdENAmUINzMJaNzK7AbliDkAWzd1AMg1FcD0wmZ07IyvXI0p2OTVUk5z4A26
         zxp64YIkpZ1NRBOtTRvUqipyRZt/qk4vc6KyTCEWQ9IW0VbOLUPKSlFcZKfBAJ4flUNd
         w3/1hxWzZzSoMRMJpwrGyO4U4qvwnSBbIVpb4m2udicE7XLmo+ghV7uFdEI89FLg2jF2
         RpqiLx5uKZIMdQ3kPSDOqtituT7ENylfTc9I68ds3gbNDvGWwMZuPjP4I01szOballxr
         W1JuPn8y+ZiUJuHl5+xMQdOK3JEvE/Nq0jgB+HwaJ7Kpgv7vATAuL/kXfKezrTntE46l
         HWZg==
X-Gm-Message-State: APjAAAU9ZWAoaNg82pjAczIAFkrEpaX66TUSBb43kfbF0QbmuhOO6WN/
	Xt9ACGj0EUl9WBb9HrL8WC3CfzMJ/c4I1hH44VoOflMMt+NGmSPKg9loH713yaWgRpaCGXXJrbW
	g4OExSVYWo+j722drifpibHQfLmeMxwCnrh6uJjFZKF8EtJsyiyv79oBhYa5H3nEj3w==
X-Received: by 2002:aa7:9407:: with SMTP id x7mr23158396pfo.163.1564148756384;
        Fri, 26 Jul 2019 06:45:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEc2iayENgPkc271qrnBUE59W4hClqk0AbLBKKVfQPSWM762FR5ZYYorlNeyebHYDXPQM4
X-Received: by 2002:aa7:9407:: with SMTP id x7mr23158348pfo.163.1564148755712;
        Fri, 26 Jul 2019 06:45:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564148755; cv=none;
        d=google.com; s=arc-20160816;
        b=b0vPdjT02Enh0+HDNoZFWf2jvOQb6tREeaxo/RNX8hTQCfPkwrhchrK2EYpHxJwi1R
         q8ozPOwJCgIzn0WDDP7M34jjH1wGVFD4utINjd2d8RuyoPrvswqbAhKZ411HStrzhmrN
         oobTMYAM2Q7KM+ys7/nUluILCUoZidwDfQ0awrkshMWcdIKgVJV/cCZ7TGCvI/aOwKAT
         nmGKtStvJpB199KaOBsb0+/DRZzC2oryXoNjm8VXDONUT03nGXX6Qfid4B4IwFbIG7J4
         nhmhwZRZ1seQVZJpMvGeMjkB4EzGg2cqsFp0a3srRNdEGV3xT9umT+qkEjUqTZrS9Qeu
         JZTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=nAo9QA+oZvetyJFoBlgdakWF8aacOpq1iJJqhJoRCrk=;
        b=Wbu4Twe/ae7hxPVRL8mzqE7Px3JtWoJwqrpzx6jeun0dEKlFulSVg5JFKi9X3W0eou
         jp1VzXZ0zglPLnsUyRsCy4MK520G2TGolj9ig8GWH6kWh7Aqwx3DMHn4LKdMblzYn5Ws
         DAZ7HR4Sg2EqzW6hGgSLwYkx5MTQeHItp3GFRx5u3GOsX4zH8nFX7XabYrxmVVG8YZge
         xXeGZptvu0ruQiA5mqF/17zzYtuANR6JY/UWyRPlw+rL6uWep6BZ5JRtUD4aoQzAXNC/
         0/Hc32p3E+YLtVyxc+mN+EpzSF5pZFjimrU/6RiyTNITKDa7UkY+xAhSz+G/Hk3GKBIM
         GZcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=a4XUxIEJ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x4si21755385pjn.93.2019.07.26.06.45.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 06:45:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=a4XUxIEJ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0287922CE8;
	Fri, 26 Jul 2019 13:45:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564148755;
	bh=VK6/yK3gnFWBTKB/sD4C6n4IXru/I7ju81C/5FgLr54=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=a4XUxIEJwOujZp/97pXSB6X1ohXxLzbTECr+wNZuEMs7IX9EmIXuWOAK2n3ow65DT
	 A5lj9gAhE3cvQn5DPQNvNIKDyq2hhDiH8PvsTzNPtABpufpTKuW1jRMRpmjSfjukna
	 f6pm01PgDcLKQeZRuQSAc7ii/87eJJ9zHZX1Sg44=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Doug Berger <opendmb@gmail.com>,
	Michal Nazarewicz <mina86@mina86.com>,
	Yue Hu <huyue2@yulong.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Laura Abbott <labbott@redhat.com>,
	Peng Fan <peng.fan@nxp.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.4 15/23] mm/cma.c: fail if fixed declaration can't be honored
Date: Fri, 26 Jul 2019 09:45:14 -0400
Message-Id: <20190726134522.13308-15-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190726134522.13308-1-sashal@kernel.org>
References: <20190726134522.13308-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Doug Berger <opendmb@gmail.com>

[ Upstream commit c633324e311243586675e732249339685e5d6faa ]

The description of cma_declare_contiguous() indicates that if the
'fixed' argument is true the reserved contiguous area must be exactly at
the address of the 'base' argument.

However, the function currently allows the 'base', 'size', and 'limit'
arguments to be silently adjusted to meet alignment constraints.  This
commit enforces the documented behavior through explicit checks that
return an error if the region does not fit within a specified region.

Link: http://lkml.kernel.org/r/1561422051-16142-1-git-send-email-opendmb@gmail.com
Fixes: 5ea3b1b2f8ad ("cma: add placement specifier for "cma=" kernel parameter")
Signed-off-by: Doug Berger <opendmb@gmail.com>
Acked-by: Michal Nazarewicz <mina86@mina86.com>
Cc: Yue Hu <huyue2@yulong.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Laura Abbott <labbott@redhat.com>
Cc: Peng Fan <peng.fan@nxp.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/cma.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/mm/cma.c b/mm/cma.c
index 5ae4452656cd..65c7aa419048 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -268,6 +268,12 @@ int __init cma_declare_contiguous(phys_addr_t base,
 	 */
 	alignment = max(alignment,  (phys_addr_t)PAGE_SIZE <<
 			  max_t(unsigned long, MAX_ORDER - 1, pageblock_order));
+	if (fixed && base & (alignment - 1)) {
+		ret = -EINVAL;
+		pr_err("Region at %pa must be aligned to %pa bytes\n",
+			&base, &alignment);
+		goto err;
+	}
 	base = ALIGN(base, alignment);
 	size = ALIGN(size, alignment);
 	limit &= ~(alignment - 1);
@@ -298,6 +304,13 @@ int __init cma_declare_contiguous(phys_addr_t base,
 	if (limit == 0 || limit > memblock_end)
 		limit = memblock_end;
 
+	if (base + size > limit) {
+		ret = -EINVAL;
+		pr_err("Size (%pa) of region at %pa exceeds limit (%pa)\n",
+			&size, &base, &limit);
+		goto err;
+	}
+
 	/* Reserve memory */
 	if (fixed) {
 		if (memblock_is_region_reserved(base, size) ||
-- 
2.20.1

