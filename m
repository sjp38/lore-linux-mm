Date: Tue, 10 Jul 2007 14:24:59 +0100
Subject: Re: -mm merge plans -- anti-fragmentation
Message-ID: <20070710132459.GB9426@skynet.ie>
References: <20070710102043.GA20303@skynet.ie> <1184065445.5281.16.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1184065445.5281.16.camel@lappy>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de, kenchen@google.com, jschopp@austin.ibm.com, apw@shadowen.org, kamezawa.hiroyu@jp.fujitsu.com, y-goto@jp.fujitsu.com, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (10/07/07 13:04), Peter Zijlstra didst pronounce:
> On Tue, 2007-07-10 at 11:20 +0100, Mel Gorman wrote:
> 
> <snip>
> 
> > > lumpy-reclaim-v4.patch
> > 
> > This patch is really what lumpy reclaim is. I believe Peter has looked
> > at this and was happy enough at the time although he is cc'd here again
> > in case this has changed. This is mainly useful with either grouping
> > pages by mobility or the ZONE_MOVABLE stuff. However, at the time the
> > patch was proposed, there was a feeling that it might help jumbo frame
> > allocation on e1000's and maybe if fsblock optimistically uses
> > contiguous pages it would have an application. I would like to see it go
> > through to see does it help e1000 at least.
> 
> I'm not seeing how this will help e1000 (and other jumbo drivers). They
> typically allocate using GFP_ATOMIC, so in order to satisfy those you'd
> need to either have a higher order watermark or do atomic defrag of the
> free space.
> 

It does help somewhat indirectly and in an unsatisfactory manner. When the
higher watermarks are breached, the atomic allocation will still succeeed
but kswapd will be poked to reclaim at a given order. This is similar to
the problems SLUB hits when it uses high-orders frequently.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
