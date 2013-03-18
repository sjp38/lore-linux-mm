Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id E04A46B005A
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 07:11:43 -0400 (EDT)
From: Lin Feng <linfeng@cn.fujitsu.com>
Subject: [PATCH] x86: mm: accurate the comments for STEP_SIZE_SHIFT macro
Date: Mon, 18 Mar 2013 18:21:08 +0800
Message-Id: <1363602068-11924-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, penberg@kernel.org, jacob.shin@amd.com, Lin Feng <linfeng@cn.fujitsu.com>

For x86 PUD_SHIFT is 30 and PMD_SHIFT is 21, so the consequence of
(PUD_SHIFT-PMD_SHIFT)/2 is 4. Update the comments to the code.

Cc: Yinghai Lu <yinghai@kernel.org>
Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
---
 arch/x86/mm/init.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 59b7fc4..637a95b 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -389,7 +389,7 @@ static unsigned long __init init_range_memory_mapping(
 	return mapped_ram_size;
 }
 
-/* (PUD_SHIFT-PMD_SHIFT)/2 */
+/* (PUD_SHIFT-PMD_SHIFT)/2+1 */
 #define STEP_SIZE_SHIFT 5
 void __init init_mem_mapping(void)
 {
-- 
1.8.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
