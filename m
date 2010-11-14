Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 76D6B8D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 09:55:41 -0500 (EST)
Date: Sun, 14 Nov 2010 16:55:36 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: [GIT PULL] SLAB fixes for 2.6.37-rc2
Message-ID: <alpine.DEB.2.00.1011141654110.4490@tiger>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: torvalds@linux-foundation.org
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus,

Here's a small SLUB locking bug fix from Pavel Emelyanov.

                         Pekka

The following changes since commit 151f52f09c5728ecfdd0c289da1a4b30bb416f2c:
   Linus Torvalds (1):
         ipw2x00: remove the right /proc/net entry

are available in the git repository at:

   ssh://master.kernel.org/pub/scm/linux/kernel/git/penberg/slab-2.6.git for-linus

Pavel Emelyanov (1):
       slub: Fix slub_lock down/up imbalance

  mm/slub.c |    3 ++-
  1 files changed, 2 insertions(+), 1 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
