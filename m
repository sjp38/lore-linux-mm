Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E6153900137
	for <linux-mm@kvack.org>; Sun, 31 Jul 2011 11:17:42 -0400 (EDT)
Received: by fxg9 with SMTP id 9so5293852fxg.14
        for <linux-mm@kvack.org>; Sun, 31 Jul 2011 08:17:40 -0700 (PDT)
Date: Sun, 31 Jul 2011 18:17:33 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: [GIT PULL] SLAB updates for 3.1-rc1
Message-ID: <alpine.DEB.2.00.1107311817140.4008@tiger>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Linus,

Here's two final slab updates. Eric's patch reduces memory usage for slab
internal data structures even mor for high NR_CPU configurations.

                         Pekka

The following changes since commit 250f8e3db646028353a2a737ddb7a894c97a1098:
   Linus Torvalds (1):
         Merge branch 'for-linus' of git://git.kernel.org/.../jikos/trivial

are available in the git repository at:

   ssh://master.kernel.org/pub/scm/linux/kernel/git/penberg/slab-2.6.git for-linus

Andrew Morton (1):
       slab: use NUMA_NO_NODE

Eric Dumazet (1):
       slab: remove one NR_CPUS dependency

  mm/slab.c |    7 ++++---
  1 files changed, 4 insertions(+), 3 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
