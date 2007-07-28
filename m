Date: Sat, 28 Jul 2007 23:10:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: NUMA policy issues with ZONE_MOVABLE
Message-Id: <20070728231032.2ec7bd35.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0707281255480.7824@skynet.skynet.ie>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
	<20070725111646.GA9098@skynet.ie>
	<Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
	<20070726132336.GA18825@skynet.ie>
	<Pine.LNX.4.64.0707261104360.2374@schroedinger.engr.sgi.com>
	<20070726225920.GA10225@skynet.ie>
	<Pine.LNX.4.64.0707261819530.18210@schroedinger.engr.sgi.com>
	<20070727082046.GA6301@skynet.ie>
	<20070727154519.GA21614@skynet.ie>
	<20070728162844.9d5b8c6e.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0707281255480.7824@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: clameter@sgi.com, linux-mm@kvack.org, Lee.Schermerhorn@hp.com, ak@suse.de, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Sat, 28 Jul 2007 12:57:09 +0100 (IST)
Mel Gorman <mel@csn.ul.ie> wrote:

> > I like this idea in general. My concern is zonelist scan cost.
> > Hmm, can this be help ?
> >
> 
> Does this not make the assumption that the zonelists are in zone-order as 
> opposed to node? i.e. that is is
> 
> H1N1D1H2N2D2H3N3D3 instead of
> H1H2H3N1N2N3D1D2D3
> 
> If it's node-order, does this scheme break?
> 

Maybe no. "skip" will point to the nearest available zone anyway.
But there may be better scheme. This is jus an easy idea.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
