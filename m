Date: Sun, 15 Jul 2007 22:47:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Add a movablecore= parameter for sizing ZONE_MOVABLE
Message-Id: <20070715224757.6432e977.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070714130207.GA15864@skynet.ie>
References: <20070710102043.GA20303@skynet.ie>
	<20070712122925.192a6601.akpm@linux-foundation.org>
	<20070712213241.GA7279@skynet.ie>
	<20070713155610.GD14125@skynet.ie>
	<20070714082807.GC1198@wotan.suse.de>
	<20070714130207.GA15864@skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: npiggin@suse.de, akpm@linux-foundation.org, kenchen@google.com, jschopp@austin.ibm.com, apw@shadowen.org, a.p.zijlstra@chello.nl, y-goto@jp.fujitsu.com, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 14 Jul 2007 14:02:08 +0100
mel@skynet.ie (Mel Gorman) wrote:
> > What's the status of making it configurable? I didn't see something
> > in -mm for that yet?
> > 
> 
> I have a patch that makes it configurable but Kamezawa-san posted a very
> promising patch about making all zones configurable in a very clever way
> which is more general than what I did. He posted it as an RFC[1] and there
> was feedback from Andy Whitcroft on how it could be made better so it wouldn't
> have been picked up for -mm but something is in the pipeline.
> 
I'll post it when I can. against the newest -mm.

> I've tested his patch for zone movable and it worked as advertised so I
> intended to see post-merge window what else could be done with it clean-up
> wise. I am curious to see if it can also make ZONE_NORMAL configurable on
> machines that only have ZONE_DMA for example.
> 
I think it as an interesting idea, Hmm....

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
