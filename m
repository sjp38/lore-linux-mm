Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A056EC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 23:10:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39CEC218D3
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 23:10:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BJmCqB+F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39CEC218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9970F8E0008; Wed,  6 Feb 2019 18:10:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 946E08E0007; Wed,  6 Feb 2019 18:10:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 835DF8E0008; Wed,  6 Feb 2019 18:10:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 422088E0007
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 18:10:23 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id b7so5700085pge.17
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 15:10:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IW5+9eoUK0l9YrjE71fI7riUMWj4UeJsluIuFcwuFT0=;
        b=pKMAF9VaIEBgMysdCY1Hfg4o7pNYEHZIpcmdpkXeDyxd7Ep8/ZNroOV4i0qE3MCMTZ
         qjNMKqpc+ksoKhOHWXMGyP6e80VQrJPd7GlmwiCuiD5yBpL+JaTfU2grdyHgziHewBlA
         aDHtagt7ZrqJ/GVP606VZR851xi1LUQRFmc73ZseBNzzTtKVAricipD3/cWo4V7EI2Fa
         f3mxko4iRDn8Lt308JxCb6aCvjKHNSSYcFpI4ccZVKwD7Si1fY+wpQMTibxVIoeEa9n2
         zQmXvhLJRb4ohy+MSYpepe/ENXYgYmmLcxAh/7+YfezvkiaO3KZdVeBsfw+PnF0I6YKv
         O3Vg==
X-Gm-Message-State: AHQUAua+FDhCMPOUzRByE7z5RMlIu+I9uc55x5k5gJ2dr7dW+1Zk8vTZ
	69fwr44GYHifzJyc6HhvtfJZTnMzGs2ycCHgsrkEa24WkjGauWj+rCtylaA4tjJIhyZwa9YXeDD
	a0YkEeatwg1+UXyUC/TuZHa0cntUTt8mn/jJyse4e4hT41bBYZ1rppAUwVSDENHbxQXiCEeDMR4
	/BzoI+Fk6SNyyFj9CGmfVlzp7nOX+nJmJJv+eMGXZx4SrQpE5WTqgTFFhZDzC16hZqB/Vl0nBvj
	Gp12YvNRoTGRh9Mw6XplNk5G5VyamJvUo02o0ArQ3YPVCM6P7G59G73bEDBm7boCpfeIkKSknE7
	oWDPxVCyGiGTeaJhj6NuFOQgoSHTbjU3bjAYmjFbY50Dg1gftd2ahzx7D13GqAU5VLXy+zGHqrT
	O
X-Received: by 2002:aa7:8608:: with SMTP id p8mr13187228pfn.125.1549494622804;
        Wed, 06 Feb 2019 15:10:22 -0800 (PST)
X-Received: by 2002:aa7:8608:: with SMTP id p8mr13187166pfn.125.1549494621945;
        Wed, 06 Feb 2019 15:10:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549494621; cv=none;
        d=google.com; s=arc-20160816;
        b=WwDeJTDj+UMRZeixzbjP5RT7Pnm9/a29XI6piv5Fu6cqNdRuyJqTjJvMlGX+ak9Kdm
         2E6SO0dI6AMHIEPyH1Hyk3rhRq1jzJ1+0wFGZd6hhmPWUZuj8oftK1nQaZ/rVw6rogFr
         kTSVlbU2SH3hPc7bF7db13X6/aTgJB9kItCBMfvUmXJ6wkYHCus4lJNtXUsqVc2PBtMh
         xSdDr9BdpNPr0az3lYSU78Jajm7zVHz5mEs8Fe0GUC+1h/BB//uAhMhgf7WenhOvKy94
         ULCcnRMxmFTyCfB2DkBOry3cc+QdenHrf1r4n4L8cpmCo444vHoIBR0mqerqOl2Kyc1F
         xY3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=IW5+9eoUK0l9YrjE71fI7riUMWj4UeJsluIuFcwuFT0=;
        b=QvVgqxy3HRiXiKiBprIQr3ucPsru1Qo+xMR8ikOoQpTxQWXDJmUZFisi1uyu2Igc3n
         CfHxl+a7tRrsmqDk+E7vbzErQbQMjW6ihqN/Tm4ZznscV1vKjSU4qHDgFv6jsyjboHYT
         y8CX9NxhZnqihzi49d8WK68ZuChi6QNqCIvjwZdWYSH2Yiws+yLVfL5XY86WDvyFWqS6
         +h1Ahc986MulI0ka5XYf9Jdwq7pPvGkIepe2YJROBudm5sZFonukP5crIzdClW//5tJA
         4E7hf79UMRf/OO/RsEQVAxO6Dm1dXtgovgsOi7rpNJsOpFJjs9UJ4b90Z8NoE7NkJ/ow
         btwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BJmCqB+F;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n11sor11337168pgp.31.2019.02.06.15.10.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 15:10:21 -0800 (PST)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BJmCqB+F;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=IW5+9eoUK0l9YrjE71fI7riUMWj4UeJsluIuFcwuFT0=;
        b=BJmCqB+FYNHvoRex8qr4dbAfs5Mf0252hHcfg/OZAboQRNYqmaW7kfkPRwO3dDHRUy
         qF6oEwFeZ5N4GqAKAdY/AmJgMORRj7G4fqYt0V8lAdcOoVofv7Etr+kcHEJmI5Z6p+wD
         0/YTA9ALzW1uaQJQoqUrWR613rH1V+AAV0tadVlh0pz866EFwtAVuI8AwCPuWsRodRdf
         jqkKffwVfPkbN2isTC3ogHDmF8vXsFIRIf8x8oLd4N25YGEalo/7eya4R8/LjPcIVSjC
         lcUL4HitdvQHD9cLYhQfBX5gMyFUIlGwDRPdWY4+6x1lUx5uKJw/Txt2i0FY2k5zwupa
         vYsw==
