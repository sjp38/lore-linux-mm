Date: Tue, 10 Jul 2007 20:38:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: -mm merge plans -- anti-fragmentation
Message-Id: <20070710203848.e7bbc98e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070710111202.GC25512@skynet.ie>
References: <20070710102043.GA20303@skynet.ie>
	<20070710200115.b5bbfb4a.kamezawa.hiroyu@jp.fujitsu.com>
	<20070710111202.GC25512@skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de, kenchen@google.com, jschopp@austin.ibm.com, apw@shadowen.org, a.p.zijlstra@chello.nl, y-goto@jp.fujitsu.com, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jul 2007 12:12:02 +0100
mel@skynet.ie (Mel Gorman) wrote:
> > For (2), we need some method for specifing the range we will remove. For doing that,
> > ZONE seems to be good candidate.  Now we use "kernelcore=" boot option to create
> > ZONE_MOVABLE by hand.
> 
> At the risk of putting you on the spot, do you mind saying whether the
> grouping pages by mobility and ZONE_MOVABLE patches are going in the
> direction you want or should something totally different be done? If
> they are going the right direction, is there anything critical that is
> missing right now?
> 
"grouping pages by mobility and ZONE_MOVABLE" things are what I want. And
I want to go with them. But I know some people doesn't want to increase #
of zones. It is my concern. 
I know ZONE_MOVABLE works well but there are people who don't want new zone.
So making ZONE_MOVABLE as configurable will be good thing, as Nick Piggin pointed.

About my other concerns , see node hotplug (below).

> > But this is the first step. I know Intel guy posted
> > his idea to specify Hotpluggable-Memory range in SRAT (by firmware).
> 
> There may be additional work required to make this play nicely with
> ZONE_MOVABLE but it shouldn't be anything fundamental.
> 
yes. And I don't know his idea about SRAT is acceped in firmware comunity or not.
For now, kernelcore= works enough for memory hotplug.

> > And I think that
> > other method may be introduced for node-hotplug. 
> > 
> 
> Same as above really. If the node contains one zone - ZONE_MOVABLE, it
> would work for unplugging.
> 
Our concern on node hotplug is "bootmem" and hashtable , pgdata, memmap etc....
NUMA initilization (of each arch) includes something complicated.
But this is not directly related to ZONE_MOVABLE things I think.
It's node-hotplug problem.
We are now consdiering hot-add nodes after initcalls().

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
