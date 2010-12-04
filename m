Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B7B646B00A2
	for <linux-mm@kvack.org>; Sat,  4 Dec 2010 03:00:49 -0500 (EST)
Date: Sat, 4 Dec 2010 10:00:38 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: [GIT PULL] SLAB fixes for 2.6.37-rc5
Message-ID: <alpine.DEB.2.00.1012040956400.6566@tiger>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: torvalds@linux-foundation.org
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus,

Here's an urgent SLUB bug fix from Tero Roponen that fixes a 
root-triggerable oops.

                         Pekka

The following changes since commit 11e8896474495dec7ce19a542f67def847ec208f:
   Linus Torvalds (1):
         Merge branch '2.6.37-rc4-pvhvm-fixes' of git://xenbits.xen.org/people/sstabellini/linux-pvhvm

are available in the git repository at:

   ssh://master.kernel.org/pub/scm/linux/kernel/git/penberg/slab-2.6.git slab/urgent

Tero Roponen (1):
       slub: Fix a crash during slabinfo -v

  mm/slub.c |    4 ++--
  1 files changed, 2 insertions(+), 2 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
