Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9155D6B0253
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 16:36:11 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id d201so126003005qkg.2
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 13:36:11 -0800 (PST)
Received: from mail-qt0-f179.google.com (mail-qt0-f179.google.com. [209.85.216.179])
        by mx.google.com with ESMTPS id 125si2274972qkk.68.2017.01.10.13.36.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 13:36:10 -0800 (PST)
Received: by mail-qt0-f179.google.com with SMTP id k15so408152392qtg.3
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 13:36:10 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv7 04/11] kexec: Switch to __pa_symbol
Date: Tue, 10 Jan 2017 13:35:43 -0800
Message-Id: <1484084150-1523-5-git-send-email-labbott@redhat.com>
In-Reply-To: <1484084150-1523-1-git-send-email-labbott@redhat.com>
References: <1484084150-1523-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Eric Biederman <ebiederm@xmission.com>, Florian Fainelli <f.fainelli@gmail.com>
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
