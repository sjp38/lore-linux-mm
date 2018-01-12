Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id CA5166B0253
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 18:27:10 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id u4so8262418iti.2
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 15:27:10 -0800 (PST)
Received: from resqmta-po-09v.sys.comcast.net (resqmta-po-09v.sys.comcast.net. [2001:558:fe16:19:96:114:154:168])
        by mx.google.com with ESMTPS id j70si15022305iod.69.2018.01.12.15.27.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jan 2018 15:27:09 -0800 (PST)
From: "W. Trevor King" <wking@tremily.us>
Subject: [PATCH] security/Kconfig: Replace pagetable-isolation.txt reference with pti.txt
Date: Fri, 12 Jan 2018 15:24:59 -0800
Message-Id: <3009cc8ccbddcd897ec1e0cb6dda524929de0d14.1515799398.git.wking@tremily.us>
In-Reply-To: <9b21ce8f-625c-6915-654b-42334cf38e99@linux.intel.com>
References: <9b21ce8f-625c-6915-654b-42334cf38e99@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-security-module@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "W. Trevor King" <wking@tremily.us>

The reference landed with the config option in 385ce0ea (x86/mm/pti:
Add Kconfig, 2017-12-04), but the referenced file was not committed
then.  It eventually landed in 01c9b17b (x86/Documentation: Add PTI
description, 2018-01-05) as pti.txt.

Signed-off-by: W. Trevor King <wking@tremily.us>
---
On Fri, Jan 12, 2018 at 03:10:53PM -0800, Dave Hansen wrote:
> There is a new file in -tip:
>
> https://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git/commit/?h=x86/pti&id=01c9b17bf673b05bb401b76ec763e9730ccf1376
>
> If you're going to patch this, please send an update to -tip that
> corrects the filename.

Here you go :).

Cheers,
Trevor

 security/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/security/Kconfig b/security/Kconfig
index 3d4debd0257e..b0cb9a5f9448 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -63,7 +63,7 @@ config PAGE_TABLE_ISOLATION
 	  ensuring that the majority of kernel addresses are not mapped
 	  into userspace.
 
-	  See Documentation/x86/pagetable-isolation.txt for more details.
+	  See Documentation/x86/pti.txt for more details.
 
 config SECURITY_INFINIBAND
 	bool "Infiniband Security Hooks"
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
