Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 207EFC7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:05:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5F2A21738
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:05:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5F2A21738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89E5D6B0008; Wed, 24 Jul 2019 02:05:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8506C6B000A; Wed, 24 Jul 2019 02:05:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 765E26B000C; Wed, 24 Jul 2019 02:05:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3696B0008
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:05:38 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r21so29565233edc.6
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:05:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eym0BMHdbArtu9uPr+EyfIeUu2p0S0z5kNpGctDciqY=;
        b=bYY1eLS1tY70alP+Qq1Ah98DmcWYIIs6svlsT/pPVy8nzHav+vJ6dFm8Je96iC3p0e
         Lmht3MslGp9ybtj0IhwEMtGr13DSOBrPfKa2+Fjw60K2LmTV+9DjNcT46rXK4N997vvU
         sPeaqkJQlqhglPTKoNYD1AaGOpW8krhqjvgIxENvlSuhVuFLRiJ4W5b7/jSudUUF7cDf
         +I+1fhLKZZ6skLaYolNzqeImzNep7dpdh3p7rN3kQZQIhffWQvCz8Nz9+btFnn6Z5L46
         o8w2OMlNYeo7II0+N57bKhyM6Oo48+aMgsubAdN2TJUlajHW5blPaEY6yfc/dZg3xFMD
         j7dg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAV2/tFTc0G7gWY17kVvfl4T6zkWqa7S7sIapThoxi1fnEX7O8Sx
	Lf6rvL/PiOYrbUf6mMZpPK4cfhdfEQuexBk1EltwsHV5sDQsNJlsLYcOLRIJS3USpb9tN6NzqYX
	PlsYDOnl8hLIwKiwzdjlewkMFWo0yH9mhpsifDj+SbrKkUPAYx8fPeIo91aQKRyc=
X-Received: by 2002:aa7:c24b:: with SMTP id y11mr22204011edo.239.1563948337758;
        Tue, 23 Jul 2019 23:05:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwq6NK5jc9usFkBFIReU2EBq+O1KXGhpo7ov17FTC6zYzh4N2S3rdhsYQl6Yak0dAhf/Sl+
X-Received: by 2002:aa7:c24b:: with SMTP id y11mr22203969edo.239.1563948337041;
        Tue, 23 Jul 2019 23:05:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563948337; cv=none;
        d=google.com; s=arc-20160816;
        b=RH1skHXfb6DiSX20fvrdcfqT61SM1R9EenpS0mfSejmNi59ILuxJhE2v4XtversLZC
         D9RloBw2qvbkK0lbLAkjqgO+EpW3OxSFvvIBAXgyn/BH5bWkF0phcWsHp2Qgajem9FG1
         qv+/U1SoBUBmdwX0iIgvJV10KCypzqLgubjxq95ooejOb5AYFDzB99ReMpu3OMZEyFUc
         KHMjJJdveh/Q3nF+LDh7rxd4hpw8SDOIdi/7vwYzM4HPjR0/90BLHY7DK105703XdYej
         33CKYzPI+bbCWTyLuXp5hS2NazG1f//QmcuFY9toln1urmxzPw9lXWZIBs3Ke9+fxrI7
         51XA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=eym0BMHdbArtu9uPr+EyfIeUu2p0S0z5kNpGctDciqY=;
        b=pn0jgdNNw6jW6X5bOaI1oDwIP7UiKLnGTb9NCMriU+TF6DBpHKMnCQsp3ivJPjMBf/
         5BAB/PouT5K7yVwHXJyVeSMfzwZu3jWsFsGH4Bigsh1C1g43yXQG3seQnkMFwHrbGPC0
         R+BBX1eWylKd6vUI5cIva/hjL7ElyjRaX+ogIXnnFrkzuNEYxAtAeuVtyk1aUV9o2zPt
         8adfceDZnhIic2P86lbsc9zTTMY+8QvXgruFRZ5Chj9t2asuwJ6NKokTXonV/w/7OHYV
         Z4ofTWirhQXrXP3rdasleixARud9SzpTDfJqS+OIMYbCAcH3KdWHmSWYlZBhWh8+/4H7
         zeGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id oc23si6987058ejb.369.2019.07.23.23.05.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Jul 2019 23:05:37 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.200;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay7-d.mail.gandi.net (Postfix) with ESMTPSA id 7E8472000C;
	Wed, 24 Jul 2019 06:05:32 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH REBASE v4 06/14] arm: Properly account for stack randomization and stack guard gap
Date: Wed, 24 Jul 2019 01:58:42 -0400
Message-Id: <20190724055850.6232-7-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190724055850.6232-1-alex@ghiti.fr>
References: <20190724055850.6232-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This commit takes care of stack randomization and stack guard gap when
computing mmap base address and checks if the task asked for randomization.
This fixes the problem uncovered and not fixed for arm here:
https://lkml.kernel.org/r/20170622200033.25714-1-riel@redhat.com

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Kees Cook <keescook@chromium.org>
---
 arch/arm/mm/mmap.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
index f866870db749..bff3d00bda5b 100644
--- a/arch/arm/mm/mmap.c
+++ b/arch/arm/mm/mmap.c
@@ -18,8 +18,9 @@
 	 (((pgoff)<<PAGE_SHIFT) & (SHMLBA-1)))
 
 /* gap between mmap and stack */
-#define MIN_GAP (128*1024*1024UL)
-#define MAX_GAP ((TASK_SIZE)/6*5)
+#define MIN_GAP		(128*1024*1024UL)
+#define MAX_GAP		((TASK_SIZE)/6*5)
+#define STACK_RND_MASK	(0x7ff >> (PAGE_SHIFT - 12))
 
 static int mmap_is_legacy(struct rlimit *rlim_stack)
 {
@@ -35,6 +36,15 @@ static int mmap_is_legacy(struct rlimit *rlim_stack)
 static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 {
 	unsigned long gap = rlim_stack->rlim_cur;
+	unsigned long pad = stack_guard_gap;
+
+	/* Account for stack randomization if necessary */
+	if (current->flags & PF_RANDOMIZE)
+		pad += (STACK_RND_MASK << PAGE_SHIFT);
+
+	/* Values close to RLIM_INFINITY can overflow. */
+	if (gap + pad > gap)
+		gap += pad;
 
 	if (gap < MIN_GAP)
 		gap = MIN_GAP;
-- 
2.20.1

