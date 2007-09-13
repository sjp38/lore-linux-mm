Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
From: Mel Gorman <mel@csn.ul.ie>
In-Reply-To: <1189691837.5013.43.camel@localhost>
References: <20070830185053.22619.96398.sendpatchset@localhost>
	 <1189527657.5036.35.camel@localhost>
	 <Pine.LNX.4.64.0709121515210.3835@schroedinger.engr.sgi.com>
	 <1189691837.5013.43.camel@localhost>
Content-Type: text/plain
Date: Thu, 13 Sep 2007 16:31:28 +0100
Message-Id: <1189697488.17924.2.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-09-13 at 09:57 -0400, Lee Schermerhorn wrote:
> On Wed, 2007-09-12 at 15:17 -0700, Christoph Lameter wrote:
> > On Tue, 11 Sep 2007, Lee Schermerhorn wrote:
> > 
> > > Andi, Christoph, Mel [added to cc]:
> > > 
> > > Any comments on these patches, posted 30aug?  I've rebased to
> > > 23-rc4-mm1, but before reposting, I wanted to give you a chance to
> > > comment.
> > 
> > Sorry that it took some time but I only just got around to look at them. 
> > The one patch that I acked may be of higher priority and should probably 
> > go in immediately to be merged for 2.6.24.
> 
> OK.  I'll pull that from the set and post it separately.  I'll see if it
> conflicts with Mel's set.  If so, we'll need to decide on the ordering.
> Do we think Mel's patches will make .24?
> 

I am hoping they will. They remove the nasty hack in relation to
MPOL_BIND applying to the top two highest zones when ZONE_MOVABLE is
configured and let MPOL_BIND use a node-local policy which I feel is
important. There hasn't been a consensus on this yet and I would expect
that to be hashed out at the start of the merge window as usual.

> > 
> > > I'm going to add Mel's "one zonelist" series to my mempolicy tree with
> > > these patches and see how that goes.  I'll slide Mel's patches in below
> > > these, as it looks like they're closer to acceptance into -mm.
> > 
> > That patchset will have a significant impact on yours. You may be able to 
> > get rid of some of the switch statements. It would be great if we had some 
> > description as to where you are heading with the incremental changes to 
> > the memory policy semantics? I sure wish we would have something more 
> > consistent and easier to understand.
> 
> The general reaction to such descriptions is "show me the code."  So, if
> we agree that Mel's patches should go first, I'll rebase and update the
> numa_memory_policy doc accordingly to explain the resulting semantics.
> Perhaps Mel should considering updating that document where his patches
> change/invalidate the current descriptions.
> 

Yes, I should be. When the patches finalise (any day now *sigh*), I'll
reread the documentation and see what I have affected and send a
follow-up patch.

> Does this sound like a resonable way to proceed?
> 

Yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
