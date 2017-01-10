Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 86C466B0038
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 08:48:15 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 204so183715721pfx.1
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 05:48:15 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d9si2213384pgf.74.2017.01.10.05.48.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 05:48:14 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.9 102/206] x86/prctl/uapi: Remove #ifdef for CHECKPOINT_RESTORE
Date: Tue, 10 Jan 2017 14:36:25 +0100
Message-Id: <20170110131507.265708004@linuxfoundation.org>
In-Reply-To: <20170110131502.767555407@linuxfoundation.org>
References: <20170110131502.767555407@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Paul Bolle <pebolle@tiscali.nl>, Dmitry Safonov <dsafonov@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, 0x7f454c46@gmail.com, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, oleg@redhat.com, Ingo Molnar <mingo@kernel.org>

4.9-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Dmitry Safonov <dsafonov@virtuozzo.com>

commit a01aa6c9f40fe03c82032e7f8b3bcf1e6c93ac0e upstream.

As userspace knows nothing about kernel config, thus #ifdefs
around ABI prctl constants makes them invisible to userspace.

Let it be clean'n'simple: remove #ifdefs.

If kernel has CONFIG_CHECKPOINT_RESTORE disabled, sys_prctl()
will return -EINVAL for those prctls.

Reported-by: Paul Bolle <pebolle@tiscali.nl>
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
Acked-by: Andy Lutomirski <luto@kernel.org>
Cc: 0x7f454c46@gmail.com
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Cc: oleg@redhat.com
Fixes: 2eefd8789698 ("x86/arch_prctl/vdso: Add ARCH_MAP_VDSO_*")
Link: http://lkml.kernel.org/r/20161027141516.28447-2-dsafonov@virtuozzo.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/include/uapi/asm/prctl.h |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

--- a/arch/x86/include/uapi/asm/prctl.h
+++ b/arch/x86/include/uapi/asm/prctl.h
@@ -6,10 +6,8 @@
 #define ARCH_GET_FS 0x1003
 #define ARCH_GET_GS 0x1004
 
-#ifdef CONFIG_CHECKPOINT_RESTORE
-# define ARCH_MAP_VDSO_X32	0x2001
-# define ARCH_MAP_VDSO_32	0x2002
-# define ARCH_MAP_VDSO_64	0x2003
-#endif
+#define ARCH_MAP_VDSO_X32	0x2001
+#define ARCH_MAP_VDSO_32	0x2002
+#define ARCH_MAP_VDSO_64	0x2003
 
 #endif /* _ASM_X86_PRCTL_H */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
