Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5F3006B0276
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 10:17:21 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id r13so22987336pag.1
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 07:17:21 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30097.outbound.protection.outlook.com. [40.107.3.97])
        by mx.google.com with ESMTPS id c71si8152763pga.289.2016.10.27.07.17.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Oct 2016 07:17:20 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCH 1/2] x86/prctl/uapi: remove ifdef for CHECKPOINT_RESTORE
Date: Thu, 27 Oct 2016 17:15:15 +0300
Message-ID: <20161027141516.28447-2-dsafonov@virtuozzo.com>
In-Reply-To: <20161027141516.28447-1-dsafonov@virtuozzo.com>
References: <20161027141516.28447-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, 0x7f454c46@gmail.com, Cyrill
 Gorcunov <gorcunov@openvz.org>, Paul Bolle <pebolle@tiscali.nl>, Andy
 Lutomirski <luto@kernel.org>, oleg@redhat.com, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, x86@kernel.org

As userspace knows nothing about kernel config, this ifdefs
will make prctl constants invisible to userspace.
Let it be clean'n'simple: remove ifdefs.
If kernel has CONFIG_CHECKPOINT_RESTORE disabled, sys_prctl()
will return -EINVAL for those prctls.

Fixes: 2eefd8789698 ("x86/arch_prctl/vdso: Add ARCH_MAP_VDSO_*")
Cc: 0x7f454c46@gmail.com
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Paul Bolle <pebolle@tiscali.nl>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: oleg@redhat.com
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Reported-by: Paul Bolle <pebolle@tiscali.nl>
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/include/uapi/asm/prctl.h | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/arch/x86/include/uapi/asm/prctl.h b/arch/x86/include/uapi/asm/prctl.h
index ae135de547f5..835aa51c7f6e 100644
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
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
