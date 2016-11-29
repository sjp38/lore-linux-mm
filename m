Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2184B6B0268
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 13:55:58 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id k201so138833845qke.6
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:55:58 -0800 (PST)
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com. [209.85.220.169])
        by mx.google.com with ESMTPS id t65si35579845qkl.108.2016.11.29.10.55.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 10:55:57 -0800 (PST)
Received: by mail-qk0-f169.google.com with SMTP id x190so184728398qkb.0
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:55:57 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv4 07/10] kexec: Switch to __pa_symbol
Date: Tue, 29 Nov 2016 10:55:26 -0800
Message-Id: <1480445729-27130-8-git-send-email-labbott@redhat.com>
In-Reply-To: <1480445729-27130-1-git-send-email-labbott@redhat.com>
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Eric Biederman <ebiederm@xmission.com>
Cc: Laura Abbott <labbott@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org, kexec@lists.infradead.org


__pa_symbol is the correct api to get the physical address of kernel
symbols. Switch to it to allow for better debug checking.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
Found during review of the kernel. Untested.
---
 kernel/kexec_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index 5616755..e1b625e 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -1397,7 +1397,7 @@ void __weak arch_crash_save_vmcoreinfo(void)
 
 phys_addr_t __weak paddr_vmcoreinfo_note(void)
 {
-	return __pa((unsigned long)(char *)&vmcoreinfo_note);
+	return __pa_symbol((unsigned long)(char *)&vmcoreinfo_note);
 }
 
 static int __init crash_save_vmcoreinfo_init(void)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
