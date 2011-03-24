Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8C07F8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 15:56:23 -0400 (EDT)
Date: Thu, 24 Mar 2011 21:56:15 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: [GIT PULL] SLAB fixes for v2.6.39-rc1
Message-ID: <alpine.DEB.2.00.1103242154440.16149@tiger>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu

Hi Linus,

Here's two urgent fixes to SLUB reported by Ingo:

https://lkml.org/lkml/2011/3/24/245

The first one is boot-time oops on x86 with PREEMPT_NONE and CPUs that 
don't support cmpxch16b. The second one is debugobjects regression caused 
by the lockless fastpaths.

                         Pekka

The following changes since commit 6d1e9a42e7176bbce9348274784b2e5f69223936:
   Linus Torvalds (1):
         Merge branch 'release' of git://git.kernel.org/.../aegl/linux-2.6

are available in the git repository at:

   ssh://master.kernel.org/pub/scm/linux/kernel/git/penberg/slab-2.6.git slab/urgent

Christoph Lameter (1):
       SLUB: Write to per cpu data when allocating it

Thomas Gleixner (1):
       slub: Fix debugobjects with lockless fastpath

  mm/slub.c |    6 +++---
  1 files changed, 3 insertions(+), 3 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
