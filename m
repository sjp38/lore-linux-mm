Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C204C41514
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:25:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20E5F20B7C
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:25:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20E5F20B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1F196B0006; Thu,  8 Aug 2019 02:25:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCEF06B000A; Thu,  8 Aug 2019 02:25:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A98406B000C; Thu,  8 Aug 2019 02:25:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5D0B66B0006
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 02:25:47 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z20so57620887edr.15
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 23:25:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WYZFBi/mDjw2AHO/7J+UsrC2CAAthlR5mqmiph32kXg=;
        b=sBww0825ToerOtv5Q47enaM8tT4Q9VdvOoMxgUT2jgsWlWteXCOGUbF66RNtcNcduX
         zxQnj6tEuvsOn7bq+m1G0F48SGZ6phKLP1St0LJ8lwm/E95vkD+N9li2a0YkYapvaSer
         pSNK809VJbItb/RRvGzBO0qau4ag/UlEEAMeTTlkqSLgpEd4ay33otW7JTo1hkf6d9FT
         bn47iS03VnfMtvzR/gPnPgzQX+lA4OmJlU2MkTr8Bj0SrWPadWHckiCFR91k7yXHPQoX
         AvdWbM8wjOU+sWiCML9YVP8CVwEib3VqpoWSSwD1x45hcbvD+wvNMoBaW+r2dq04gF9V
         ZfXw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWgT1qPZUMkNguNKCqJgrwrYKf3oOAxfdM5FZgpnWrXYKdwDl8F
	BKrE+2qvzXayeIX4K8uwbtAHVkQ2cYvjBg+VYib+NJDRj4VQ1BzhOJVniKluKVPZR8MWAqFQyof
	Xoc6/kxG3B/6c0frGuSQqqiFGYeJUjpCyvVf0Nr3B08dDyIINv8uPi72OQ7ARALI=
X-Received: by 2002:a17:906:eb8d:: with SMTP id mh13mr1410653ejb.98.1565245546962;
        Wed, 07 Aug 2019 23:25:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8O3pSi2r+Y9fWiqVF+T1OMv3pGRHRmG37zj3bKLcLf0duJwusD9/MiveOIA6KEmFXr+Mw
X-Received: by 2002:a17:906:eb8d:: with SMTP id mh13mr1410631ejb.98.1565245546289;
        Wed, 07 Aug 2019 23:25:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565245546; cv=none;
        d=google.com; s=arc-20160816;
        b=r5azZ9l6/trcvXUZk+kRe7fDPIuR8xQSiyRf3Juoma9eRWFAVdTEGuXRu9eThmZG9O
         Psnp2sO3IHCpgA4vkl2/CojTtx1mcu9K+wj83d9jLBNXNQ3zMGIsaivlzh0tQWQ/r9ha
         m2ehvOFSlA2P+l7G7LzQkWTh/dviuTArcbKdrdyJY85FgmQbtmW9YR4mpLImf1Hn8u+U
         m5AI9SLy14t5WgpBLlW/pcPwmViL/WggLd3ngENnLsPV9mvDJ2gwsbpqkKAsCBVJGTGe
         ksttMYLa69sVR60Ox55vReJGm1T237CeiCUKlhaIHIdeP6rpBIF3GpT56bigc8yavJKs
         DzLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=WYZFBi/mDjw2AHO/7J+UsrC2CAAthlR5mqmiph32kXg=;
        b=QgNbX9qPSiqJu9pnbJLxVOfXioxPBSDSbAcheIdsZm9IG7P9cgM5pcI88iUYIzkU6L
         uJCB+SIYOnO/b2tveF9d71MVf/EtaWaVEQSrYhuVbkhhnkOxJP6R3gWC13OqKU0KyxJf
         ftqn2gF7jrcqIqUahX1u8aqJ+Gu7ScmDJVBoHkgJ6oxDDaYmr3zb+fxykCoYNTu+lYLi
         25drCAbskSyV+QblZEajWAYsD4c8sGVAizw9U7kRSyxlbkpOiM3Iva1xgqA7HFhYboqo
         5pSEQl2cPwRCj+UPUNNQehLY3kiLB5rSk9WAcbRtVBxtXgf8RjgnCec48HEy1rMJ3m3/
         fMng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay11.mail.gandi.net (relay11.mail.gandi.net. [217.70.178.231])
        by mx.google.com with ESMTPS id oq6si30989417ejb.160.2019.08.07.23.25.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Aug 2019 23:25:46 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.231;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay11.mail.gandi.net (Postfix) with ESMTPSA id 4A8C8100003;
	Thu,  8 Aug 2019 06:25:40 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Walmsley <paul.walmsley@sifive.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v6 07/14] arm: Use STACK_TOP when computing mmap base address
Date: Thu,  8 Aug 2019 02:17:49 -0400
Message-Id: <20190808061756.19712-8-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190808061756.19712-1-alex@ghiti.fr>
References: <20190808061756.19712-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

mmap base address must be computed wrt stack top address, using TASK_SIZE
is wrong since STACK_TOP and TASK_SIZE are not equivalent.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
---
 arch/arm/mm/mmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
index bff3d00bda5b..0b94b674aa91 100644
--- a/arch/arm/mm/mmap.c
+++ b/arch/arm/mm/mmap.c
@@ -19,7 +19,7 @@
 
 /* gap between mmap and stack */
 #define MIN_GAP		(128*1024*1024UL)
-#define MAX_GAP		((TASK_SIZE)/6*5)
+#define MAX_GAP		((STACK_TOP)/6*5)
 #define STACK_RND_MASK	(0x7ff >> (PAGE_SHIFT - 12))
 
 static int mmap_is_legacy(struct rlimit *rlim_stack)
@@ -51,7 +51,7 @@ static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 	else if (gap > MAX_GAP)
 		gap = MAX_GAP;
 
-	return PAGE_ALIGN(TASK_SIZE - gap - rnd);
+	return PAGE_ALIGN(STACK_TOP - gap - rnd);
 }
 
 /*
-- 
2.20.1

