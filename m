Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1382C41514
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 06:00:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA83D2087F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 06:00:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA83D2087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5753C8E0014; Tue, 30 Jul 2019 02:00:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 525788E0003; Tue, 30 Jul 2019 02:00:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 414AD8E0014; Tue, 30 Jul 2019 02:00:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E8B348E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 02:00:14 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m23so39595423edr.7
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 23:00:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LQVvrRrr/swGRphV/257WvSOGOZvl4ebHt8qhO/ifFg=;
        b=fJ0cY9fORYYp5FAn7Y9rcOohj9wZQF3z1JKm+reufimb1fP/wvZmRaa/o0Z0pdNpEf
         E9dne/I3j1m9+8A9tTi/Yvk/jSjqqgVnfikFzA4UR1k81rY6p5FHAcEouHj42PWiRZhC
         2onj9OX3v+uo+84tJEesK/LslX5cLJx6QcN+Ky9a5+m/UfRFsCpC5gvktyXA9QN9CISz
         7Rvdnd7bnqwJc07EoVo4jJ76sJAms88GGDrHdn+zGb28IUwl/UHZ+QKeAtEK9exXORM6
         7U2Qctmur6I+vGeiN/1NM4vXlGrTi+Rbohiu/8H30Lzl3G8yPL2WuXddTFRdNovT+l7R
         7u7A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWmijecEKIo94nXyhPu+VKzNND6CBVyGKdkLkkNo+jE/ZvLdVjN
	nC+cDAjQprdr5Mq9yrxbkxyOTkmM2bfaNiB48HhG8KE+tVBvyE7PW7WnlHH+ZftAClZirh0pWpL
	wdY1Fwj5tQhFaDrICKKbTi+Rt8zdPy0x/PpxtVzOZUtFdsikVenDZPriwaSrRqWQ=
X-Received: by 2002:aa7:c559:: with SMTP id s25mr1204168edr.117.1564466414510;
        Mon, 29 Jul 2019 23:00:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRROlYMxex2kYvWOpKFvdVQuEOIkE+Ys4aWs3afgTRn3q0WSpJUc8ns2CunvrxNcSq9lnr
X-Received: by 2002:aa7:c559:: with SMTP id s25mr1204044edr.117.1564466413144;
        Mon, 29 Jul 2019 23:00:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564466413; cv=none;
        d=google.com; s=arc-20160816;
        b=zQjYagj5npcaWeu2cDdlk8wu888tfe5jRBYnlNAN7xW0OIXCTNB2CJzCioGu1rZqeL
         eJlfA/MeGHZz5EwFnCOLREhE5qiHQcjCvfeV7dvcV60n2OE0B0ebppzg1zxFWlWHGZao
         ir3Lz5yQKQ/fTg7qpZdHiwnve0XhpRa5HmIr/TCsu7h1BRBWXB7ADLKzyLOYOGOBbg2B
         e00EcsXxRQg5S1hBpxbLe3GyxyP9YHz0HOHtDBBrLG6m7FpX4p7Utq5XBNTvyRUC3wkE
         ZwEwx7OdAau9pXGg5xg356pkQL+VPPK+G5sMjI7HYw02SQ7E4T4E46yrOsyxSjTLHpJf
         QROA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=LQVvrRrr/swGRphV/257WvSOGOZvl4ebHt8qhO/ifFg=;
        b=TQ5xQ7597yPy7O3HonzPANjJLPTWpB3Ai+9yZLmpJqfvYr0UwNYZBM7n6OfgvpRkz/
         Pg8kf2muMWEkDMUgZUlXLTeToDJ27Bd/cINqHRz4sO8H0SoP8Beqd0FtL7OwGLFv71B0
         Vuh41gYLFAU7RaURX4ee2Am+85Z3envZALLr6LZVHrIFyUo5owyjnoriZxNtjnAURXpm
         Tx6+O0MPIPtmoLzyDSPwj0iJQBNw0DGw3w+8ML/DomPgDwyMrYAJsviNxko+Qykl8aKi
         ggegGmGXnrGv6GLVD0kuYK24ijunOZ+o61GYuiNA5PCRqYqLJQqrFwhXRqFzfABbPnps
         qEkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay8-d.mail.gandi.net (relay8-d.mail.gandi.net. [217.70.183.201])
        by mx.google.com with ESMTPS id x15si15988325ejv.41.2019.07.29.23.00.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Jul 2019 23:00:13 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.201;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay8-d.mail.gandi.net (Postfix) with ESMTPSA id 558AF1BF211;
	Tue, 30 Jul 2019 06:00:08 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Luis Chamberlain <mcgrof@kernel.org>,
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
Subject: [PATCH v5 08/14] arm: Use generic mmap top-down layout and brk randomization
Date: Tue, 30 Jul 2019 01:51:07 -0400
Message-Id: <20190730055113.23635-9-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190730055113.23635-1-alex@ghiti.fr>
References: <20190730055113.23635-1-alex@ghiti.fr>
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
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
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

