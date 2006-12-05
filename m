Date: Tue, 5 Dec 2006 21:47:21 +0000
Subject: Re: [PATCH] Add __GFP_MOVABLE for callers to flag allocations that may be migrated
Message-ID: <20061205214721.GE20614@skynet.ie>
References: <20061204113051.4e90b249.akpm@osdl.org> <Pine.LNX.4.64.0612041133020.32337@schroedinger.engr.sgi.com> <20061204120611.4306024e.akpm@osdl.org> <Pine.LNX.4.64.0612041211390.32337@schroedinger.engr.sgi.com> <20061204131959.bdeeee41.akpm@osdl.org> <Pine.LNX.4.64.0612041337520.851@schroedinger.engr.sgi.com> <20061204142259.3cdda664.akpm@osdl.org> <Pine.LNX.4.64.0612050754560.11213@schroedinger.engr.sgi.com> <20061205112541.2a4b7414.akpm@osdl.org> <Pine.LNX.4.64.0612051159510.18687@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0612051159510.18687@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On (05/12/06 12:01), Christoph Lameter didst pronounce:
> On Tue, 5 Dec 2006, Andrew Morton wrote:
> 
> > > We always run reclaim against the whole zone not against parts. Why 
> > > would we start running reclaim against a portion of a zone?
> > 
> > Oh for gawd's sake.
> 
> Yes indeed. Another failure to answer a simple question.
>  

There are times you want to reclaim just part of a zone - specifically
satisfying a high-order allocations. See sitations 1 and 2 from elsewhere
in this thread. On a similar vein, there will be times when you want to
migrate a PFN range for similar reasons.

> > If you want to allocate a page from within the first 1/4 of a zone, and if
> > all those pages are in use for something else then you'll need to run
> > reclaim against the first 1/4 of that zone.  Or fail the allocation.  Or
> > run reclaim against the entire zone.  The second two options are
> > self-evidently dumb.
> 
> Why would one want to allocate from the 1/4th of a zone? (Are we still 
> discussing Mel's antifrag scheme or what is this about?)
> 

Because you wanted contiguous blocks of pages.  This is related to anti-frag
because with anti-frag, reclaiming memory or migration memory will free up
contiguous blocks. Without it, you're probably wasting your time.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
