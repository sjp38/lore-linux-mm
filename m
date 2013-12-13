Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vb0-f43.google.com (mail-vb0-f43.google.com [209.85.212.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0B97D6B0038
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 15:01:17 -0500 (EST)
Received: by mail-vb0-f43.google.com with SMTP id p6so1615612vbe.16
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 12:01:16 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t6si3226679eeh.66.2013.12.13.12.01.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 12:01:16 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/4] x86: mm: Change tlb_flushall_shift for IvyBridge
Date: Fri, 13 Dec 2013 20:01:09 +0000
Message-Id: <1386964870-6690-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1386964870-6690-1-git-send-email-mgorman@suse.de>
References: <1386964870-6690-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

There was a large performance regression that was bisected to commit 611ae8e3
(x86/tlb: enable tlb flush range support for x86). This patch simply changes
the default balance point between a local and global flush for IvyBridge.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/x86/kernel/cpu/intel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index dc1ec0d..2d93753 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -627,7 +627,7 @@ static void intel_tlb_flushall_shift_set(struct cpuinfo_x86 *c)
 		tlb_flushall_shift = 5;
 		break;
 	case 0x63a: /* Ivybridge */
-		tlb_flushall_shift = 1;
+		tlb_flushall_shift = 2;
 		break;
 	default:
 		tlb_flushall_shift = 6;
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
