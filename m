Date: Tue, 10 Jul 2007 12:12:02 +0100
Subject: Re: -mm merge plans -- anti-fragmentation
Message-ID: <20070710111202.GC25512@skynet.ie>
References: <20070710102043.GA20303@skynet.ie> <20070710200115.b5bbfb4a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070710200115.b5bbfb4a.kamezawa.hiroyu@jp.fujitsu.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de, kenchen@google.com, jschopp@austin.ibm.com, apw@shadowen.org, a.p.zijlstra@chello.nl, y-goto@jp.fujitsu.com, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (10/07/07 20:01), KAMEZAWA Hiroyuki didst pronounce:
> On Tue, 10 Jul 2007 11:20:43 +0100
> mel@skynet.ie (Mel Gorman) wrote:
> > > memory-unplug-v7-migration-by-kernel.patch
> > > memory-unplug-v7-isolate_lru_page-fix.patch
> > > memory-unplug-v7-memory-hotplug-cleanup.patch
> > > memory-unplug-v7-page-isolation.patch
> > > memory-unplug-v7-page-offline.patch
> > > memory-unplug-v7-ia64-interface.patch
> > > 
> > >  These are new, and are dependent on Mel's stuff.  Not for 2.6.23.
> > > 
> > 
> > Specifically, they depend on grouping pages by mobility for the page
> > isolation patch. Without grouping pages by mobility, that patch gets
> > pretty messy. For the operation to succeed at all, it benefits from the
> > ZONE_MOVABLE patches. Kamezawa is cc'd so he might comment further.
> > 
> 
> In gerneal, there are 2 purpose for memory unplug.
> (1) reduce amount of memory.
> (2) plug some range of memory.
> 
> (1) is request from people who use some flexible environment, like virtual machine,
> LPAR. (2) is request from people who want to remove physical DIMM deivces.
> 
> For (1), page movable type and page defragment works very well. Because memory unplug
> interface allows removing a section of pages, we need to unplug the whole section.
> By page grouping, pages are grouped into chunks and MOVABLE type chunk can be unplugged
> very easily.
> 
> For (2), we need some method for specifing the range we will remove. For doing that,
> ZONE seems to be good candidate.  Now we use "kernelcore=" boot option to create
> ZONE_MOVABLE by hand.

At the risk of putting you on the spot, do you mind saying whether the
grouping pages by mobility and ZONE_MOVABLE patches are going in the
direction you want or should something totally different be done? If
they are going the right direction, is there anything critical that is
missing right now?

> But this is the first step. I know Intel guy posted
> his idea to specify Hotpluggable-Memory range in SRAT (by firmware).

There may be additional work required to make this play nicely with
ZONE_MOVABLE but it shouldn't be anything fundamental.

> And I think that
> other method may be introduced for node-hotplug. 
> 

Same as above really. If the node contains one zone - ZONE_MOVABLE, it
would work for unplugging.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
