Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 83B1A6B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 04:17:01 -0400 (EDT)
Date: Wed, 15 Sep 2010 10:16:53 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC][PATCH] Cross Memory Attach
Message-ID: <20100915081653.GA16406@elte.hu>
References: <20100915104855.41de3ebf@lilo>
 <20100915080235.GA13152@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100915080235.GA13152@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Christopher Yeoh <cyeoh@au1.ibm.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> > NPB:
> > ====
> > BT - 12% improvement
> > FT - 15% improvement
> > IS - 30% improvement
> > SP - 34% improvement
> > 
> > IMB:
> > ===
> > 		
> > Ping Pong - ~30% improvement
> > Ping Ping - ~120% improvement
> > SendRecv - ~100% improvement
> > Exchange - ~150% improvement
> > Gather(v) - ~20% improvement
> > Scatter(v) - ~20% improvement
> > AlltoAll(v) - 30-50% improvement

btw., how does OpenMPI signal the target tasks that something happened 
to their address space - is there some pipe/socket side-channel, or 
perhaps purely based on flags in the modified memory areas, which are 
polled?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
