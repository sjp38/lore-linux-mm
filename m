Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id B33A96B0033
	for <linux-mm@kvack.org>; Fri, 31 May 2013 06:55:17 -0400 (EDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH 0/2] mm: fixlets
Date: Fri, 31 May 2013 16:23:48 +0530
Message-ID: <1369997630-6522-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>, Vineet  Gupta <Vineet.Gupta1@synopsys.com>

Hi Andrew,

Max Filippov reported a generic MM issue with PTE/TLB coherency
@ http://www.spinics.net/lists/linux-arch/msg21736.html

While the fix for issue is still being discussed, sending over a bunch
mm fixlets which we found in due course.

Infact, 1/2 looks like stable material as orig code was flushing wrong range
from TLB - wherever used.

Please consider applying.

Thx,
-Vineet


Vineet Gupta (2):
  mm: Fix the TLB range flushed when __tlb_remove_page() runs out of
    slots
  mm: tlb_fast_mode check missing in tlb_finish_mmu()

 mm/memory.c |   12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
