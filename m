Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
From: Mel Gorman <mel@csn.ul.ie>
In-Reply-To: <1189695715.5013.58.camel@localhost>
References: <20070830185053.22619.96398.sendpatchset@localhost>
	 <1189527657.5036.35.camel@localhost>
	 <Pine.LNX.4.64.0709121515210.3835@schroedinger.engr.sgi.com>
	 <1189691837.5013.43.camel@localhost>  <1189697488.17924.2.camel@localhost>
	 <1189695715.5013.58.camel@localhost>
Content-Type: text/plain
Date: Thu, 13 Sep 2007 19:55:12 +0100
Message-Id: <1189709712.21101.2.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-09-13 at 11:01 -0400, Lee Schermerhorn wrote:
> On Thu, 2007-09-13 at 16:31 +0100, Mel Gorman wrote:
> > On Thu, 2007-09-13 at 09:57 -0400, Lee Schermerhorn wrote:
> > > On Wed, 2007-09-12 at 15:17 -0700, Christoph Lameter wrote:
> > > > On Tue, 11 Sep 2007, Lee Schermerhorn wrote:
> > > > 
> > > > > Andi, Christoph, Mel [added to cc]:
> > > > > 
> > > > > Any comments on these patches, posted 30aug?  I've rebased to
> > > > > 23-rc4-mm1, but before reposting, I wanted to give you a chance to
> > > > > comment.
> > > > 
> > > > Sorry that it took some time but I only just got around to look at them. 
> > > > The one patch that I acked may be of higher priority and should probably 
> > > > go in immediately to be merged for 2.6.24.
> > > 
> > > OK.  I'll pull that from the set and post it separately.  I'll see if it
> > > conflicts with Mel's set.  If so, we'll need to decide on the ordering.
> > > Do we think Mel's patches will make .24?
> > > 
> > 
> > I am hoping they will. They remove the nasty hack in relation to
> > MPOL_BIND applying to the top two highest zones when ZONE_MOVABLE is
> > configured and let MPOL_BIND use a node-local policy which I feel is
> > important. There hasn't been a consensus on this yet and I would expect
> > that to be hashed out at the start of the merge window as usual.
> 
> OK.  I haven't had a chance to check your patch for the mem controller
> issue yet.  Should I test with your latest series that uses the struct
> containing the zone id?  I know that Christoph had concerns about
> increasing the number of cache lines.  Which way do you think we'll go
> on this?
> 

I think we'll be going with the struct with zone id for the moment.
Christoph's concerns are valid but it's an easier starting point for
trying out optimisations in the page allocator path. We may end up doing
the pointer packing after a while if there are no better optimisations
but we should have a flexible starting point.

I've sent you V7 so hopefully it'll pass your tests.

Thanks

-- 
Mel Gorman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
