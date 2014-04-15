Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 13B5B6B0037
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 10:41:23 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so7933484eei.28
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 07:41:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z2si25857197eeo.94.2014.04.15.07.41.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 07:41:22 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/3] x86: Require x86-64 for automatic NUMA balancing
Date: Tue, 15 Apr 2014 15:41:15 +0100
Message-Id: <1397572876-1610-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1397572876-1610-1-git-send-email-mgorman@suse.de>
References: <1397572876-1610-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

32-bit support for NUMA is an oddity on its own but with automatic NUMA
balancing on top there is a reasonable risk that the CPUPID information
cannot be stored in the page flags. This patch removes support for
automatic NUMA support on 32-bit x86.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/x86/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 0af5250..084b1c1 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -26,7 +26,7 @@ config X86
 	select ARCH_MIGHT_HAVE_PC_SERIO
 	select HAVE_AOUT if X86_32
 	select HAVE_UNSTABLE_SCHED_CLOCK
-	select ARCH_SUPPORTS_NUMA_BALANCING
+	select ARCH_SUPPORTS_NUMA_BALANCING if X86_64
 	select ARCH_SUPPORTS_INT128 if X86_64
 	select ARCH_WANTS_PROT_NUMA_PROT_NONE
 	select HAVE_IDE
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
