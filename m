Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 932A9C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:32:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 418DE217F4
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:32:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 418DE217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CF0F6B0006; Thu,  8 Aug 2019 02:32:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 980316B000C; Thu,  8 Aug 2019 02:32:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8208F6B000D; Thu,  8 Aug 2019 02:32:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3285A6B0006
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 02:32:21 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k22so57620712ede.0
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 23:32:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ai6tRv6NH7TtSvQbIJYxYKlls6rj+pPySz74OsUl8/s=;
        b=f1aAnehj3K4Q7uce0nuwv/HtjQnk1EOfNwQA5Zj7KZ8AerSw2SpDQZS0ibuMj8PEKe
         pFDZ80bPGmI20xFl2dSuxHf7N4/p34w5YAH6p+jRrEzflQs08NilfiJWn+DRqSIs0Wsw
         8qU57lQvKd3XscPOv8OxJu8XNJu60RFAXn0PPkHpNZZzdY1Nx7xUW6v4XJDg2T4slhhX
         zO/otoiZNiMTLkpjlHGzEN5S8zRhpwUJkfZRRyj68yrMJCuFKd3mw0KOX999Dh9T4+L1
         mjcnU7+kvtpm71HG/RBIu3rEJs1MbH9LTtniwF4tESMSambadkoupvGr16NcL4vhqGDA
         tBaQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAV0jIswEKPFAILne/OKD4DY9BOv7/UnwvZBdIJ2cPlGhDWK9ZMr
	nkhdX+M/IVzg+Ynpbjp7574eQ72nyZ0LBrmccLVjQgYs3JgYu58jKygIH/wljOVJw8/wq08m0zE
	BAlxGsncyPov0Rr0Ti+wrflfudK8RUwRxVlJ1yvplWlP5INklfEhx9TeBUw/vefQ=
X-Received: by 2002:a17:906:7d12:: with SMTP id u18mr11637444ejo.24.1565245940757;
        Wed, 07 Aug 2019 23:32:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHvBMg2J+mRp3htAoG94lcJ+3/ZedNGVYgBBt4NfvY1fpCR+lfHEBCnF7CXaQQNOXjP/9Q
X-Received: by 2002:a17:906:7d12:: with SMTP id u18mr11637377ejo.24.1565245939297;
        Wed, 07 Aug 2019 23:32:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565245939; cv=none;
        d=google.com; s=arc-20160816;
        b=YKOBACTIxHWMhw4GFR11T8ZChzVv/LWVAPJ5hNK95vcHc00dPrJLFNr9ffk+LbV/0h
         59ZCsphswy6I6kMghwMttQVFZLGdRJUbKG+OMsByrY4PWyTLMkUwGyOrrrjGMFPW0Asn
         mAsV1cH/wZf4E5K9IZUNVACkoGz/axPKKc94Z08ZCreRFBf3/86FHQfGVpF2G2NDNsHA
         i/H5nvd4r0NrHXCzGYNgEdlth2THF1Tjcr7wA14/z96U3LhKQPfMwtqSs2kNWlJovBS7
         Pxe6aQjBbks9YUNQxESW1LjJJkh8IdVZZYZCEcBr0GET99oRUULVp0EHKuMqHoTo8hKH
         FZHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ai6tRv6NH7TtSvQbIJYxYKlls6rj+pPySz74OsUl8/s=;
        b=WtQGGi8brwpyNwXHzCpc0MR6L53nyOSVMy0C4QIWb4RHRf+DwykjmSIsKVKJAxrB0I
         FjEh0r5NLv3v0mJjLYQrzfw0Xz969WgpfMlAG0baDGc1LtGbnQf1lDq1JX1Le6f769lO
         83D5LbTZ22WglARtMU/+aAQEy5TUmYLEFP4aUEiDB7JD6CgGa2ERr04x8l7QDyzAd/Rp
         uk2V2R2yMrNqNsfDbSjEPCiTJX6QW3SsVgDARaR7sYlYx65pokqIC0bpRENraVykVD5b
         lYN0Skjj0uJgKNAoou4rF6tum9g36QlIPDDrWxbpbGOpsgiQU6S5gARHD8q820SeDgif
         zIrg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id k24si31378163ejz.188.2019.08.07.23.32.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Aug 2019 23:32:19 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id B4C8060004;
	Thu,  8 Aug 2019 06:32:14 +0000 (UTC)
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
Subject: [PATCH v6 13/14] mips: Use generic mmap top-down layout and brk randomization
Date: Thu,  8 Aug 2019 02:17:55 -0400
Message-Id: <20190808061756.19712-14-alex@ghiti.fr>
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

