Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B800C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A1A621852
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A1A621852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC8B08E0013; Wed, 27 Feb 2019 12:07:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4F048E0001; Wed, 27 Feb 2019 12:07:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C404C8E0013; Wed, 27 Feb 2019 12:07:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 663ED8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:07:28 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id j5so7174273edt.17
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:07:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cpDv3mBvbD8hNAclYHZlrnWhwlRtUYmq/kJWE5bqZAU=;
        b=lzTvF9xqZHFg1zRAIRkMPxun0kNFQN9y+9FdVwPCv+TOLaugLg4cue9z4svU0FgYtj
         Iiud3+PRxxAOI76cFISyKUjdMbd1EYfUAID8GsYpgg112vzv6olH+pDw+w1KCw03d5Al
         H5mGR/xfSSjQMExvTXzOtvKiwHQxYz07CobdIbl0o5hViQ9NVcT2KmPhOdsDqtg/d4k5
         8zqJCqxS6OheinnyZPEdkQVrOEoOxaOxjNNd70+vUiC0mRM8YT0oaW1488+lcv+oPd0n
         Nnw+wyXGOkQcym/4BH1VlYl2iF2hr6ezvTn/iQXst5tybUqnRCFFBWlWfKxCZVhYjdFf
         toKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuYh0loDrxwnTokBQEAaqM/dg8umgJkU14ykdBliPvQNALZkOuvx
	+KfvVgjjZTo3QveKAZ5higCwRvGkBLvTce8tFztQu9rjWzCUDsUOrlTkbGmbftXuzdRh3NxG2IX
	zRcAqLAks3xqChS+KdGtkKl/O8XMuhtO4YRUarGxSu5xDGsNutQEFpWIjpT6ECtUSCg==
X-Received: by 2002:a50:87dc:: with SMTP id 28mr3116923edz.168.1551287247918;
        Wed, 27 Feb 2019 09:07:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbsrV5f/Puav7WGgkksBLsniEWetIgIebu5OlDmCAIO6ZMMGL/tTA9Fxa4Nr1dBiG7ZObqp
X-Received: by 2002:a50:87dc:: with SMTP id 28mr3116833edz.168.1551287246455;
        Wed, 27 Feb 2019 09:07:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287246; cv=none;
        d=google.com; s=arc-20160816;
        b=y/wG0xcwN/BVEPRrBzR+j1ADBCOk3Z/YZf0VAffD6uwnDoOxxqlhTZwEfiYao2bmzw
         g+ofsBZHk4PrHx7k2SE6l4yPqtUKhLGXgghAmGz4cVRyp0cetB8YgVVDCQXdeKyqBFaW
         0S5ZvT8nry6BAE4R2ij+zFBhCJHS0ye4awG6/lBruQTpAdTu78wg8iEUgMgSsb2mBGiW
         zKdC49xxY23cW8HZ4wlOW30PjyVZxxToiz8aUx0RM2Y4p3fn1oLznLAnrhP+cAZzE6s+
         jZyjGWJgtmjW6pUkU5lT8rFcecvrr4cwuarkcOuWGjell99Px/+dc8WWbvn75vYMpmxm
         +F2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=cpDv3mBvbD8hNAclYHZlrnWhwlRtUYmq/kJWE5bqZAU=;
        b=XefyUf0I1ptzBG+SeH18rilJEwFvmvYbb+vD0Vr4b1pQVVLHBBsH6/d5v3g1MurbWT
         oQQu6GAtpZb89Vpb79xlZDdyvHNeHzOe7znLK7qZfvpQaEdX5F42oWMl1laCzQQyK4F4
         IdK1cgju46Y3tV7gSMbDNa/na2SY13OlKP3vjAI4unvBft2XC73Kw/raLohEFT2Nz7M1
         py8y8mmJjezGWnpD7keqOgGUrw2C3NysT4KsF72Fdni0Fnq8rsD5Am+LaG9PxyQdZGyB
         kM23/2js2OSPQzdeYiuPPC2+jvpUhGIoAKX47wvmnKEl4MMKd7DHSddIJ4T71ws8fS1G
         DLSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n21si2345155eja.150.2019.02.27.09.07.26
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:07:26 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8FFCD1688;
	Wed, 27 Feb 2019 09:07:25 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id DEAE63F738;
	Wed, 27 Feb 2019 09:07:21 -0800 (PST)
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
	"James E.J. Bottomley" <jejb@parisc-linux.org>,
	Helge Deller <deller@gmx.de>,
	linux-parisc@vger.kernel.org
Subject: [PATCH v3 15/34] parisc: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:49 +0000
Message-Id: <20190227170608.27963-16-steven.price@arm.com>
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
'leaf' entry in the page tables. This information is provided by the
p?d_large() functions/macros.

For parisc, we don't support large pages, so add stubs returning 0.

CC: "James E.J. Bottomley" <jejb@parisc-linux.org>
CC: Helge Deller <deller@gmx.de>
CC: linux-parisc@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/parisc/include/asm/pgtable.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/parisc/include/asm/pgtable.h b/arch/parisc/include/asm/pgtable.h
index c7bb74e22436..1f38c85a9530 100644
--- a/arch/parisc/include/asm/pgtable.h
+++ b/arch/parisc/include/asm/pgtable.h
@@ -302,6 +302,7 @@ extern unsigned long *empty_zero_page;
 #endif
 #define pmd_bad(x)	(!(pmd_flag(x) & PxD_FLAG_VALID))
 #define pmd_present(x)	(pmd_flag(x) & PxD_FLAG_PRESENT)
+#define pmd_large(x)	(0)
 static inline void pmd_clear(pmd_t *pmd) {
 #if CONFIG_PGTABLE_LEVELS == 3
 	if (pmd_flag(*pmd) & PxD_FLAG_ATTACHED)
@@ -324,6 +325,7 @@ static inline void pmd_clear(pmd_t *pmd) {
 #define pgd_none(x)     (!pgd_val(x))
 #define pgd_bad(x)      (!(pgd_flag(x) & PxD_FLAG_VALID))
 #define pgd_present(x)  (pgd_flag(x) & PxD_FLAG_PRESENT)
+#define pgd_large(x)	(0)
 static inline void pgd_clear(pgd_t *pgd) {
 #if CONFIG_PGTABLE_LEVELS == 3
 	if(pgd_flag(*pgd) & PxD_FLAG_ATTACHED)
@@ -342,6 +344,7 @@ static inline void pgd_clear(pgd_t *pgd) {
 static inline int pgd_none(pgd_t pgd)		{ return 0; }
 static inline int pgd_bad(pgd_t pgd)		{ return 0; }
 static inline int pgd_present(pgd_t pgd)	{ return 1; }
+static inline int pgd_large(pgd_t pgd)		{ return 0; }
 static inline void pgd_clear(pgd_t * pgdp)	{ }
 #endif
 
-- 
2.20.1

