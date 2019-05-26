Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95041C282E3
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 13:57:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 494802075E
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 13:57:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 494802075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E99FA6B0003; Sun, 26 May 2019 09:57:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E49EA6B0005; Sun, 26 May 2019 09:57:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D12B66B0007; Sun, 26 May 2019 09:57:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 840B86B0003
	for <linux-mm@kvack.org>; Sun, 26 May 2019 09:57:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d15so23333776edm.7
        for <linux-mm@kvack.org>; Sun, 26 May 2019 06:57:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=k4gAy3Z0GohLZRHeMFIbFeMU/TQlVJcVgn+DpFBm95g=;
        b=LUAZ7Vwt2ksiFYbpw5W4CTO9PBTWqrmj9TowN188ne6B65dnMcSci0Ez8T2ExpF7Uf
         Fd/Va8evgssmVu17lNoPeva7CaKUYu7Olg1D+RHdfy2k09YLqBXuIEIE0EbjIm4qC6+U
         MaNrU9kUyvW+Z4JiCDG0Ae4RaZgVoDXry1w8RKAFzBKwexQUOyfepxxjgqdesk/XuwlB
         QelbhgjTEfr0ekySrJ4MKsagca7kB/PY/1cjeF3YS3r1zU3RWtp6CwwzFiRBrv/O2tuV
         rJ5jZqAVGkOHU/Y9sDZj14I3/pdmXWIpH7plDXanQq4RGQYSOQxsuD+zVl+nw3/CffL8
         FDVQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAU0IjeogDDeGufm61A3BKR9RAtMR4gz2TZE6wCSYl8gyZ+mKTCC
	ouz237ZUgUaNS6hiHOkZG0woWP/jvSfFlRHkBQ9/nO/JClFLOyr3BsBFqM5GCm5A41qv531nOhc
	akuowEZ5OV8zAgA82/1aNHxYOowIeshnRwojrElWqKy2WN7wxLZvLdONOtj37F4g=
X-Received: by 2002:a50:91cc:: with SMTP id h12mr116243475eda.3.1558879028028;
        Sun, 26 May 2019 06:57:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgApBfPLUTy/7iECdVsQI/wtru241tgH6PA+5SlVLKsuWtxBGARbZPwYj0P56dIjf6TKIx
X-Received: by 2002:a50:91cc:: with SMTP id h12mr116243384eda.3.1558879026676;
        Sun, 26 May 2019 06:57:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558879026; cv=none;
        d=google.com; s=arc-20160816;
        b=oqIiJ7P8iORu8a/2Gs6lohkC2PFa5sHWgbTHr8bujGnlt+nzFW8hEaAMLyKVX1POuI
         M17fzDbbKTBNnlClp5Jp8ALhUTV6jkX0rzgtkNxB2+7+UM8jE1CRx5yf3vjuJMvfcmx4
         aQPvTvfZypS/+p3GFkc8GYspZGrAjTJ4tdiY+Ij+rGaeIzny0BL5bIb8l/y3W9BTr4U7
         XVIA+MsqaJuaguHp1uGDG3gmJe+OpA0uOQ6zobhSWMPbjOStb9NtV8N4HRVP5sjXgNSe
         64Q0QX31NhV6rxcJiQgpJeY9aHZxCly/fac0LSm0BUJhZaK53rfWoEXUIfQ6TmKJiDu3
         Ak1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=k4gAy3Z0GohLZRHeMFIbFeMU/TQlVJcVgn+DpFBm95g=;
        b=Lze2yAnXfM9O9fkNgAc7bSkEu9HFHad1F0jdE0jCKfDXJ9TarekENhX9eIK9+H6Wwr
         OfSB1IH02nIUootr7EPkyNsUrjyvaRZGoyRDGL2NQ50zulLfTfFcy+fSvjEkrKsxanBZ
         QEj0NOjaDQEFHcI+nJ7/7YJJUhmEMnzKjQ8aavQyRVlQ4X1EA0ray8RmBYp1vv1poqG1
         ZZV3Zdt9h9XAP+Qm35lJ0JNqLyTVJKsv7Y0/vZnDTnb3zBmTbUuPtRV/QfXOBAmwXMPR
         FqR9UYN7l9gbGJUA6WZUGrQY4bzLIspyf+unMwA3rfhxKzYIPyeP4Z48ed2S2khUaB3p
         hGpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id b26si6110929edw.334.2019.05.26.06.57.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 26 May 2019 06:57:06 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.197;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 572EE1C0003;
	Sun, 26 May 2019 13:57:00 +0000 (UTC)
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
Subject: [PATCH v4 08/14] arm: Use generic mmap top-down layout and brk randomization
Date: Sun, 26 May 2019 09:47:40 -0400
Message-Id: <20190526134746.9315-9-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190526134746.9315-1-alex@ghiti.fr>
References: <20190526134746.9315-1-alex@ghiti.fr>
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

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/arm/Kconfig                 |  2 +-
 arch/arm/include/asm/processor.h |  2 --
 arch/arm/kernel/process.c        |  5 ---
 arch/arm/mm/mmap.c               | 62 --------------------------------
 4 files changed, 1 insertion(+), 70 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 8869742a85df..27687a8c9fb5 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -6,7 +6,6 @@ config ARM
 	select ARCH_CLOCKSOURCE_DATA
 	select ARCH_HAS_DEBUG_VIRTUAL if MMU
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
-	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_KEEPINITRD
 	select ARCH_HAS_KCOV
@@ -29,6 +28,7 @@ config ARM
 	select ARCH_SUPPORTS_ATOMIC_RMW
 	select ARCH_USE_BUILTIN_BSWAP
 	select ARCH_USE_CMPXCHG_LOCKREF
+	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
 	select ARCH_WANT_IPC_PARSE_VERSION
 	select BUILDTIME_EXTABLE_SORT if MMU
 	select CLONE_BACKWARDS
diff --git a/arch/arm/include/asm/processor.h b/arch/arm/include/asm/processor.h
index 5d06f75ffad4..95b7688341c5 100644
--- a/arch/arm/include/asm/processor.h
+++ b/arch/arm/include/asm/processor.h
@@ -143,8 +143,6 @@ static inline void prefetchw(const void *ptr)
 #endif
 #endif
 
-#define HAVE_ARCH_PICK_MMAP_LAYOUT
-
 #endif
 
 #endif /* __ASM_ARM_PROCESSOR_H */
diff --git a/arch/arm/kernel/process.c b/arch/arm/kernel/process.c
index 72cc0862a30e..19a765db5f7f 100644
--- a/arch/arm/kernel/process.c
+++ b/arch/arm/kernel/process.c
@@ -322,11 +322,6 @@ unsigned long get_wchan(struct task_struct *p)
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

