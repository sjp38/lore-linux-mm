Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id DB9B66B025E
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 18:45:41 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id a66so59531142qkg.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 15:45:41 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1on0083.outbound.protection.outlook.com. [157.56.110.83])
        by mx.google.com with ESMTPS id i129si606266qke.89.2016.04.26.15.45.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 15:45:41 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v1 02/18] x86: Secure Memory Encryption (SME) build
 enablement
Date: Tue, 26 Apr 2016 17:45:34 -0500
Message-ID: <20160426224533.13079.905.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20160426224508.13079.90373.stgit@tlendack-t1.amdoffice.net>
References: <20160426224508.13079.90373.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek
 Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander
 Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry
 Vyukov <dvyukov@google.com>

Provide the Kconfig support to build the SME support in the kernel.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/Kconfig |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 7bb1574..13249b5 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1356,6 +1356,15 @@ config X86_DIRECT_GBPAGES
 	  supports them), so don't confuse the user by printing
 	  that we have them enabled.
 
+config AMD_MEM_ENCRYPT
+	bool "Secure Memory Encryption support for AMD"
+	depends on X86_64 && CPU_SUP_AMD
+	---help---
+	  Say yes to enable the encryption of system memory. This requires
+	  an AMD processor that supports Secure Memory Encryption (SME).
+	  The encryption of system memory is disabled by default but can be
+	  enabled with the mem_encrypt=on command line option.
+
 # Common NUMA Features
 config NUMA
 	bool "Numa Memory Allocation and Scheduler Support"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
