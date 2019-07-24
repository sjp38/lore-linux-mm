Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 589ECC7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:07:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B517227BF
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:07:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B517227BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF94A6B0008; Wed, 24 Jul 2019 02:07:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B83058E0003; Wed, 24 Jul 2019 02:07:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A229F8E0002; Wed, 24 Jul 2019 02:07:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4F8C36B0008
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:07:50 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n3so29540116edr.8
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:07:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pg2c2GGboO97HgSLIQoHM8sYbl0vdbpaZETgXWDAdW4=;
        b=UTMf1VbYWxx+KE22c4bkRQz+UugArtubFGrZI9cEb3c0eFhez0o4B9MaroQ8BenfVi
         RGjqhLG4RK64dVjEUJ2DKKwdfpnB/fwu5816G1RpkwyWtDyaS2u0CvRXcWDizbFu+uAH
         ZEm/Ct+xCeAfQjPLBdPZirkwbqjAK3JzrMC8DjaFySootROALyFmoSGfx1puGXmiDQDg
         3K8761/MsTuP9azRlz+Sisfdj8slUrPvg82mIfBqKbdoiuB5gLhMWIwrSOY/2rhL7V1x
         Op0WslRW39Do0KdhzaZIyyKEjGfDSm75aPscSdN3a/2S7bEwAu/IpfAcsrYon3Iem0T4
         Jv2Q==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUo3DAKZJDrTwJIzhZVOFcs/qbMLk9QzjMeeTnRuCtsiOAISCZl
	YHuTz/n9bryV+S7ZlS+yDQOF5DesaQP9zhpgLTG8W+pgax4nMrzeoSflCj653C83CKH7DTIrHHx
	dMUYLpYphS5BbOP0vKVcGUsVVBbgHdexDPHrnq4tYhfa866Up9vvc9+ULWFqOGOY=
X-Received: by 2002:a17:906:94ce:: with SMTP id d14mr62584514ejy.251.1563948469877;
        Tue, 23 Jul 2019 23:07:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx6qoHA7gelOe68yU1ghsrRoHKyRUeADjy7QN1AOKPOY76gPIj+p6xpHh4tHv+DMKBbQNaO
X-Received: by 2002:a17:906:94ce:: with SMTP id d14mr62584434ejy.251.1563948468193;
        Tue, 23 Jul 2019 23:07:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563948468; cv=none;
        d=google.com; s=arc-20160816;
        b=Cmj8NlwI3l+48Y65jO3usZxXV0m07q/UZzlEvf19sSJr3g+Ix4lEAUSLOPDEqqy7SP
         pTMbyZ+rYSL62AwhpBJjMjjJmFPvvaf9tylMwPvz1wqAy2ztVrUzrxIV7WOYBSJ/Ink1
         qdmBoGhcQKRfV4f5On1xEqaFVm/NQPRj56QmtisxAFvPEejGumFMC0w9xtKSHYAkdRgf
         RBtfUXkt60SdeAxqDg5nng/OJvGWsbt1d+10slLsEbW2SaKYaxtpXWq9Jkqzvg5Jz2Bz
         K1rqKddyrqL88laGUzqyodZCR5pVBWDlp9l7HeX5fzuAolcivdRUfZQDfyK3R+uRCv/0
         epZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=pg2c2GGboO97HgSLIQoHM8sYbl0vdbpaZETgXWDAdW4=;
        b=M3QDQpKACAfD3vYKQj4Zayg2dIcVJDeF6L1g/JQGCrTUrbXyy8UbLnFlfpa+mK4jWL
         QzH6y+J5EACUdL+BhPbUgg6FwZRhQakArT/E8WO5tDMlR7opBVhmcl+2YuNwRJGYjHAe
         D21X7PxHIN6iDNbochdCmZhPKC4YNCxdXytoX10ESnDRKZxYhzS2/XogA1QAf+qgzkHT
         sZXKXuG2lhdrkI6KtpFwrWDB9JICiw5CeRBLkwO/mvrQZ2tEcD8ycae1KQs54avE6TNa
         XDuWtWoyc9RF2z46fzBdsMx/7ylLkhf4I/62l9QolleBW4dkZ7RF1ba3mGQodLf61iW7
         Vz8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [217.70.183.196])
        by mx.google.com with ESMTPS id hh20si7037670ejb.240.2019.07.23.23.07.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Jul 2019 23:07:48 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.196;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 389EFE0007;
	Wed, 24 Jul 2019 06:07:43 +0000 (UTC)
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
Subject: [PATCH REBASE v4 08/14] arm: Use generic mmap top-down layout and brk randomization
Date: Wed, 24 Jul 2019 01:58:44 -0400
Message-Id: <20190724055850.6232-9-alex@ghiti.fr>
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

