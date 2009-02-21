Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 43EDB6B003D
	for <linux-mm@kvack.org>; Sat, 21 Feb 2009 08:36:15 -0500 (EST)
Received: by ug-out-1314.google.com with SMTP id 29so114233ugc.19
        for <linux-mm@kvack.org>; Sat, 21 Feb 2009 05:36:13 -0800 (PST)
From: Vegard Nossum <vegard.nossum@gmail.com>
Subject: 
Date: Sat, 21 Feb 2009 14:36:00 +0100
Message-Id: <1235223364-2097-1-git-send-email-vegard.nossum@gmail.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Hi,

Here comes a kmemcheck update. I found out how to solve the P4 REP problem
cleanly, and by adding the right hooks in the DMA API, we were able to get
page-allocator support with no additional false positives.

 arch/x86/include/asm/dma-mapping.h |    6 ++
 arch/x86/include/asm/thread_info.h |    4 +-
 arch/x86/kernel/cpu/intel.c        |   23 +++++++
 arch/x86/mm/kmemcheck/kmemcheck.c  |  119 +-----------------------------------
 arch/x86/mm/kmemcheck/opcode.c     |   13 +----
 arch/x86/mm/kmemcheck/opcode.h     |    3 +-
 arch/x86/mm/kmemcheck/shadow.c     |    8 +++
 include/linux/gfp.h                |    5 ++
 include/linux/kmemcheck.h          |   33 +++++++++--
 mm/kmemcheck.c                     |   45 ++++++++++----
 mm/page_alloc.c                    |    8 +++
 mm/slab.c                          |   15 +++--
 mm/slub.c                          |   23 ++++++--
 13 files changed, 143 insertions(+), 162 deletions(-)

(Ingo: Don't apply to -tip, I'll send a pull request later.)


Vegard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
