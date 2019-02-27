Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9B52C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:06:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B18CE20842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:06:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B18CE20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 516BA8E0005; Wed, 27 Feb 2019 12:06:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C5C78E0001; Wed, 27 Feb 2019 12:06:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31E028E0005; Wed, 27 Feb 2019 12:06:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C9CB68E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:06:34 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d31so7236708eda.1
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:06:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6FoKm4T/vulm4WLeNhgEiUXQspfPhFcFQ9eklNtsPfA=;
        b=I/F3zalIatLP+CQBuBzSY2FXkzOzolVD/SQ6zNaaMn67Snpq7hGx6PYUP4VFyZ5tXF
         38+vgexeJKzFze4x607UM4oEnB6mPZ8kZp6J9SoMN9BCORQGTcxWTic93o4WAzCafdzd
         Yh7+8wbHy665+Wuq7xIaZdPP71vX2NIr77J3vCJigV3rQJ3WhE8P5JFfZHOOQsAfM5XD
         aDJh1qCiGzoV0pZrwOZI1DEqwfPc8mSCS6xlw204zbvbWHmc0hi/Svy7UZyKbULYJDsk
         HeWFAeMCdlSusCdw/ywKKc8+tybKmZ5f54fdj0QvfFQ7jkUHuiv7E3eTlUAxGIf31sEn
         cU+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuZx6uGirf4re7anvW1ZvfIwTFGbkfYQ0KWhvIL7SzVwYkyM3Hkb
	FE8ExVlgPCjU8xsMMPC52n+dcTIhJFODSPT2X5CPW+UpYZDpt5PKdjiHk6xl7xP5He15Xh2hjYa
	SDMySJ6qxQiNncJ4X8zdj10ci5juc22bCM6nTK7KS0rxFoNkov6LzbEFPFEjL5s9fpw==
X-Received: by 2002:a17:906:7621:: with SMTP id c1mr2294852ejn.47.1551287194278;
        Wed, 27 Feb 2019 09:06:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZStC6IxWqlAsK3JascZaVoxTQV1z77068N3ylgXF8NbWZw7KMWYjO4gGmltbnCyUZPK56e
X-Received: by 2002:a17:906:7621:: with SMTP id c1mr2294798ejn.47.1551287193264;
        Wed, 27 Feb 2019 09:06:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287193; cv=none;
        d=google.com; s=arc-20160816;
        b=GJHqMLljhpVBZMvT/MSt8ecE46ouUWlSf0xj+6K3x5eBvDPJ93a6+J6f+hxB/hxIX6
         xPizgTCogGyRhyIXXP6gA1cCtCg7JWx9GUHJmDcWx7eRFPpdvyig2VhN+CM1GIiztdtt
         CyRqD7M/MwBqkmE8p5tOPVYdWKnFzBIu89lCSRio4tI1ztOuu8j3RXPPgfa+qAU4nudZ
         B5jPjacHTJWqzt+hQEkKKpgwEJSrIU7GPLMFEl5BTLT1+/bLewOGRG1vjU9AZc5LeiSp
         RJkOhRzteEKmvUYvGiEf+pzuuUJu2obMEPfj1wG/twW7EbsRidoEmbwe7nrmHFvkT19Q
         m8Kg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=6FoKm4T/vulm4WLeNhgEiUXQspfPhFcFQ9eklNtsPfA=;
        b=A4IHDSFTVAWUCIFpNWjMV8rs+8gR+PQIRcqzWy6ig8UxRlkma63CuuEwja26pYLqQR
         YaDEVMiLN2RSBYHse3ybcLtXJ8YqbJFewZX48fHEgzw0mLWKbD+HJwTPqmkwlpOj7zP7
         FBRHzu4btiUXCfseABjG9/j1pN+Ib0KCVkm9xq7PJmOerWXRi50cWF6h2GMGj1ZWRoR6
         zHeqEo/mKLCObBH8Yz9QHrorHIM1FeB4iE4Xz+XSFLSvo6RHhjZB9n6a/pAiXZ3jzJ0Z
         kdjdZlFZDDFeK0WBbKLO7gYEhQRK5wbhNuYkuqsJWHzl/j6h8P1o4nLQT3lWebnAEfeq
         oHhw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n30si5344087edd.3.2019.02.27.09.06.32
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:06:33 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2E2BD1684;
	Wed, 27 Feb 2019 09:06:32 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5A1D23F738;
	Wed, 27 Feb 2019 09:06:28 -0800 (PST)
From: Steven Price <steven.price@arm.com>
To: linux-mm@kvack.org
Cc: Steven Price <steven.price@arm.com>,
	Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	James Morse <james.morse@arm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	linux-alpha@vger.kernel.org,
	Richard Henderson <rth@twiddle.net>,
	Ivan Kokshaysky <ink@jurassic.park.msu.ru>,
	Matt Turner <mattst88@gmail.com>
Subject: [PATCH v3 01/34] alpha: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:35 +0000
Message-Id: <20190227170608.27963-2-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190227170608.27963-1-steven.price@arm.com>
References: <20190227170608.27963-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

walk_page_range() is going to be allowed to walk page tables other than
those of user space. For this it needs to know when it has reached a
'leaf' entry in the page tables. This information will be provided by the
p?d_large() functions/macros.

For alpha, we don't support huge pages, so add stubs returning 0.

CC: linux-alpha@vger.kernel.org
CC: Richard Henderson <rth@twiddle.net>
CC: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
CC: Matt Turner <mattst88@gmail.com>
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/alpha/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/alpha/include/asm/pgtable.h b/arch/alpha/include/asm/pgtable.h
index 89c2032f9960..e5726d3a3200 100644
--- a/arch/alpha/include/asm/pgtable.h
+++ b/arch/alpha/include/asm/pgtable.h
@@ -254,11 +254,13 @@ extern inline void pte_clear(struct mm_struct *mm, unsigned long addr, pte_t *pt
 extern inline int pmd_none(pmd_t pmd)		{ return !pmd_val(pmd); }
 extern inline int pmd_bad(pmd_t pmd)		{ return (pmd_val(pmd) & ~_PFN_MASK) != _PAGE_TABLE; }
 extern inline int pmd_present(pmd_t pmd)	{ return pmd_val(pmd) & _PAGE_VALID; }
+extern inline int pmd_large(pmd_t pmd)		{ return 0; }
 extern inline void pmd_clear(pmd_t * pmdp)	{ pmd_val(*pmdp) = 0; }
 
 extern inline int pgd_none(pgd_t pgd)		{ return !pgd_val(pgd); }
 extern inline int pgd_bad(pgd_t pgd)		{ return (pgd_val(pgd) & ~_PFN_MASK) != _PAGE_TABLE; }
 extern inline int pgd_present(pgd_t pgd)	{ return pgd_val(pgd) & _PAGE_VALID; }
+extern inline int pgd_large(pgd_t pgd)		{ return 0; }
 extern inline void pgd_clear(pgd_t * pgdp)	{ pgd_val(*pgdp) = 0; }
 
 /*
-- 
2.20.1

