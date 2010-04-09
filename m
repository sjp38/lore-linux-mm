Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id ACC3F6B0230
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 17:37:37 -0400 (EDT)
Date: Fri, 9 Apr 2010 14:37:15 -0700 (PDT)
From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look
 please!...)
In-Reply-To: <00bb01cad70d$a814c2c0$0400a8c0@dcccs>
Message-ID: <alpine.DEB.2.01.1004091435170.29272@bogon.housecafe.de>
References: <02c101cacbf8$d21d1650$0400a8c0@dcccs> <179901cad182$5f87f620$0400a8c0@dcccs> <t2h2375c9f91004010337p618c4d5yc739fa25b5f842fa@mail.gmail.com> <1fe901cad2b0$d39d0300$0400a8c0@dcccs> <20100402230905.GW3335@dastard> <22c901cad333$7a67db60$0400a8c0@dcccs>
 <20100404103701.GX3335@dastard> <2bd101cad4ec$5a425f30$0400a8c0@dcccs> <20100405224522.GZ3335@dastard> <3a5f01cad6c5$8a722c00$0400a8c0@dcccs> <20100408025822.GL11036@dastard> <00bb01cad70d$a814c2c0$0400a8c0@dcccs>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Janos Haar <janos.haar@netcenter.hu>
Cc: Dave Chinner <david@fromorbit.com>, axboe@kernel.dk, LKML <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com, linux-mm@kvack.org, xiyou.wangcong@gmail.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 8 Apr 2010 at 13:21, Janos Haar wrote:
> > Yeah, these still a fix that needs to be back ported to .33
> > to solve this problem. It's in the series for 2.6.32.x, so maybe
> > pulling the 2.6.32-stable-queue tree in the meantime is your best
> > bet.
> 
> Ok, thank you.
> But where can i find this tree?


Perhaps Dave meant the stable-queue?

http://git.kernel.org/?p=linux/kernel/git/stable/stable-queue.git

Then again, 2.6.34-rc3 needs testing too! :-)

Christian.
-- 
BOFH excuse #98:

The vendor put the bug there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
