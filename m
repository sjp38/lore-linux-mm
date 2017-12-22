Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id CC1936B0260
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 03:59:37 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id r20so15857003wrg.23
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 00:59:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p39si5026732wrb.93.2017.12.22.00.59.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 00:59:36 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 033/159] x86/boot: Relocate definition of the initial state of CR0
Date: Fri, 22 Dec 2017 09:45:18 +0100
Message-Id: <20171222084625.544783162@linuxfoundation.org>
In-Reply-To: <20171222084623.668990192@linuxfoundation.org>
References: <20171222084623.668990192@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Ricardo Neri <ricardo.neri-calderon@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@suse.de>, Andy Lutomirski <luto@kernel.org>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, ricardo.neri@intel.com, linux-mm@kvack.org, Paul Gortmaker <paul.gortmaker@windriver.com>, Huang Rui <ray.huang@amd.com>, Shuah Khan <shuah@kernel.org>, linux-arch@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Jiri Slaby <jslaby@suse.cz>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, Chris Metcalf <cmetcalf@mellanox.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Chen Yucong <slaoub@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Masami Hiramatsu <mhiramat@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Ricardo Neri <ricardo.neri-calderon@linux.intel.com>

commit b0ce5b8c95c83a7b98c679b117e3d6ae6f97154b upstream.

Both head_32.S and head_64.S utilize the same value to initialize the
control register CR0. Also, other parts of the kernel might want to access
this initial definition (e.g., emulation code for User-Mode Instruction
Prevention uses this state to provide a sane dummy value for CR0 when
emulating the smsw instruction). Thus, relocate this definition to a
header file from which it can be conveniently accessed.

Suggested-by: Borislav Petkov <bp@alien8.de>
Signed-off-by: Ricardo Neri <ricardo.neri-calderon@linux.intel.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Reviewed-by: Borislav Petkov <bp@suse.de>
Reviewed-by: Andy Lutomirski <luto@kernel.org>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: ricardo.neri@intel.com
Cc: linux-mm@kvack.org
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Huang Rui <ray.huang@amd.com>
Cc: Shuah Khan <shuah@kernel.org>
Cc: linux-arch@vger.kernel.org
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Jiri Slaby <jslaby@suse.cz>
Cc: "Ravi V. Shankar" <ravi.v.shankar@intel.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Chris Metcalf <cmetcalf@mellanox.com>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Chen Yucong <slaoub@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Link: https://lkml.kernel.org/r/1509135945-13762-3-git-send-email-ricardo.neri-calderon@linux.intel.com
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/include/uapi/asm/processor-flags.h |    3 +++
 arch/x86/kernel/head_32.S                   |    3 ---
 arch/x86/kernel/head_64.S                   |    3 ---
 3 files changed, 3 insertions(+), 6 deletions(-)

--- a/arch/x86/include/uapi/asm/processor-flags.h
+++ b/arch/x86/include/uapi/asm/processor-flags.h
@@ -152,5 +152,8 @@
 #define CX86_ARR_BASE	0xc4
 #define CX86_RCR_BASE	0xdc
 
+#define CR0_STATE	(X86_CR0_PE | X86_CR0_MP | X86_CR0_ET | \
+			 X86_CR0_NE | X86_CR0_WP | X86_CR0_AM | \
+			 X86_CR0_PG)
 
 #endif /* _UAPI_ASM_X86_PROCESSOR_FLAGS_H */
--- a/arch/x86/kernel/head_32.S
+++ b/arch/x86/kernel/head_32.S
@@ -212,9 +212,6 @@ ENTRY(startup_32_smp)
 #endif
 
 .Ldefault_entry:
-#define CR0_STATE	(X86_CR0_PE | X86_CR0_MP | X86_CR0_ET | \
-			 X86_CR0_NE | X86_CR0_WP | X86_CR0_AM | \
-			 X86_CR0_PG)
 	movl $(CR0_STATE & ~X86_CR0_PG),%eax
 	movl %eax,%cr0
 
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -154,9 +154,6 @@ ENTRY(secondary_startup_64)
 1:	wrmsr				/* Make changes effective */
 
 	/* Setup cr0 */
-#define CR0_STATE	(X86_CR0_PE | X86_CR0_MP | X86_CR0_ET | \
-			 X86_CR0_NE | X86_CR0_WP | X86_CR0_AM | \
-			 X86_CR0_PG)
 	movl	$CR0_STATE, %eax
 	/* Make changes effective */
 	movq	%rax, %cr0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
