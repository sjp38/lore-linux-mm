Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f175.google.com (mail-ea0-f175.google.com [209.85.215.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9BBD46B0037
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 06:55:13 -0500 (EST)
Received: by mail-ea0-f175.google.com with SMTP id z10so172556ead.34
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 03:55:13 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id l44si23321283eem.166.2013.12.12.03.55.12
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 03:55:12 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/3] x86: mm: Change tlb_flushall_shift for IvyBridge
Date: Thu, 12 Dec 2013 11:55:08 +0000
Message-Id: <1386849309-22584-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1386849309-22584-1-git-send-email-mgorman@suse.de>
References: <1386849309-22584-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@linaro.org>
Cc: H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

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
