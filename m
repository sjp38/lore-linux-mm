Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id CFEF26B0266
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 16:36:21 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id a29so108848297qtb.6
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 13:36:21 -0800 (PST)
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com. [209.85.220.172])
        by mx.google.com with ESMTPS id v124si2255310qki.246.2017.01.10.13.36.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 13:36:21 -0800 (PST)
Received: by mail-qk0-f172.google.com with SMTP id 11so90658324qkl.3
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 13:36:21 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv7 07/11] drivers: firmware: psci: Use __pa_symbol for kernel symbol
Date: Tue, 10 Jan 2017 13:35:46 -0800
Message-Id: <1484084150-1523-8-git-send-email-labbott@redhat.com>
In-Reply-To: <1484084150-1523-1-git-send-email-labbott@redhat.com>
References: <1484084150-1523-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Florian Fainelli <f.fainelli@gmail.com>
Cc: Laura Abbott <labbott@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org


__pa_symbol is technically the macro that should be used for kernel
symbols. Switch to this as a pre-requisite for DEBUG_VIRTUAL which
will do bounds checking.

Reviewed-by: Mark Rutland <mark.rutland@arm.com>
Tested-by: Mark Rutland <mark.rutland@arm.com>
Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/firmware/psci.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/firmware/psci.c b/drivers/firmware/psci.c
index 6c60a50..66a8793 100644
--- a/drivers/firmware/psci.c
+++ b/drivers/firmware/psci.c
@@ -383,7 +383,7 @@ static int psci_suspend_finisher(unsigned long index)
 	u32 *state = __this_cpu_read(psci_power_state);
 
 	return psci_ops.cpu_suspend(state[index - 1],
-				    virt_to_phys(cpu_resume));
+				    __pa_symbol(cpu_resume));
 }
 
 int psci_cpu_suspend_enter(unsigned long index)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
