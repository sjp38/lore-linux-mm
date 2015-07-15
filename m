Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 81FD428029C
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 12:25:05 -0400 (EDT)
Received: by oige126 with SMTP id e126so32141208oig.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 09:25:05 -0700 (PDT)
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com. [15.216.225.55])
        by mx.google.com with ESMTPS id xu5si4151759oeb.85.2015.07.15.09.25.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 09:25:02 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v2 1/4] x86/vdso32: Define PGTABLE_LEVELS to 32bit VDSO
Date: Wed, 15 Jul 2015 10:23:52 -0600
Message-Id: <1436977435-31826-2-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1436977435-31826-1-git-send-email-toshi.kani@hp.com>
References: <1436977435-31826-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

In case of CONFIG_X86_64, vdso32/vclock_gettime.c fakes a 32bit
kernel configuration by re-defining it to CONFIG_X86_32.  However,
it does not re-define CONFIG_PGTABLE_LEVELS leaving it as 4 levels.
Fix it by re-defining CONFIG_PGTABLE_LEVELS to 2 as X86_PAE is not
set.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
---
 arch/x86/entry/vdso/vdso32/vclock_gettime.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/x86/entry/vdso/vdso32/vclock_gettime.c b/arch/x86/entry/vdso/vdso32/vclock_gettime.c
index 175cc72..87a86e0 100644
--- a/arch/x86/entry/vdso/vdso32/vclock_gettime.c
+++ b/arch/x86/entry/vdso/vdso32/vclock_gettime.c
@@ -14,11 +14,13 @@
  */
 #undef CONFIG_64BIT
 #undef CONFIG_X86_64
+#undef CONFIG_PGTABLE_LEVELS
 #undef CONFIG_ILLEGAL_POINTER_VALUE
 #undef CONFIG_SPARSEMEM_VMEMMAP
 #undef CONFIG_NR_CPUS
 
 #define CONFIG_X86_32 1
+#define CONFIG_PGTABLE_LEVELS 2
 #define CONFIG_PAGE_OFFSET 0
 #define CONFIG_ILLEGAL_POINTER_VALUE 0
 #define CONFIG_NR_CPUS 1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
