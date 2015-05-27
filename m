Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3436B0102
	for <linux-mm@kvack.org>; Wed, 27 May 2015 10:18:51 -0400 (EDT)
Received: by pdea3 with SMTP id a3so17057125pde.2
        for <linux-mm@kvack.org>; Wed, 27 May 2015 07:18:51 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id ge6si26080231pbc.181.2015.05.27.07.18.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 07:18:50 -0700 (PDT)
Date: Wed, 27 May 2015 07:17:56 -0700
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-10455f64aff0d715dcdfb09b02393df168fe267e@git.kernel.org>
Reply-To: bp@alien8.de, akpm@linux-foundation.org, dvlasenk@redhat.com,
        torvalds@linux-foundation.org, toshi.kani@hp.com, hpa@zytor.com,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linutronix.de,
        peterz@infradead.org, mingo@kernel.org, bp@suse.de, brgerst@gmail.com,
        luto@amacapital.net, mcgrof@suse.com
In-Reply-To: <1432628901-18044-2-git-send-email-bp@alien8.de>
References: <1431714237-880-2-git-send-email-toshi.kani@hp.com>
	<1432628901-18044-2-git-send-email-bp@alien8.de>
Subject: [tip:x86/mm] x86/mm/kconfig:
  Simplify conditions for HAVE_ARCH_HUGE_VMAP
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: dvlasenk@redhat.com, torvalds@linux-foundation.org, hpa@zytor.com, toshi.kani@hp.com, bp@alien8.de, akpm@linux-foundation.org, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bp@suse.de, mingo@kernel.org, peterz@infradead.org, mcgrof@suse.com, brgerst@gmail.com, luto@amacapital.net

Commit-ID:  10455f64aff0d715dcdfb09b02393df168fe267e
Gitweb:     http://git.kernel.org/tip/10455f64aff0d715dcdfb09b02393df168fe267e
Author:     Toshi Kani <toshi.kani@hp.com>
AuthorDate: Tue, 26 May 2015 10:28:04 +0200
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Wed, 27 May 2015 14:40:55 +0200

x86/mm/kconfig: Simplify conditions for HAVE_ARCH_HUGE_VMAP

Simplify the conditions selecting HAVE_ARCH_HUGE_VMAP since
X86_PAE depends on X86_32 already.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Elliott@hp.com
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: dave.hansen@intel.com
Cc: linux-mm <linux-mm@kvack.org>
Cc: pebolle@tiscali.nl
Link: http://lkml.kernel.org/r/1431714237-880-2-git-send-email-toshi.kani@hp.com
Link: http://lkml.kernel.org/r/1432628901-18044-2-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 226d569..4eb0b0f 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -100,7 +100,7 @@ config X86
 	select IRQ_FORCED_THREADING
 	select HAVE_BPF_JIT if X86_64
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
-	select HAVE_ARCH_HUGE_VMAP if X86_64 || (X86_32 && X86_PAE)
+	select HAVE_ARCH_HUGE_VMAP if X86_64 || X86_PAE
 	select ARCH_HAS_SG_CHAIN
 	select CLKEVT_I8253
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
