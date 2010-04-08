Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1D45B620097
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 22:58:44 -0400 (EDT)
Date: Thu, 8 Apr 2010 12:58:22 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look
 please!...)
Message-ID: <20100408025822.GL11036@dastard>
References: <02c101cacbf8$d21d1650$0400a8c0@dcccs>
 <179901cad182$5f87f620$0400a8c0@dcccs>
 <t2h2375c9f91004010337p618c4d5yc739fa25b5f842fa@mail.gmail.com>
 <1fe901cad2b0$d39d0300$0400a8c0@dcccs>
 <20100402230905.GW3335@dastard>
 <22c901cad333$7a67db60$0400a8c0@dcccs>
 <20100404103701.GX3335@dastard>
 <2bd101cad4ec$5a425f30$0400a8c0@dcccs>
 <20100405224522.GZ3335@dastard>
 <3a5f01cad6c5$8a722c00$0400a8c0@dcccs>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3a5f01cad6c5$8a722c00$0400a8c0@dcccs>
Sender: owner-linux-mm@kvack.org
To: Janos Haar <janos.haar@netcenter.hu>
Cc: xiyou.wangcong@gmail.com, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, xfs@oss.sgi.com, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Thu, Apr 08, 2010 at 04:45:13AM +0200, Janos Haar wrote:
> Hello,
> 
> Sorry, but still have the problem with 2.6.33.2.

Yeah, these still a fix that needs to be back ported to .33
to solve this problem. It's in the series for 2.6.32.x, so maybe
pulling the 2.6.32-stable-queue tree in the meantime is your best
bet.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
