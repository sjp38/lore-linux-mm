Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB38E6B0261
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:25:56 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id d37so13317169wrd.21
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 08:25:56 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id x58si682038edx.338.2018.04.16.08.25.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 08:25:54 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 33/35] x86/pti: Allow CONFIG_PAGE_TABLE_ISOLATION for x86_32
Date: Mon, 16 Apr 2018 17:25:21 +0200
Message-Id: <1523892323-14741-34-git-send-email-joro@8bytes.org>
In-Reply-To: <1523892323-14741-1-git-send-email-joro@8bytes.org>
References: <1523892323-14741-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Allow PTI to be compiled on x86_32.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 security/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/security/Kconfig b/security/Kconfig
index c430206..afa91c6 100644
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
