Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1FE456B004F
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 06:15:59 -0400 (EDT)
Subject: [RFC PATCH 0/3] kmemleak: Add support for the bootmem allocator
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Mon, 06 Jul 2009 11:51:43 +0100
Message-ID: <20090706104654.16051.44029.stgit@pc1117.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Hi,

In the last few days, I went through of false positives reported by
kmemleak and it turns out some of them were caused by not tracking
alloc_bootmem* calls. Rather than adding more and more kmemleak
annotations throughout the kernel, I decided to add support for tracking
all the alloc_bootmem* and free_bootmem calls.

The latter may not have a corresponding alloc_bootmem* pair or it may
only free part of a block. I changed kmemleak to support this usage.

Thanks for your feedback.


Catalin Marinas (3):
      kmemleak: Remove alloc_bootmem annotations introduced in the past
      kmemleak: Add callbacks to the bootmem allocator
      kmemleak: Allow partial freeing of memory blocks


 include/linux/kmemleak.h |    4 +++
 kernel/pid.c             |    7 ------
 mm/bootmem.c             |   36 ++++++++++++++++++++++++------
 mm/kmemleak.c            |   55 ++++++++++++++++++++++++++++++++++++++++++----
 mm/page_alloc.c          |   14 +++---------
 5 files changed, 86 insertions(+), 30 deletions(-)

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
