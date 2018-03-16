Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9E5AB6B0261
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:30:14 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r78so1230269wmd.0
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:30:14 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id d12si3867347edh.501.2018.03.16.12.30.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 12:30:13 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 33/35] x86/pti: Allow CONFIG_PAGE_TABLE_ISOLATION for x86_32
Date: Fri, 16 Mar 2018 20:29:51 +0100
Message-Id: <1521228593-3820-34-git-send-email-joro@8bytes.org>
In-Reply-To: <1521228593-3820-1-git-send-email-joro@8bytes.org>
References: <1521228593-3820-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Allow PTI to be compiled on x86_32.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 security/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/security/Kconfig b/security/Kconfig
index b0cb9a5..93d85fd 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -57,7 +57,7 @@ config SECURITY_NETWORK
 config PAGE_TABLE_ISOLATION
 	bool "Remove the kernel mapping in user mode"
 	default y
-	depends on X86_64 && !UML
+	depends on X86 && !UML
 	help
 	  This feature reduces the number of hardware side channels by
 	  ensuring that the majority of kernel addresses are not mapped
-- 
2.7.4
