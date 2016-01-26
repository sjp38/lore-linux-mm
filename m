Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id A0F486B0254
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 10:00:37 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id r129so107838266wmr.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:00:37 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0058.outbound.protection.outlook.com. [104.47.1.58])
        by mx.google.com with ESMTPS id k128si6004226wma.55.2016.01.26.07.00.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 07:00:36 -0800 (PST)
From: <mika.penttila@nextfour.com>
Subject: [PATCH v2 RESEND 1/2] arm, arm64: change_memory_common with numpages == 0 should be no-op.
Date: Tue, 26 Jan 2016 16:59:52 +0200
Message-ID: <1453820393-31179-2-git-send-email-mika.penttila@nextfour.com>
In-Reply-To: <1453820393-31179-1-git-send-email-mika.penttila@nextfour.com>
References: <1453820393-31179-1-git-send-email-mika.penttila@nextfour.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux@arm.linux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, =?UTF-8?q?Mika=20Penttil=C3=A4?= <mika.penttila@nextfour.com>

From: Mika PenttilA? <mika.penttila@nextfour.com>

This makes the caller set_memory_xx() consistent with x86.

arm64 part is rebased on 4.5.0-rc1 with Ard's patch
 lkml.kernel.org/g/<1453125665-26627-1-git-send-email-ard.biesheuvel@linaro.org>
applied.

Signed-off-by: Mika PenttilA? mika.penttila@nextfour.com
Reviewed-by: Laura Abbott <labbott@redhat.com>
Acked-by: David Rientjes <rientjes@google.com>

---
 arch/arm/mm/pageattr.c   | 3 +++
 arch/arm64/mm/pageattr.c | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/arch/arm/mm/pageattr.c b/arch/arm/mm/pageattr.c
index cf30daf..d19b1ad 100644
--- a/arch/arm/mm/pageattr.c
+++ b/arch/arm/mm/pageattr.c
@@ -49,6 +49,9 @@ static int change_memory_common(unsigned long addr, int numpages,
 		WARN_ON_ONCE(1);
 	}
 
+	if (!numpages)
+		return 0;
+
 	if (start < MODULES_VADDR || start >= MODULES_END)
 		return -EINVAL;
 
diff --git a/arch/arm64/mm/pageattr.c b/arch/arm64/mm/pageattr.c
index 1360a02..b582fc2 100644
--- a/arch/arm64/mm/pageattr.c
+++ b/arch/arm64/mm/pageattr.c
@@ -53,6 +53,9 @@ static int change_memory_common(unsigned long addr, int numpages,
 		WARN_ON_ONCE(1);
 	}
 
+	if (!numpages)
+		return 0;
+
 	/*
 	 * Kernel VA mappings are always live, and splitting live section
 	 * mappings into page mappings may cause TLB conflicts. This means
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