X-Google-Smtp-Source: AHgI3IYugb1cc5BuZx8B30vi/3nzgkFWUW7+hff/o66VImrH+fVFZjDNajITNe9J1IRLJe54p7x8CQ==
X-Received: by 2002:a63:7c41:: with SMTP id l1mr11843148pgn.45.1549494621594;
        Wed, 06 Feb 2019 15:10:21 -0800 (PST)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id 4sm10254880pfq.10.2019.02.06.15.10.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 15:10:20 -0800 (PST)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Nick Piggin <npiggin@suse.de>,
	linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Dave Kleikamp <shaggy@linux.vnet.ibm.com>,
	Hugh Dickins <hughd@google.com>,
	Jeff Layton <jlayton@kernel.org>,
	Matthew Wilcox <willy@infradead.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 1/1] mm: page_cache_add_speculative(): refactor out some code duplication
Date: Wed,  6 Feb 2019 15:10:16 -0800
Message-Id: <20190206231016.22734-2-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190206231016.22734-1-jhubbard@nvidia.com>
References: <20190206231016.22734-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

This combines the common elements of these routines:

    page_cache_get_speculative()
    page_cache_add_speculative()

This was anticipated by the original author, as shown by the comment
in commit ce0ad7f095258 ("powerpc/mm: Lockless get_user_pages_fast()
for 64-bit (v3)"):

    "Same as above, but add instead of inc (could just be merged)"

There is no intention to introduce any behavioral change, but there is a
small risk of that, due to slightly differing ways of expressing the
TINY_RCU and related configurations.

This also removes the VM_BUG_ON(in_interrupt()) that was in
page_cache_add_speculative(), but not in page_cache_get_speculative(). This
provides slightly less detection of such bugs, but it given that it was
only there on the "add" path anyway, we can likely do without it just fine.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Jeff Layton <jlayton@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Nick Piggin <npiggin@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/pagemap.h | 31 +++++++++----------------------
 1 file changed, 9 insertions(+), 22 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index e2d7039af6a3..b477a70cc2e4 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -164,7 +164,7 @@ void release_pages(struct page **pages, int nr);
  * will find the page or it will not. Likewise, the old find_get_page could run
  * either before the insertion or afterwards, depending on timing.
  */
-static inline int page_cache_get_speculative(struct page *page)
+static inline int __page_cache_add_speculative(struct page *page, int count)
 {
 #ifdef CONFIG_TINY_RCU
 # ifdef CONFIG_PREEMPT_COUNT
@@ -180,10 +180,10 @@ static inline int page_cache_get_speculative(struct page *page)
 	 * SMP requires.
 	 */
 	VM_BUG_ON_PAGE(page_count(page) == 0, page);
-	page_ref_inc(page);
+	page_ref_add(page, count);
 
 #else
-	if (unlikely(!get_page_unless_zero(page))) {
+	if (unlikely(!page_ref_add_unless(page, count, 0))) {
 		/*
 		 * Either the page has been freed, or will be freed.
 		 * In either case, retry here and the caller should
@@ -197,27 +197,14 @@ static inline int page_cache_get_speculative(struct page *page)
 	return 1;
 }
 
-/*
- * Same as above, but add instead of inc (could just be merged)
- */
-static inline int page_cache_add_speculative(struct page *page, int count)
+static inline int page_cache_get_speculative(struct page *page)
 {
-	VM_BUG_ON(in_interrupt());
-
-#if !defined(CONFIG_SMP) && defined(CONFIG_TREE_RCU)
-# ifdef CONFIG_PREEMPT_COUNT
-	VM_BUG_ON(!in_atomic() && !irqs_disabled());
-# endif
-	VM_BUG_ON_PAGE(page_count(page) == 0, page);
-	page_ref_add(page, count);
-
-#else
-	if (unlikely(!page_ref_add_unless(page, count, 0)))
-		return 0;
-#endif
-	VM_BUG_ON_PAGE(PageCompound(page) && page != compound_head(page), page);
+	return __page_cache_add_speculative(page, 1);
+}
 
-	return 1;
+static inline int page_cache_add_speculative(struct page *page, int count)
+{
+	return __page_cache_add_speculative(page, count);
 }
 
 #ifdef CONFIG_NUMA
-- 
2.20.1

