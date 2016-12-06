Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 23BDF6B026F
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 18:51:30 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id h201so302567381qke.7
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 15:51:30 -0800 (PST)
Received: from mail-qt0-f176.google.com (mail-qt0-f176.google.com. [209.85.216.176])
        by mx.google.com with ESMTPS id l68si12989485qte.4.2016.12.06.15.51.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Dec 2016 15:51:29 -0800 (PST)
Received: by mail-qt0-f176.google.com with SMTP id c47so362894463qtc.2
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 15:51:29 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv5 08/11] kexec: Switch to __pa_symbol
Date: Tue,  6 Dec 2016 15:50:54 -0800
Message-Id: <1481068257-6367-9-git-send-email-labbott@redhat.com>
In-Reply-To: <1481068257-6367-1-git-send-email-labbott@redhat.com>
References: <1481068257-6367-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Eric Biederman <ebiederm@xmission.com>
Cc: Laura Abbott <labbott@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org, kexec@lists.infradead.org


__pa_symbol is the correct api to get the physical address of kernel
symbols. Switch to it to allow for better debug checking.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Laura Abbott <labbott@redhat.com>
---
v5: No changes, just acks
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
