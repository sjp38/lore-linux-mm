Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3B5CF6B009D
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 09:09:41 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so672617eei.14
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 06:09:39 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v8si2758564eew.67.2014.04.08.06.09.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 06:09:38 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/5] x86: Require x86-64 for automatic NUMA balancing
Date: Tue,  8 Apr 2014 14:09:26 +0100
Message-Id: <1396962570-18762-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1396962570-18762-1-git-send-email-mgorman@suse.de>
References: <1396962570-18762-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-X86 <x86@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Mel Gorman <mgorman@suse.de>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

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
