Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 927AA6B0038
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 17:00:27 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id x71so5852177iod.3
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 14:00:27 -0800 (PST)
Received: from resqmta-po-11v.sys.comcast.net (resqmta-po-11v.sys.comcast.net. [2001:558:fe16:19:96:114:154:170])
        by mx.google.com with ESMTPS id 94si14891447ioj.8.2018.01.12.14.00.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jan 2018 14:00:25 -0800 (PST)
From: "W. Trevor King" <wking@tremily.us>
Subject: [PATCH] security/Kconfig: Remove pagetable-isolation.txt reference
Date: Fri, 12 Jan 2018 13:58:23 -0800
Message-Id: <0ccf9a4d2e42bcb823ab877e4fb21274f27878bd.1515794059.git.wking@tremily.us>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-security-module@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "W. Trevor King" <wking@tremily.us>

The reference landed with the config option in 385ce0ea (x86/mm/pti:
Add Kconfig, 2017-12-04), but the referenced file was never committed.

Signed-off-by: W. Trevor King <wking@tremily.us>
---
 security/Kconfig | 2 --
 1 file changed, 2 deletions(-)

diff --git a/security/Kconfig b/security/Kconfig
index 3d4debd0257e..6c02b69581c8 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -63,8 +63,6 @@ config PAGE_TABLE_ISOLATION
 	  ensuring that the majority of kernel addresses are not mapped
 	  into userspace.
 
-	  See Documentation/x86/pagetable-isolation.txt for more details.
-
 config SECURITY_INFINIBAND
 	bool "Infiniband Security Hooks"
 	depends on SECURITY && INFINIBAND
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
