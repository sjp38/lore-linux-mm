Subject: Re: Page allocator: Single Zone optimizations
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0611031012140.14741@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
	 <20061027190452.6ff86cae.akpm@osdl.org>
	 <Pine.LNX.4.64.0610271907400.10615@schroedinger.engr.sgi.com>
	 <20061027192429.42bb4be4.akpm@osdl.org>
	 <Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com>
	 <20061027214324.4f80e992.akpm@osdl.org>
	 <Pine.LNX.4.64.0610281743260.14058@schroedinger.engr.sgi.com>
	 <20061028180402.7c3e6ad8.akpm@osdl.org>
	 <Pine.LNX.4.64.0610281805280.14100@schroedinger.engr.sgi.com>
	 <4544914F.3000502@yahoo.com.au> <20061101182605.GC27386@skynet.ie>
	 <20061101123451.3fd6cfa4.akpm@osdl.org>
	 <Pine.LNX.4.64.0611012155340.29614@skynet.skynet.ie>
	 <454A2CE5.6080003@shadowen.org>
	 <Pine.LNX.4.64.0611021004270.8098@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0611022053490.27544@skynet.skynet.ie>
	 <Pine.LNX.4.64.0611021345140.9877@schroedinger.engr.sgi.com>
	 <1162558085.26989.17.camel@twins>
	 <Pine.LNX.4.64.0611031012140.14741@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 03 Nov 2006 19:53:03 +0100
Message-Id: <1162579983.26989.27.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-11-03 at 10:15 -0800, Christoph Lameter wrote:
> On Fri, 3 Nov 2006, Peter Zijlstra wrote:
> 
> > > I think talking about reclaim here is not what you want. 
> > 
> > I think it is; all of this only matters at the moment you want to
> > allocate a large page, at that time you need to reclaim memory to
> > satisfy the request. (There is some hysteresis between alloc and
> > reclaim; but lets ignore that for a moment.)
> 
> That is wrong. Dropping pages that will later have to be reread is not 
> good. It is better to defrag by moving pages.

> > The ability to move pages about that are otherwise unreclaimable does
> > indeed open up a new class of pages. But moving pages about is not the
> > main purpose; attaining linear free pages with the least amount of
> > collateral damage is.
> 
> IMHO Moving pages creates less collateral damage than evicting 
> random pages.

Move them where?, you have to drop pages anyway, the only thing
migrate_pages() (my bad for calling it move_pages()) might help with is
preserving LRU order better and the possibility to move otherwise
unreclaimable pages to a more favourable position (page-tables,
mlock'ed).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
