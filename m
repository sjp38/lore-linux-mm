Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 475D52808C5
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 09:24:33 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id e5so113894048pgk.1
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 06:24:33 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id n87si6610984pfj.73.2017.03.09.06.24.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 06:24:32 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 1/7] x86/cpufeature: Add 5-level paging detection
Date: Thu,  9 Mar 2017 17:24:02 +0300
Message-Id: <20170309142408.2868-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170309142408.2868-1-kirill.shutemov@linux.intel.com>
References: <20170309142408.2868-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Look for 'la57' in /proc/cpuinfo to see if your machine supports 5-level
paging.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 arch/x86/include/asm/cpufeatures.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/cpufeatures.h b/arch/x86/include/asm/cpufeatures.h
index 4e7772387c6e..b04bb6dfed7f 100644
--- a/arch/x86/include/asm/cpufeatures.h
+++ b/arch/x86/include/asm/cpufeatures.h
@@ -289,7 +289,8 @@
 #define X86_FEATURE_PKU		(16*32+ 3) /* Protection Keys for Userspace */
 #define X86_FEATURE_OSPKE	(16*32+ 4) /* OS Protection Keys Enable */
 #define X86_FEATURE_AVX512_VPOPCNTDQ (16*32+14) /* POPCNT for vectors of DW/QW */
-#define X86_FEATURE_RDPID	(16*32+ 22) /* RDPID instruction */
+#define X86_FEATURE_LA57	(16*32+16) /* 5-level page tables */
+#define X86_FEATURE_RDPID	(16*32+22) /* RDPID instruction */
 
 /* AMD-defined CPU features, CPUID level 0x80000007 (ebx), word 17 */
 #define X86_FEATURE_OVERFLOW_RECOV (17*32+0) /* MCA overflow recovery support */
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
