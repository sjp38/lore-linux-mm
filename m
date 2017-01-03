Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 26DAF6B026B
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 12:22:30 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id d45so362260439qta.2
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 09:22:30 -0800 (PST)
Received: from mail-qt0-f173.google.com (mail-qt0-f173.google.com. [209.85.216.173])
        by mx.google.com with ESMTPS id v6si25466855qtb.249.2017.01.03.09.22.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 09:22:29 -0800 (PST)
Received: by mail-qt0-f173.google.com with SMTP id v23so8913qtb.0
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 09:22:29 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv6 08/11] kexec: Switch to __pa_symbol
Date: Tue,  3 Jan 2017 09:21:50 -0800
Message-Id: <1483464113-1587-9-git-send-email-labbott@redhat.com>
In-Reply-To: <1483464113-1587-1-git-send-email-labbott@redhat.com>
References: <1483464113-1587-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Eric Biederman <ebiederm@xmission.com>
Cc: Laura Abbott <labbott@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org, kexec@lists.infradead.org

__pa_symbol is the correct api to get the physical address of kernel
symbols. Switch to it to allow for better debug checking.

Reviewed-by: Mark Rutland <mark.rutland@arm.com>
Tested-by: Mark Rutland <mark.rutland@arm.com>
Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 kernel/kexec_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index 5617cc4..a01974e 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -1399,7 +1399,7 @@ void __weak arch_crash_save_vmcoreinfo(void)
 
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
