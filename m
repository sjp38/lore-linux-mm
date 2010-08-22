Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 697C8600044
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 11:18:02 -0400 (EDT)
Date: Sun, 22 Aug 2010 18:17:58 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: [GIT PULL] SLAB fixes for 2.6.36-rc2
Message-ID: <alpine.DEB.2.00.1008221816590.3858@tiger>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: torvalds@linux-foundation.org
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus,

Here's two minor bug fixes for SLAB and SLUB.

                         Pekka

The following changes since commit e36c886a0f9d624377977fa6cae309cfd7f362fa:
   Arjan van de Ven (1):
         workqueue: Add basic tracepoints to track workqueue execution

are available in the git repository at:

   ssh://master.kernel.org/pub/scm/linux/kernel/git/penberg/slab-2.6.git for-linus

Carsten Otte (1):
       slab: fix object alignment

Namhyung Kim (1):
       slub: add missing __percpu markup in mm/slub_def.h

  include/linux/slub_def.h |    2 +-
  mm/slab.c                |    4 ++--
  2 files changed, 3 insertions(+), 3 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
