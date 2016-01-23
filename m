Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6DAA16B0253
	for <linux-mm@kvack.org>; Sat, 23 Jan 2016 10:07:41 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id is5so85225337obc.0
        for <linux-mm@kvack.org>; Sat, 23 Jan 2016 07:07:41 -0800 (PST)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0068.outbound.protection.outlook.com. [157.55.234.68])
        by mx.google.com with ESMTPS id f9si10039460oej.97.2016.01.23.07.07.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 23 Jan 2016 07:07:40 -0800 (PST)
From: <mika.penttila@nextfour.com>
Subject: [PATCH 3/4] arm64: let set_memory_xx(addr, 0) succeed.
Date: Sat, 23 Jan 2016 17:05:42 +0200
Message-ID: <1453561543-14756-4-git-send-email-mika.penttila@nextfour.com>
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
 arch/arm64/mm/pageattr.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/arm64/mm/pageattr.c b/arch/arm64/mm/pageattr.c
index 3571c73..52220dd 100644
--- a/arch/arm64/mm/pageattr.c
+++ b/arch/arm64/mm/pageattr.c
@@ -51,6 +51,9 @@ static int change_memory_common(unsigned long addr, int numpages,
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