mips uses a top-down layout by default that exactly fits the generic
functions, so get rid of arch specific code and use the generic version
by selecting ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT.

As ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT selects ARCH_HAS_ELF_RANDOMIZE,
use the generic version of arch_randomize_brk since it also fits.

Note that this commit also removes the possibility for mips to have elf
randomization and no MMU: without MMU, the security added by randomization
is worth nothing.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Paul Burton <paul.burton@mips.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
---
 arch/mips/Kconfig                 |  2 +-
 arch/mips/include/asm/processor.h |  5 --
 arch/mips/mm/mmap.c               | 96 -------------------------------
 3 files changed, 1 insertion(+), 102 deletions(-)

diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index d50fafd7bf3a..4e85d7d2cf1a 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -5,7 +5,6 @@ config MIPS
 	select ARCH_32BIT_OFF_T if !64BIT
 	select ARCH_BINFMT_ELF_STATE if MIPS_FP_SUPPORT
 	select ARCH_CLOCKSOURCE_DATA
-	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
 	select ARCH_SUPPORTS_UPROBES
@@ -13,6 +12,7 @@ config MIPS
 	select ARCH_USE_CMPXCHG_LOCKREF if 64BIT
 	select ARCH_USE_QUEUED_RWLOCKS
 	select ARCH_USE_QUEUED_SPINLOCKS
+	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
 	select ARCH_WANT_IPC_PARSE_VERSION
 	select BUILDTIME_EXTABLE_SORT
 	select CLONE_BACKWARDS
diff --git a/arch/mips/include/asm/processor.h b/arch/mips/include/asm/processor.h
index aca909bd7841..fba18d4a9190 100644
--- a/arch/mips/include/asm/processor.h
+++ b/arch/mips/include/asm/processor.h
@@ -29,11 +29,6 @@
 
 extern unsigned int vced_count, vcei_count;
 
-/*
- * MIPS does have an arch_pick_mmap_layout()
- */
-#define HAVE_ARCH_PICK_MMAP_LAYOUT 1
-
 #ifdef CONFIG_32BIT
 #ifdef CONFIG_KVM_GUEST
 /* User space process size is limited to 1GB in KVM Guest Mode */
diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index d5106c26ac6a..00fe90c6db3e 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -16,49 +16,10 @@
 #include <linux/random.h>
 #include <linux/sched/signal.h>
 #include <linux/sched/mm.h>
-#include <linux/sizes.h>
-#include <linux/compat.h>
 
 unsigned long shm_align_mask = PAGE_SIZE - 1;	/* Sane caches */
 EXPORT_SYMBOL(shm_align_mask);
 
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
 #define COLOUR_ALIGN(addr, pgoff)				\
 	((((addr) + shm_align_mask) & ~shm_align_mask) +	\
 	 (((pgoff) << PAGE_SHIFT) & shm_align_mask))
@@ -156,63 +117,6 @@ unsigned long arch_get_unmapped_area_topdown(struct file *filp,
 			addr0, len, pgoff, flags, DOWN);
 }
 
-unsigned long arch_mmap_rnd(void)
-{
-	unsigned long rnd;
-
-#ifdef CONFIG_COMPAT
-	if (TASK_IS_32BIT_ADDR)
-		rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
-	else
-#endif /* CONFIG_COMPAT */
-		rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
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
-static inline unsigned long brk_rnd(void)
-{
-	unsigned long rnd = get_random_long();
-
-	rnd = rnd << PAGE_SHIFT;
-	/* 32MB for 32bit, 1GB for 64bit */
-	if (!IS_ENABLED(CONFIG_64BIT) || is_compat_task())
-		rnd = rnd & (SZ_32M - 1);
-	else
-		rnd = rnd & (SZ_1G - 1);
-
-	return rnd;
-}
-
-unsigned long arch_randomize_brk(struct mm_struct *mm)
-{
-	unsigned long base = mm->brk;
-	unsigned long ret;
-
-	ret = PAGE_ALIGN(base + brk_rnd());
-
-	if (ret < mm->brk)
-		return mm->brk;
-
-	return ret;
-}
-
 bool __virt_addr_valid(const volatile void *kaddr)
 {
 	unsigned long vaddr = (unsigned long)kaddr;
-- 
2.20.1

