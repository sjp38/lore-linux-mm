Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 674696B0009
	for <linux-mm@kvack.org>; Sat, 23 Jan 2016 10:07:30 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id yo10so60220825obb.2
        for <linux-mm@kvack.org>; Sat, 23 Jan 2016 07:07:30 -0800 (PST)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0058.outbound.protection.outlook.com. [157.55.234.58])
        by mx.google.com with ESMTPS id kz4si10072774obb.73.2016.01.23.07.07.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 23 Jan 2016 07:07:29 -0800 (PST)
From: <mika.penttila@nextfour.com>
Subject: [PATCH 2/4] arm: let set_memory_xx(addr, 0) succeed.
Date: Sat, 23 Jan 2016 17:05:41 +0200
Message-ID: <1453561543-14756-3-git-send-email-mika.penttila@nextfour.com>
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

This makes set_memory_xx() consistent with x86.

Signed-off-by: Mika PenttilA? mika.penttila@nextfour.com

---
 arch/arm/mm/pageattr.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/arm/mm/pageattr.c b/arch/arm/mm/pageattr.c
index be7fe4b..9edf6b0 100644
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
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
