Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F1B2440D3D
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:32:15 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 76so8448219pfr.3
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 11:32:15 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id d21si9859566pll.191.2017.11.10.11.32.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 11:32:14 -0800 (PST)
Subject: [PATCH 26/30] x86, kaiser: add a function to check for KAISER being enabled
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 10 Nov 2017 11:31:55 -0800
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
In-Reply-To: <20171110193058.BECA7D88@viggo.jf.intel.com>
Message-Id: <20171110193155.D088AF1D@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

Currently, all of the checks for KAISER are compile-time checks.

Runtime checks are needed for turning it on/off at runtime.

Add a function to do that.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/include/asm/kaiser.h |    5 +++++
 b/include/linux/kaiser.h        |    4 ++++
 2 files changed, 9 insertions(+)

diff -puN arch/x86/include/asm/kaiser.h~kaiser-dynamic-check-func arch/x86/include/asm/kaiser.h
--- a/arch/x86/include/asm/kaiser.h~kaiser-dynamic-check-func	2017-11-10 11:22:19.435244924 -0800
+++ b/arch/x86/include/asm/kaiser.h	2017-11-10 11:22:19.440244924 -0800
@@ -50,6 +50,11 @@ extern void kaiser_remove_mapping(unsign
  */
 extern void kaiser_init(void);
 
+static inline bool kaiser_active(void)
+{
+	extern int kaiser_enabled;
+	return kaiser_enabled;
+}
 #endif
 
 #endif /* __ASSEMBLY__ */
diff -puN include/linux/kaiser.h~kaiser-dynamic-check-func include/linux/kaiser.h
--- a/include/linux/kaiser.h~kaiser-dynamic-check-func	2017-11-10 11:22:19.437244924 -0800
+++ b/include/linux/kaiser.h	2017-11-10 11:22:19.440244924 -0800
@@ -25,5 +25,9 @@ static inline int kaiser_add_mapping(uns
 	return 0;
 }
 
+static inline bool kaiser_active(void)
+{
+	return 0;
+}
 #endif /* !CONFIG_KAISER */
 #endif /* _INCLUDE_KAISER_H */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
