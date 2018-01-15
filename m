Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7CE6B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 07:52:23 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id g13so8536679wrh.19
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 04:52:23 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j25si21777600wrc.132.2018.01.15.04.52.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jan 2018 04:52:22 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 116/118] security/Kconfig: Correct the Documentation reference for PTI
Date: Mon, 15 Jan 2018 13:35:43 +0100
Message-Id: <20180115123422.238688977@linuxfoundation.org>
In-Reply-To: <20180115123415.325497625@linuxfoundation.org>
References: <20180115123415.325497625@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, "W. Trevor King" <wking@tremily.us>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, linux-security-module@vger.kernel.org, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: W. Trevor King <wking@tremily.us>

commit a237f762681e2a394ca67f21df2feb2b76a3609b upstream.

When the config option for PTI was added a reference to documentation was
added as well. But the documentation did not exist at that point. The final
documentation has a different file name.

Fix it up to point to the proper file.

Fixes: 385ce0ea ("x86/mm/pti: Add Kconfig")
Signed-off-by: W. Trevor King <wking@tremily.us>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-mm@kvack.org
Cc: linux-security-module@vger.kernel.org
Cc: James Morris <james.l.morris@oracle.com>
Cc: "Serge E. Hallyn" <serge@hallyn.com>
Cc: stable@vger.kernel.org
Link: https://lkml.kernel.org/r/3009cc8ccbddcd897ec1e0cb6dda524929de0d14.1515799398.git.wking@tremily.us
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 security/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
