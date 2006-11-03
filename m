Date: Fri, 3 Nov 2006 14:15:53 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <20061103141218.8dbdbd14.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0611031413100.16603@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
 <20061101123451.3fd6cfa4.akpm@osdl.org> <Pine.LNX.4.64.0611012155340.29614@skynet.skynet.ie>
 <454A2CE5.6080003@shadowen.org> <Pine.LNX.4.64.0611021004270.8098@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611022053490.27544@skynet.skynet.ie>
 <Pine.LNX.4.64.0611021345140.9877@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611022153491.27544@skynet.skynet.ie>
 <Pine.LNX.4.64.0611021442210.10447@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611030900480.9787@skynet.skynet.ie>
 <Pine.LNX.4.64.0611030952530.14741@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611031825420.25219@skynet.skynet.ie>
 <Pine.LNX.4.64.0611031124340.15242@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611032101190.25219@skynet.skynet.ie>
 <Pine.LNX.4.64.0611031329480.16397@schroedinger.engr.sgi.com>
 <20061103135013.6bdc6240.akpm@osdl.org> <Pine.LNX.4.64.0611031352420.16486@schroedinger.engr.sgi.com>
 <20061103141218.8dbdbd14.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Nov 2006, Andrew Morton wrote:

> That's possibly useful if the cache has a destructor.  If it has a
> constructor and no destructor then there's no point in locally caching the
> pages.
> 
> But destructors are a bad idea: you dirty a cacheline, evict something else
> and then let the cacheline just sit there and go stale.

Right thats why I tried to avoid constructors and destructors for the new 
slab design but it is important for RCU since the object must be in a 
defined state even after a free. i386 arch code does some weird wizardry 
with it. So I had to add a support layer.

> But I thought that slab once-upon-a-time retained caches of plain old free
> pages, not in any particular state.  Maybe it did and maybe we did remove
> that.

Must have been before my time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
