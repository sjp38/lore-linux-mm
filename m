Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id A07AB6B0009
	for <linux-mm@kvack.org>; Sat, 23 Jan 2016 10:07:23 -0500 (EST)
Received: by mail-oi0-f50.google.com with SMTP id w75so64265034oie.0
        for <linux-mm@kvack.org>; Sat, 23 Jan 2016 07:07:23 -0800 (PST)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0089.outbound.protection.outlook.com. [157.56.112.89])
        by mx.google.com with ESMTPS id f132si10057404oig.72.2016.01.23.07.07.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 23 Jan 2016 07:07:22 -0800 (PST)
From: <mika.penttila@nextfour.com>
Subject: [PATCH 1/4] arm: Fix wrong bounds check.
Date: Sat, 23 Jan 2016 17:05:40 +0200
Message-ID: <1453561543-14756-2-git-send-email-mika.penttila@nextfour.com>
In-Reply-To: <1453561543-14756-1-git-send-email-mika.penttila@nextfour.com>
References: <1453561543-14756-1-git-send-email-mika.penttila@nextfour.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, linux@arm.linux.org.uk, =?UTF-8?q?Mika=20Penttil=C3=A4?= <mika.penttila@nextfour.com>

From: Mika PenttilA? <mika.penttila@nextfour.com>

Not related to this oops, but while at it, fix incorrect bounds check.

Signed-off-by: Mika PenttilA? mika.penttila@nextfour.com

---
 arch/arm/mm/pageattr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm/mm/pageattr.c b/arch/arm/mm/pageattr.c
index cf30daf..be7fe4b 100644
--- a/arch/arm/mm/pageattr.c
+++ b/arch/arm/mm/pageattr.c
@@ -52,7 +52,7 @@ static int change_memory_common(unsigned long addr, int numpages,
 	if (start < MODULES_VADDR || start >= MODULES_END)
 		return -EINVAL;
 
-	if (end < MODULES_VADDR || start >= MODULES_END)
+	if (end < MODULES_VADDR || end >= MODULES_END)
 		return -EINVAL;
 
 	data.set_mask = set_mask;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
