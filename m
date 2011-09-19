Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 81B7D9000BD
	for <linux-mm@kvack.org>; Mon, 19 Sep 2011 10:50:15 -0400 (EDT)
Received: by bkbzs2 with SMTP id zs2so6907557bkb.14
        for <linux-mm@kvack.org>; Mon, 19 Sep 2011 07:50:12 -0700 (PDT)
Date: Mon, 19 Sep 2011 17:50:09 +0300 (EEST)
From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: [GIT PULL] SLUB fix for v3.1-rc7
Message-ID: <alpine.DEB.2.00.1109191748030.7992@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Linus,

Here's a one-line SLUB hackbench performance regression fix from Shaohua 
Li. It's been sitting in linux-next for a while now and wasn't sent to you 
earlier due to git.kernel.org issues.

                         Pekka

The following changes since commit b0e7031ac08fa0aa242531c8d9a0cf9ae8ee276d:

   Merge git://github.com/davem330/net (2011-09-18 11:02:26 -0700)

are available in the git repository at:

   git@github.com:penberg/linux.git slab/urgent

Shaohua Li (1):
       slub: add slab with one free object to partial list tail

  mm/slub.c |    2 +-
  1 files changed, 1 insertions(+), 1 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
