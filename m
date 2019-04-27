Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0E76C43218
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:42:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 811A820652
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:42:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="waqk+8gg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 811A820652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A2726B0003; Fri, 26 Apr 2019 21:42:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 151376B0005; Fri, 26 Apr 2019 21:42:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03F016B0006; Fri, 26 Apr 2019 21:42:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF7BB6B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 21:42:18 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id t5so2497009pfh.21
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 18:42:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3RNZxIdCpMdQjz4VsHugfEvm/PyEOsHicLIng3Yhw4s=;
        b=Ap4QZcrHogg2J5dn7Tun3oGlcapiGVP+Z+BQXwVoWCYs5FCKdjTPo7bHeM9xGUifyl
         hrqK9OLIZu8rKMoGeVrUTm7zMdDxf+Sz3o1q4apDG5ekGOuqnL2/HFUV8CiYIOelDi7M
         4GrIyB23pJJnX2ByP97UQb19Qgr1bY2GYdb7RqiNw28ikCBAIpb+3eTSkIEVO+uVrl6m
         akd7PIoQwed+AB5jNzwHzX1iPtmiAxAjogIsrD04Dh4tcSUnx7bbdp3eyDfcBD7tJUcL
         ax5bVGwWUN6YeYOThPO6K6BCJM9gxrUg+YjHC9Xr27bvUtFLxuqXcc70I51BHd1MlPel
         +wHg==
X-Gm-Message-State: APjAAAVAZb5oIo4OwJe3GAjafZGSGMmjHua2xoSZnzM0w+bk6dgXhHnk
	vDRBs0qq7g2Gm4n+oCF6WTCWA4v6+Up0j1bmbMqhOcoQPzH0wLHyCA51LK3uaVhLtI4psTbbHEf
	BLKDAWb2GHXQFvNM5o9QgTF0xIHP3aPxN3q2ocwkU7y+j5NUHqiTNwaOAotLQUwahrA==
X-Received: by 2002:a63:f503:: with SMTP id w3mr43294345pgh.60.1556329338434;
        Fri, 26 Apr 2019 18:42:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztxjcNx9o5GSuaPEuQKkVEqwuOEDXSKcHeBd/xh7hz2i9yP+ZJblwXlq+hm/Ljr2s1iyr9
X-Received: by 2002:a63:f503:: with SMTP id w3mr43294294pgh.60.1556329337719;
        Fri, 26 Apr 2019 18:42:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556329337; cv=none;
        d=google.com; s=arc-20160816;
        b=jTTC+Z5KJyYOjqWicGh3Ue0Nn3hjMD3unWSC/3QZ9yDtInk9yItpZeSBJJjAts7/CX
         VHgIucw3QBYVx3u9z5ss3DNjfdGUjAvGvzMuveFUInlZPL+LsZe4Ng1xPE/+wLVnlB91
         KhzboZly0S09HQqztrXvNLQakuF91Fp+yteiTgkgIb8ff3fz3kgunfiqcX4W95up/WJH
         8v1nCtpnOYYXWrcqqBT96vPzEqPpC/qBZFWTXPWXAKfuQ4tSyqRZGdbDsc+jMq0CxsjV
         puMv50h1xxVdvwZs/NsBCTqbf+8/iCknUnqnS376x3mdYJ20dExtmSBO4NbYrXcxhloa
         bJXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=3RNZxIdCpMdQjz4VsHugfEvm/PyEOsHicLIng3Yhw4s=;
        b=Zh8StADdqG0X1GSSX0kfoxNyNsBfSscL3miahsLpY5hHFMc7o1BWsQSftFZ1Xyk987
         +IUjw3ZhQGJYTqxzuIdE3QQJeidJZ9BXPcc/k6pBElFTcDShSLdbu+gWC+Fulwt5YlVt
         SYJJjTd84w6PdQYYQ+8bLNhuVZABEF67NjV3Tq0nI1d/GnGx4se1Xv0jNxbOlfAY6nkU
         +x0wJpP/H076FvdeYmcdkMjST2y+rpnZlSM69tyfGMGLnNSTIiEkfCwIp49P298PILP2
         pbMHP77fs9eWMNkvpHKSw20kYXA8gL1KOOE1dhz717S7k0gO5RVA+QpA/uVKp68Pq1u9
         +r/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=waqk+8gg;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b66si13676718pfa.104.2019.04.26.18.42.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 18:42:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=waqk+8gg;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8F0F1208CB;
	Sat, 27 Apr 2019 01:42:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556329337;
	bh=Q3urYcDEe66IuY8WV/UjTgw2Qy8LfG2AzF1wj1n+t0U=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=waqk+8ggI3L5mIr+UtL3h9NfTyBNP670LtQBT/SPaVLGPl6zLtkP3QR+LhQTgYHPO
	 WMsi/5KHPR1Z+NTKdtdY39y0vG0M4upRuqQiq4bHMA1L9dXK2tHIEQJyloR9J9OaYd
	 GrCKV0/tLTIO0faZc2KjC//VYTww5PSzwuzdMUlI=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jann Horn <jannh@google.com>,
	stable@kernel.org,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 51/53] mm: make page ref count overflow check tighter and more explicit
Date: Fri, 26 Apr 2019 21:40:48 -0400
Message-Id: <20190427014051.7522-51-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190427014051.7522-1-sashal@kernel.org>
References: <20190427014051.7522-1-sashal@kernel.org>
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
index e899460f1bc5..9965704813dc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -915,6 +915,10 @@ static inline bool is_device_public_page(const struct page *page)
 }
 #endif /* CONFIG_DEV_PAGEMAP_OPS */
 
+/* 127: arbitrary random number, small enough to assemble well */
+#define page_ref_zero_or_close_to_overflow(page) \
+	((unsigned int) page_ref_count(page) + 127u <= 127u)
+
 static inline void get_page(struct page *page)
 {
 	page = compound_head(page);
@@ -922,7 +926,7 @@ static inline void get_page(struct page *page)
 	 * Getting a normal page or the head of a compound page
 	 * requires to already have an elevated page->_refcount.
 	 */
-	VM_BUG_ON_PAGE(page_ref_count(page) <= 0, page);
+	VM_BUG_ON_PAGE(page_ref_zero_or_close_to_overflow(page), page);
 	page_ref_inc(page);
 }
 
-- 
2.19.1

