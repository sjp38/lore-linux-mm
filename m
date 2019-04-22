Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90863C10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:45:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3925E21917
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:45:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="bGeZS1uw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3925E21917
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CAF8C6B0269; Mon, 22 Apr 2019 15:45:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5ECB6B026A; Mon, 22 Apr 2019 15:45:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B744C6B026B; Mon, 22 Apr 2019 15:45:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 80BC56B0269
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 15:45:10 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z7so8553491pgc.1
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 12:45:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wVcEurmY5uS4Iqm0l1HscDjF+Rb0jMGiXOZB7t4sXf4=;
        b=YMwi/SPvXN6rZDbInPIKUNOsyJXRQKWG0nY3/WWFQ8SAcODOAM57gJEMmU2WaVcuJl
         o1b6H7e2j8F9lnMVUEA9RFq73bNUdtxsqTwJpM9aDrRuKjYqMz4OQl5yLdzq8+4JeaaH
         gmgXvtspEF5hT/XnL3YGlEz/Cc/Fgs8WrotU7UZemqJ8S5jxqxIu/VqkDPG75vftSud5
         EoOFupIWythBuNLdwjCw3W9wK3ckddp5qb/aQQMingXGIwdOo5PocYQQqwNuaYS2+qLh
         hGchZDaSN9pLQhgWV6jl0T+t1sMfaH9xCEgxPKy2sveASf0uNsZyc5bGDCJwCa4SVBJU
         hZhQ==
X-Gm-Message-State: APjAAAVPRyf2wkGKwJ39yQuUOPVZJoToJUNl2t05K6IwlOyPmFTjW9Z9
	AlhSJh3e4y6PM6WitKKr/kvQpDq5VAUFF27zWv9KZSt+uVb2FJr15JtLHOv29mnc0FFEKdH4wAb
	dFOaiVw8z+puAwM4rbifZNWY+443mM73ex8Rs/es1Mkuk66PldDeIqlPsadMg61P6rg==
X-Received: by 2002:a17:902:2702:: with SMTP id c2mr21966369plb.37.1555962310029;
        Mon, 22 Apr 2019 12:45:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqN3XKy2l0aZDrCEX1r9CmHu7fQl993oeYjCTFvy2WYm1m61TVnCn01a2lRnwrT3IRS9aT
X-Received: by 2002:a17:902:2702:: with SMTP id c2mr21966311plb.37.1555962309294;
        Mon, 22 Apr 2019 12:45:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555962309; cv=none;
        d=google.com; s=arc-20160816;
        b=UYRa4XEtbTGN9pCDtjfRH3+qP9L+CJ0SX1kmppp6PrR5pDk3ObaRry6KFHd97ZNhz5
         HNWnr1AFQ+eB1fY9SDqqUVZwOl3cTR1vWCCW8ZyTABlD8lLcg4S36E46LnhP7nzYcrUS
         OHaCOnf66gzYNkK3ah7htrXPuS8V5NtPCD+kUkeHBcI+IOn85hRo6CabC1E0dhoi3qCR
         D9IW9OcgjgUPWlvXC0Pnc2FfJeF+ktYSUB+dP8NSaKb89Xp7fsNKRlxKuwBaIkXijxK/
         Y75ac1XDDxajelq5DB+9djpxzSMpVLjjhEK8muqnpcLHrWg1o4GC032ihOYeatBuwfTP
         TQYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=wVcEurmY5uS4Iqm0l1HscDjF+Rb0jMGiXOZB7t4sXf4=;
        b=bP/SMaVAS43JEa+PEqvx5T5GfHrgJYVZu0V1zRtCBAFSZn2xOa9ig1vok6MkJ5UUDl
         BUda5Dx52deOcmIeONigSyVcoTkfZS7YzgiWu0knC41DXo1XBouKM1AQ9NOL0QB/7kpR
         2P8aXJyELYVCqu+GaM2w0d0Wkj4YPelhgw30rfZD/ujiNz/+K61MMYXQa7ff69WHntwR
         ERuk5I+mOdP3h0lbsBi/hgM33JOa8dMHdGUASXuHAPgJBIPxMuKvxm02WJ9haxxyFaVS
         E3/2nnhNY3URgsLSDsgHVnbmVPNO2aHaxNgSln6uvQCsBtG+ObInrfg+/urD6TY72KIh
         kzcw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bGeZS1uw;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 125si12549542pgc.220.2019.04.22.12.45.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 12:45:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bGeZS1uw;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B9521218FC;
	Mon, 22 Apr 2019 19:45:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1555962309;
	bh=ayBwbVMY9vgfYN51KPq6lqqiETptuAceXX80LCYaM4I=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=bGeZS1uwcI9daP4jNXauOuysr3JJkNmwGkycS3aQUU8YFud/ZfaV+145hai1yPyn8
	 CYFyrclvlMk0E6s3KYbb/YucUwyWXgsTHOScAu6rmMgRyJO1CBgdi3QPRZWkOaT5ag
	 SiNp6HpYvCExLoq3UuK8rDCVFBEjFVr6Ip8VPLaE=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	kasan-dev@googlegroups.com,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 95/98] kasan: fix variable 'tag' set but not used warning
Date: Mon, 22 Apr 2019 15:42:02 -0400
Message-Id: <20190422194205.10404-95-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190422194205.10404-1-sashal@kernel.org>
References: <20190422194205.10404-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Qian Cai <cai@lca.pw>

[ Upstream commit c412a769d2452161e97f163c4c4f31efc6626f06 ]

set_tag() compiles away when CONFIG_KASAN_SW_TAGS=n, so make
arch_kasan_set_tag() a static inline function to fix warnings below.

  mm/kasan/common.c: In function '__kasan_kmalloc':
  mm/kasan/common.c:475:5: warning: variable 'tag' set but not used [-Wunused-but-set-variable]
    u8 tag;
       ^~~

Link: http://lkml.kernel.org/r/20190307185244.54648-1-cai@lca.pw
Signed-off-by: Qian Cai <cai@lca.pw>
Reviewed-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin (Microsoft) <sashal@kernel.org>
---
 mm/kasan/kasan.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index ea51b2d898ec..c980ce43e3ba 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -164,7 +164,10 @@ static inline u8 random_tag(void)
 #endif
 
 #ifndef arch_kasan_set_tag
-#define arch_kasan_set_tag(addr, tag)	((void *)(addr))
+static inline const void *arch_kasan_set_tag(const void *addr, u8 tag)
+{
+	return addr;
+}
 #endif
 #ifndef arch_kasan_reset_tag
 #define arch_kasan_reset_tag(addr)	((void *)(addr))
-- 
2.19.1

