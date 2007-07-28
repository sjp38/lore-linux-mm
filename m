Date: Sat, 28 Jul 2007 23:21:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: NUMA policy issues with ZONE_MOVABLE
Message-Id: <20070728232154.d84f0bcb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070728231032.2ec7bd35.kamezawa.hiroyu@jp.fujitsu.com>
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
	<20070728231032.2ec7bd35.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: mel@csn.ul.ie, clameter@sgi.com, linux-mm@kvack.org, Lee.Schermerhorn@hp.com, ak@suse.de, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Sat, 28 Jul 2007 23:10:32 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > H1N1D1H2N2D2H3N3D3 instead of
> > H1H2H3N1N2N3D1D2D3
> > 
> > If it's node-order, does this scheme break?
> > 
> 
> Maybe no. "skip" will point to the nearest available zone anyway.
> But there may be better scheme. This is jus an easy idea.
> 
Assume zonelist on Node0, 

zone order:  M0M1M2M3N0N1N2N3D0 (only node 0 has zone dma)
node order:  M0N0D0M1N1M2N2N3  

GFP_KERNEL for zone_order: skip 4, find N0N2N3D0
GFP_KERNEL for node_order: skip 1, find N0D0N2N3

I'm not sure that this easy trick can show performance benefit.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