arm uses a top-down mmap layout by default that exactly fits the generic
functions, so get rid of arch specific code and use the generic version
by selecting ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT.
As ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT selects ARCH_HAS_ELF_RANDOMIZE,
use the generic version of arch_randomize_brk since it also fits.
Note that this commit also removes the possibility for arm to have elf
randomization and no MMU: without MMU, the security added by randomization
is worth nothing.
Note that it is safe to remove STACK_RND_MASK since it matches the default
value.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Kees Cook <keescook@chromium.org>
---
 arch/arm/Kconfig                 |  2 +-
 arch/arm/include/asm/processor.h |  2 --
 arch/arm/kernel/process.c        |  5 ---
 arch/arm/mm/mmap.c               | 62 --------------------------------
 4 files changed, 1 insertion(+), 70 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 33b00579beff..81b08b027e4e 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -7,7 +7,6 @@ config ARM
 	select ARCH_HAS_BINFMT_FLAT
 	select ARCH_HAS_DEBUG_VIRTUAL if MMU
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
-	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_KEEPINITRD
 	select ARCH_HAS_KCOV
@@ -30,6 +29,7 @@ config ARM
 	select ARCH_SUPPORTS_ATOMIC_RMW
 	select ARCH_USE_BUILTIN_BSWAP
 	select ARCH_USE_CMPXCHG_LOCKREF
+	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
 	select ARCH_WANT_IPC_PARSE_VERSION
 	select BINFMT_FLAT_ARGVP_ENVP_ON_STACK
 	select BUILDTIME_EXTABLE_SORT if MMU
diff --git a/arch/arm/include/asm/processor.h b/arch/arm/include/asm/processor.h
index 20c2f42454b8..614bf829e454 100644
--- a/arch/arm/include/asm/processor.h
+++ b/arch/arm/include/asm/processor.h
@@ -140,8 +140,6 @@ static inline void prefetchw(const void *ptr)
 #endif
 #endif
 
-#define HAVE_ARCH_PICK_MMAP_LAYOUT
-
 #endif
 
 #endif /* __ASM_ARM_PROCESSOR_H */
diff --git a/arch/arm/kernel/process.c b/arch/arm/kernel/process.c
index f934a6739fc0..9485acc520a4 100644
--- a/arch/arm/kernel/process.c
+++ b/arch/arm/kernel/process.c
@@ -319,11 +319,6 @@ unsigned long get_wchan(struct task_struct *p)
 	return 0;
 }
 
-unsigned long arch_randomize_brk(struct mm_struct *mm)
-{
-	return randomize_page(mm->brk, 0x02000000);
-}
-
 #ifdef CONFIG_MMU
 #ifdef CONFIG_KUSER_HELPERS
 /*
diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
index 0b94b674aa91..b8d912ac9e61 100644
--- a/arch/arm/mm/mmap.c
+++ b/arch/arm/mm/mmap.c
@@ -17,43 +17,6 @@
 	((((addr)+SHMLBA-1)&~(SHMLBA-1)) +	\
 	 (((pgoff)<<PAGE_SHIFT) & (SHMLBA-1)))
 
-/* gap between mmap and stack */
-#define MIN_GAP		(128*1024*1024UL)
-#define MAX_GAP		((STACK_TOP)/6*5)
-#define STACK_RND_MASK	(0x7ff >> (PAGE_SHIFT - 12))
-
-static int mmap_is_legacy(struct rlimit *rlim_stack)
-{
-	if (current->personality & ADDR_COMPAT_LAYOUT)
-		return 1;
-
-	if (rlim_stack->rlim_cur == RLIM_INFINITY)
-		return 1;
-
-	return sysctl_legacy_va_layout;
-}
-
-static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
-{
-	unsigned long gap = rlim_stack->rlim_cur;
-	unsigned long pad = stack_guard_gap;
-
-	/* Account for stack randomization if necessary */
-	if (current->flags & PF_RANDOMIZE)
-		pad += (STACK_RND_MASK << PAGE_SHIFT);
-
-	/* Values close to RLIM_INFINITY can overflow. */
-	if (gap + pad > gap)
-		gap += pad;
-
-	if (gap < MIN_GAP)
-		gap = MIN_GAP;
-	else if (gap > MAX_GAP)
-		gap = MAX_GAP;
-
-	return PAGE_ALIGN(STACK_TOP - gap - rnd);
-}
-
 /*
  * We need to ensure that shared mappings are correctly aligned to
  * avoid aliasing issues with VIPT caches.  We need to ensure that
@@ -181,31 +144,6 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	return addr;
 }
 
-unsigned long arch_mmap_rnd(void)
-{
-	unsigned long rnd;
-
-	rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
-
-	return rnd << PAGE_SHIFT;
-}
-
-void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
-{
-	unsigned long random_factor = 0UL;
-
-	if (current->flags & PF_RANDOMIZE)
-		random_factor = arch_mmap_rnd();
-
-	if (mmap_is_legacy(rlim_stack)) {
-		mm->mmap_base = TASK_UNMAPPED_BASE + random_factor;
-		mm->get_unmapped_area = arch_get_unmapped_area;
-	} else {
-		mm->mmap_base = mmap_base(random_factor, rlim_stack);
-		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
-	}
-}
-
 /*
  * You really shouldn't be using read() or write() on /dev/mem.  This
  * might go away in the future.
-- 
2.20.1

