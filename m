Date: Fri, 14 Sep 2007 09:53:36 +0100
Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
Message-ID: <20070914085335.GA30407@skynet.ie>
References: <20070830185053.22619.96398.sendpatchset@localhost> <1189527657.5036.35.camel@localhost> <Pine.LNX.4.64.0709121515210.3835@schroedinger.engr.sgi.com> <1189691837.5013.43.camel@localhost> <Pine.LNX.4.64.0709131118190.9378@schroedinger.engr.sgi.com> <20070913182344.GB23752@skynet.ie> <Pine.LNX.4.64.0709131124100.9378@schroedinger.engr.sgi.com> <20070913141704.4623ac57.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070913141704.4623ac57.akpm@linux-foundation.org>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On (13/09/07 14:17), Andrew Morton didst pronounce:
> On Thu, 13 Sep 2007 11:26:19 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > On Thu, 13 Sep 2007, Mel Gorman wrote:
> > 
> > > What do you see holding it up? Is it the fact we are no longer doing the
> > > pointer packing and you don't want that structure to exist, or is it simply
> > > a case that 2.6.23 is too close the door and it won't get adequate
> > > coverage in -mm?
> > 
> > No its not the pointer packing. The problem is that the patches have not 
> > been merged yet and 2.6.23 is close. We would need to merge it very soon 
> > and get some exposure in mm. Andrew?
> 
> You rang?
> 
> To which patches do you refer?  "Memory Policy Cleanups and Enhancements"? 
> That's still in my queue somewhere, but a) it has "RFC" in it which usually
> makes me run away and b) we already have no fewer than 221 memory
> management patches queued.
> 

Christoph's question is in relation to the patchset "Use one zonelist per
node instead of multiple zonelists v7" and whether one zonelist will be
merged in 2.6.24 in your opinion. I am hoping "yes" because it removes that
hack with ZONE_MOVABLE and policies. I had sent you a version (v5) but there
were further suggestions on ways to improve it so we're up to v7 now. Lee
will hopefully be able to determine if v7 regresses policy behaviour or not.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
