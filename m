Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DE5286B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 14:41:33 -0400 (EDT)
Received: by ewy9 with SMTP id 9so255455ewy.14
        for <linux-mm@kvack.org>; Tue, 09 Aug 2011 11:41:30 -0700 (PDT)
Date: Tue, 9 Aug 2011 21:41:23 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: [GIT PULL] SLUB fixes for v3.1-rc1
Message-ID: <alpine.DEB.2.00.1108092140360.678@tiger>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Linus,

Here's one more fix for SLUB debugging code. I didn't send it as part of the
previous batch because Dave Jones didn't indicate that it was needed to fix the
corruption issue. It was, however, included in Xiaotian Feng's testing so it's
best to include it in mainline as well and the problem is pretty obvious when
reading the code.

I've tested the patch lightly on x86-64 SMP machine by compiling the kernel
with SLUB debugging and list debugging enabled.

                         Pekka

The following changes since commit e6a99d312687a42c077a9b8cb5e757f186edb1b9:
   Linus Torvalds (1):
         Merge branch 'slab/urgent' of git://git.kernel.org/.../penberg/slab-2.6

are available in the git repository at:

   ssh://master.kernel.org/pub/scm/linux/kernel/git/penberg/slab-2.6.git slab/urgent

Christoph Lameter (1):
       slub: Fix partial count comparison confusion

  mm/slub.c |    2 +-
  1 files changed, 1 insertions(+), 1 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
