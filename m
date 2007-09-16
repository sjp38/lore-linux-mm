Date: Sun, 16 Sep 2007 22:22:58 +0100
Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
Message-ID: <20070916212258.GF16406@skynet.ie>
References: <Pine.LNX.4.64.0709121515210.3835@schroedinger.engr.sgi.com> <1189691837.5013.43.camel@localhost> <Pine.LNX.4.64.0709131118190.9378@schroedinger.engr.sgi.com> <20070913182344.GB23752@skynet.ie> <Pine.LNX.4.64.0709131124100.9378@schroedinger.engr.sgi.com> <20070913141704.4623ac57.akpm@linux-foundation.org> <20070914085335.GA30407@skynet.ie> <1189800926.5315.76.camel@localhost> <20070916180527.GB15184@skynet.ie> <20070916123459.79e0848a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070916123459.79e0848a.akpm@linux-foundation.org>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On (16/09/07 12:34), Andrew Morton didst pronounce:
> On Sun, 16 Sep 2007 19:05:27 +0100 mel@skynet.ie (Mel Gorman) wrote:
> 
> > > I'm still trying to absorb the patches, but so far they look good.
> > > Perhaps Andrew can tack them onto the bottom of the next -mm so that if
> > > someone else finds issues, they won't complicate merging earlier patches
> > > upstream?
> > > 
> > 
> > I hope so. Andrew, how do you feel about pulling V7 into -mm?
> 
> umm, sure, once the churn rate falls to less than one new revision per day?
> 

I don't intend to revise it any more except in response to bugs. Lee's tests
have gone well and no one has reported performance problems.

The suggestion for future revision was putting node-id in the struct zoneref
that makes up the zonelist but that needs to be justified because it's not
a zero-cost to add with 32 bit NUMA. I don't intend to go back to packing
the zone_id into a pointer because the code is a little opaque and it's not
clear it gains in performance.  We might justify it later because "clearly
it uses less cache" but it's not a decision that is going to be made in a day.

> I need to get rc6-mm1 out, and it'll be crap, and it'll need another -mm shortly
> after that to get things vaguely stable.
> 

If you want to wait until the -mm after rc6-mm1, that's fine. I don't intend
to revise the patches for the moment so hopefully I can put the time
into helping debug -mm instead.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
