Date: Tue, 5 Dec 2006 10:26:54 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Add __GFP_MOVABLE for callers to flag allocations that
 may be migrated
Message-Id: <20061205102654.19165150.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0612050803000.11213@schroedinger.engr.sgi.com>
References: <20061130170746.GA11363@skynet.ie>
	<20061130173129.4ebccaa2.akpm@osdl.org>
	<Pine.LNX.4.64.0612010948320.32594@skynet.skynet.ie>
	<20061201110103.08d0cf3d.akpm@osdl.org>
	<20061204140747.GA21662@skynet.ie>
	<20061204113051.4e90b249.akpm@osdl.org>
	<Pine.LNX.4.64.0612041946460.26428@skynet.skynet.ie>
	<20061204143435.6ab587db.akpm@osdl.org>
	<Pine.LNX.4.64.0612042338390.2108@skynet.skynet.ie>
	<20061205101629.5cb78828.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0612050952500.11807@skynet.skynet.ie>
	<Pine.LNX.4.64.0612050803000.11213@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, apw@shadowen.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Dec 2006 08:05:16 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 5 Dec 2006, Mel Gorman wrote:
> 
> > That is one possibility. There are people working on fake nodes for containers
> > at the moment. If that pans out, the infrastructure would be available to
> > create one node per DIMM.
> 
> Right that is a hack in use for one project.

Other projects can use it too.  It has the distinct advantage that it works
with today's VM.

> We would be adding huge 
> amounts of VM overhead if we do a node per DIMM.

No we wouldn't.

> So a desktop system with two dimms is to be treated like a NUMA 
> system?

Could do that.  Or make them separate zones.

> Or how else do we deal with the multitude of load balancing 
> situations that the additional nodes will generate?

No such problems are known.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
