Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0DF426B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 16:32:25 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id az5-v6so3026356plb.14
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 13:32:25 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id m24si4518132pgd.763.2018.03.02.13.32.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 13:32:24 -0800 (PST)
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH 0/2] Backport IBPB on context switch to non-dumpable process 
Date: Fri,  2 Mar 2018 13:32:08 -0800
Message-Id: <cover.1520026221.git.tim.c.chen@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, David Woodhouse <dwmw@amazon.co.uk>, ak@linux.intel.com, karahmed@amazon.de, pbonzini@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Greg,

I will like to propose backporting "x86/speculation: Use Indirect Branch
Prediction Barrier on context switch" from commit 18bf3c3e in upstream
to 4.9 and 4.4 stable.  The patch has already been ported to 4.14 and
4.15 stable.  The patch needs mm context id that Andy added in commit
f39681ed. I have lifted the mm context id change from Andy's upstream
patch and included it here.

Thanks.

Tim

Tim Chen (2):
  x86/mm: Give each mm a unique ID
  x86/speculation: Use Indirect Branch Prediction Barrier in context
    switch

 arch/x86/include/asm/mmu.h         | 15 +++++++++++++--
 arch/x86/include/asm/mmu_context.h |  5 +++++
 arch/x86/include/asm/tlbflush.h    |  2 ++
 arch/x86/mm/tlb.c                  | 33 +++++++++++++++++++++++++++++++++
 4 files changed, 53 insertions(+), 2 deletions(-)

-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
