Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17219C43218
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:40:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3F4420B7C
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:40:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="jDZ8BR4F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3F4420B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76D926B0005; Fri, 26 Apr 2019 21:40:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71D156B0006; Fri, 26 Apr 2019 21:40:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 634796B0008; Fri, 26 Apr 2019 21:40:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 26DDC6B0005
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 21:40:43 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g92so3036952plb.9
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 18:40:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qH/zJ98hTYZOzaO4pEtkIQYKpIKXC4v608B1W2qN1qU=;
        b=trj/wRxfbkcaAKEZUvauZ0155fBP3xcmPLXwF00sra0eR6WOPSte6fwUEAhgHR90Fk
         fN1TFTlfG3GJaEFvXjJzTRnZQlGmid870ugjYNRieEyNJcVB+eimb/B+l83phdvduPrI
         vjBdHk0fujvrNNLkfJtkDhiHPM+8H08YdobtkQIsnvAlkssdfaQJfUtQ+5vVX9BNX3zA
         WckwLsy8cprfvO4pwl8JfzbDn1abN5290PEvxYy2w2YtIu6eKEia0cRXZ6pmx3+sqQRW
         62F8C5xJT3ek7l+ojj21/XbgaQ5Zmcap3a6/Pwq2TiND0Qeme5XE5zlVU4ab87/ZndH3
         /pog==
X-Gm-Message-State: APjAAAUTU19d+r3wahbpTS27P8uQfjhLSHo54+coqKxrxnN9kkE4q3WM
	tS7MB0euIo7ukjc8x1AamTcXkHKO1x+/FwDAdGVmuduYisV8io6hHLxNq41FZBx/ZwG8C2H4QvN
	Jo0lZCDF+zQbOl6OZN4QimQDESeY64fjcavFa3mgcJS+X2jAOnRhkumP3w+4gKiFtag==
X-Received: by 2002:aa7:8d8e:: with SMTP id i14mr3200918pfr.121.1556329242800;
        Fri, 26 Apr 2019 18:40:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8ZFkd+IjKIWS0u5c174cgTL6vJsHnjX1G6aunlzo0w5nm7+ZBQiTWGFk1031kzR7gLfka
X-Received: by 2002:aa7:8d8e:: with SMTP id i14mr3200880pfr.121.1556329242139;
        Fri, 26 Apr 2019 18:40:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556329242; cv=none;
        d=google.com; s=arc-20160816;
        b=aMvVhTmSVgbd/yXdn0kr62jXX1MwsbOWle6dDHA6ciWwkivq7ZFMCTU96kynMmgcsF
         12mSgoHerMGMNRZ+Li4DM/QxKpc3g/Bel3F7w2M1NPHJmv3dPXPeNSTT21EsJoxX1YDx
         BAgw2+XvOFxTmcAxk4ikGaFkkXDuWuW60OFK3p1qkLsImCT01xXCcGGlxhZCDJe7z1El
         aJJlbNqnqFfmGJaSxeA3d8N9ToTFEe7Guf/riovhpUie5qrhhQMMH57W9NMO7wnt9VcF
         WAxPhK4g7hdZtr3eqljzRoPQHw11aE/m2xjAT+VoBtgyyy+kzkWZ7aJrdJJvh4PQ+pPt
         wT6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=qH/zJ98hTYZOzaO4pEtkIQYKpIKXC4v608B1W2qN1qU=;
        b=cqZT6Pd7lcbCinTlmP9viPG9MJJm8lDDVfDhy+rlCIA/Owj5jrqW9biMfxzb/jGjdG
         PuPUf7LRcwQRDbqR+ywGI5WejjN0YznpQwL+4PQSAYGfxVcjG/wzvAqMJH2xD2KL4Uxd
         SJdGzdaQsPaVbQjBC0NFNjVSF2/No7s/x/aLZFVFlg60Gkn0kpMgHtWYgsCdFAD4eInM
         AbJnrwt8nZaj6hlOIAt4kUz1k1AGw0zm2S56fjzd1q5NtUkR1hGTTZDRgLl9NAO6m08X
         yikDI6n4lHFJdDLG6oE5JCDbc2Ds/yeIWUXtyy+Ob1Ch4sEWAKT28+/bcFF56TqT+X/v
         jdCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=jDZ8BR4F;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d20si26124822pll.322.2019.04.26.18.40.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 18:40:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=jDZ8BR4F;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 09CCD208CB;
	Sat, 27 Apr 2019 01:40:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556329241;
	bh=Oi0TxYuDHBd93kuX9fo74E5Om1hd3KEPLC7F9JU9O7k=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=jDZ8BR4FV0etFXwiRas+bHOMFvY8AODs8wusc2k1iyA7iFclmg09OYEHpnhRJwQwh
	 sPHdWqu8NJNUKFeQliDejfZfk6LiFyqc6URhqa/Ap5Xj6GOHmWKBt1ZaGZ5VKNDPCj
	 nQ2sRz/q91PbeeLXD66KQkbbb59mXUtTanhtl0lo=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jann Horn <jannh@google.com>,
	stable@kernel.org,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 76/79] mm: make page ref count overflow check tighter and more explicit
Date: Fri, 26 Apr 2019 21:38:35 -0400
Message-Id: <20190427013838.6596-76-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190427013838.6596-1-sashal@kernel.org>
References: <20190427013838.6596-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Linus Torvalds <torvalds@linux-foundation.org>

[ Upstream commit f958d7b528b1b40c44cfda5eabe2d82760d868c3 ]

We have a VM_BUG_ON() to check that the page reference count doesn't
underflow (or get close to overflow) by checking the sign of the count.

That's all fine, but we actually want to allow people to use a "get page
ref unless it's already very high" helper function, and we want that one
to use the sign of the page ref (without triggering this VM_BUG_ON).

Change the VM_BUG_ON to only check for small underflows (or _very_ close
to overflowing), and ignore overflows which have strayed into negative
territory.

Acked-by: Matthew Wilcox <willy@infradead.org>
Cc: Jann Horn <jannh@google.com>
Cc: stable@kernel.org
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 include/linux/mm.h | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80bb6408fe73..541d99b86aea 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -965,6 +965,10 @@ static inline bool is_pci_p2pdma_page(const struct page *page)
 }
 #endif /* CONFIG_DEV_PAGEMAP_OPS */
 
+/* 127: arbitrary random number, small enough to assemble well */
+#define page_ref_zero_or_close_to_overflow(page) \
+	((unsigned int) page_ref_count(page) + 127u <= 127u)
+
 static inline void get_page(struct page *page)
 {
 	page = compound_head(page);
@@ -972,7 +976,7 @@ static inline void get_page(struct page *page)
 	 * Getting a normal page or the head of a compound page
 	 * requires to already have an elevated page->_refcount.
 	 */
-	VM_BUG_ON_PAGE(page_ref_count(page) <= 0, page);
+	VM_BUG_ON_PAGE(page_ref_zero_or_close_to_overflow(page), page);
 	page_ref_inc(page);
 }
 
-- 
2.19.1

