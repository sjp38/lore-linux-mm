Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CC4236B04AB
	for <linux-mm@kvack.org>; Sun, 16 Jul 2017 19:00:06 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e19so31410348pfb.13
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 16:00:06 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id y5si3722472pgj.111.2017.07.16.16.00.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jul 2017 16:00:05 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 7/8] x86/mm: Allow userspace have mapping above 47-bit
Date: Mon, 17 Jul 2017 01:59:53 +0300
Message-Id: <20170716225954.74185-8-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170716225954.74185-1-kirill.shutemov@linux.intel.com>
References: <20170716225954.74185-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

All bits and pieces now in place and we can allow userspace to have VMAs
above 47-bit.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/processor.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index 91362921eb05..06d4dd8aca5d 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -844,9 +844,9 @@ static inline void spin_lock_prefetch(const void *x)
  * particular problem by preventing anything from being mapped
  * at the maximum canonical address.
  */
-#define TASK_SIZE_MAX	((1UL << 47) - PAGE_SIZE)
+#define TASK_SIZE_MAX	((1UL << __VIRTUAL_MASK_SHIFT) - PAGE_SIZE)
 
-#define DEFAULT_MAP_WINDOW	TASK_SIZE_MAX
+#define DEFAULT_MAP_WINDOW	((1UL << 47) - PAGE_SIZE)
 
 /* This decides where the kernel will search for a free chunk of vm
  * space during mmap's.
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
