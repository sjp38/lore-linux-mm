Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9095EC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:14:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 581DA2184D
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:14:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="GI3pnzsH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 581DA2184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05F708E000A; Wed, 13 Mar 2019 15:14:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0106D8E0001; Wed, 13 Mar 2019 15:14:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF4918E000A; Wed, 13 Mar 2019 15:14:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9E11F8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:14:12 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m17so3321268pgk.3
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:14:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1KzwPaM63H11zh2mO9/xRPRnOCcEOAPlzK0UF5G5CTA=;
        b=VbmMr/tdfFuPSxvDaTuNo26bFXi8WV7/74YunzIGrFB/SfjCUQmbB81Dius4dBDT+c
         0MS5pmwp17CGynuxFFzlFPZmkyIFpH+O6lgR1LXoks/4C0B/INUHyrwTYuZffOFvq0qc
         K7lckd9T2UZsppTLw2XTYVasDXg6A6YzT2Tqeq8xhIP01ChqXJPS82POreipBasuH0Ra
         AFZYbV00+chKvwl6/MenGskBEnNHbt9Se8e2vRxuxPsIZXAye34MIP2NuJmXiJJLS7c7
         JetlptQyS5tS2Su4SFucorRlIsVnErz83T+Z3ZoCWRldwloX16/ApDFO9tH1jt93ID5g
         pOYw==
X-Gm-Message-State: APjAAAWl21eo8WV25X5HHF64vvhSAoH6Qcjx7rOtp2Ld9mlP2fKWaTD4
	Q+9DKRY5shr8mQ5gzmv0CEA4yr5ILuzp171XXEtCVhnUmoEVmi5ZBSwXDuic1ezvsoL+Hme3scf
	Mu4kgjUchtjBSxa24VX9TG4063OZartNQE2IjCu89AKUqtJHUCUa9C/5kMHZA6rXN6g==
X-Received: by 2002:a63:6a48:: with SMTP id f69mr41114854pgc.7.1552504452345;
        Wed, 13 Mar 2019 12:14:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypMNAZPMdat3njXAmwEVCaXJtE7QD8WpDAikcxOKpwhzyM9xtL6I70qOGIZEKGLciYpT8k
X-Received: by 2002:a63:6a48:: with SMTP id f69mr41114799pgc.7.1552504451711;
        Wed, 13 Mar 2019 12:14:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504451; cv=none;
        d=google.com; s=arc-20160816;
        b=rWFSclUSdioXqxMiJlOaFnSOCNdGfkkucX5WXut7S/Nue8PT4V6iySl1GoXPuvA6p5
         n8kbtz1uBLbMYhad6+IlDB8Wp8Np4zkv4t9HEo2wYPmSLjdTAQN1UuxLrC6nPs1j0edB
         urieyo+lm8qs6g/EkSl97DOSen8b0TjEXpD10jUdXzPhPytqpx8J5u8mIFBR1uxHGJet
         3AgDwl9PBuEhmY59+etK+fR9cAIWNm8y88t6fg4UkbBJFaCwwxxfouxaU3cRot/570OO
         6Opx/+1CuPGNRW5o8jlmtY2o512Vta4puToKCV/9xAIIUtyhaIGo5kbGKroeiVVLhReT
         d2pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=1KzwPaM63H11zh2mO9/xRPRnOCcEOAPlzK0UF5G5CTA=;
        b=bZHWcJCHAv39ne7bZcGXrOW1C2eTn/yEJdZP7QR/a8uFZArqmtzwt2hBayv6JlUw7v
         eANyjzMPv37IvIKswbzpojOYuYjLT5HSJGK1vn5rbRUxPnRHSQyel3VuBPgkrRxUPF+E
         kdjkNsBJZJheZ5HdCAiWlrcyc0TGfEVXogeNDRR/rToiOIwebSSliGE+Qgt23i8xAvLq
         xa1IolvDLfDjWv6W569jZgw6pNv42Syg2CYxL15SjOrJgBQ5DaAgqx4SfULvNge58MWU
         LKK4DKJDCQ+cC+L/MVwdIdhs1tjawOmPcXimerW1hPxJvbWk+74XD0UpFo8xNTTHCjZC
         FODA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=GI3pnzsH;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q22si10328740pls.408.2019.03.13.12.14.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:14:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=GI3pnzsH;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 99DC22075C;
	Wed, 13 Mar 2019 19:14:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552504451;
	bh=sl6/GXQRelWFsXQW/7BdboCO+QtKuHFRyTkajJnALtI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=GI3pnzsHlRP4YyRLrxXbG4tz+S55XhmiP3WLaCgsO0yoRGP49AId7Ngu4oPDozYTt
	 WVHHdLNYUIBAsLLTl7ri1rmWCRTk5w+ugLbqPWp5ZgQjnzuZdQu8SpgLnibn6JYGAk
	 jxAiLGai+d/EVCeCev8N2xDfueEqT7UbT4RldbeI=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 30/48] kasan, slab: fix conflicts with CONFIG_HARDENED_USERCOPY
Date: Wed, 13 Mar 2019 15:12:32 -0400
Message-Id: <20190313191250.158955-30-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190313191250.158955-1-sashal@kernel.org>
References: <20190313191250.158955-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrey Konovalov <andreyknvl@google.com>

[ Upstream commit 219667c23c68eb3dbc0d5662b9246f28477fe529 ]

Similarly to commit 96fedce27e13 ("kasan: make tag based mode work with
CONFIG_HARDENED_USERCOPY"), we need to reset pointer tags in
__check_heap_object() in mm/slab.c before doing any pointer math.

Link: http://lkml.kernel.org/r/9a5c0f958db10e69df5ff9f2b997866b56b7effc.1550602886.git.andreyknvl@google.com
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Qian Cai <cai@lca.pw>
Cc: Alexander Potapenko <glider@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Evgeniy Stepanov <eugenis@google.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slab.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/slab.c b/mm/slab.c
index fad6839e8eab..813bd89c263b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4421,6 +4421,8 @@ void __check_heap_object(const void *ptr, unsigned long n, struct page *page,
 	unsigned int objnr;
 	unsigned long offset;
 
+	ptr = kasan_reset_tag(ptr);
+
 	/* Find and validate object. */
 	cachep = page->slab_cache;
 	objnr = obj_to_index(cachep, page, (void *)ptr);
-- 
2.19.1

