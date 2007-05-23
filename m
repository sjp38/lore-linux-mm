Date: Wed, 23 May 2007 11:35:40 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/8] mm: merge populate and nopage into fault (fixes nonlinear)
Message-ID: <20070523093540.GA22453@wotan.suse.de>
References: <200705180737.l4I7b5aR010752@shell0.pdx.osdl.net> <alpine.LFD.0.98.0705180758450.3890@woody.linux-foundation.org> <20070522151220.GA9541@infradead.org> <alpine.LFD.0.98.0705221814220.3890@woody.linux-foundation.org> <20070523083548.GX86004887@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070523083548.GX86004887@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, akpm@linux-foundation.org, linux-mm@kvack.org, randy.dunlap@oracle.com
List-ID: <linux-mm.kvack.org>

On Wed, May 23, 2007 at 06:35:48PM +1000, David Chinner wrote:
> On Tue, May 22, 2007 at 06:14:47PM -0700, Linus Torvalds wrote:
> > 
> > 
> > On Tue, 22 May 2007, Christoph Hellwig wrote:
> > >
> > > On Fri, May 18, 2007 at 08:11:35AM -0700, Linus Torvalds wrote:
> > > > 
> > > > On Fri, 18 May 2007, akpm@linux-foundation.org wrote:
> > > > > 
> > > > > Nonlinear mappings are (AFAIKS) simply a virtual memory concept that encodes
> > > > > the virtual address -> file offset differently from linear mappings.
> > > > 
> > > > I'm not going to merge this one.
> > > 
> > > So if ->fault doesn't get in can be please at least get block_page_mkwrite
> > > in to fix the shared mmap write allocation and unwritten extent + mmap
> > > issues?  It can then later be converted to whatever version of ->fault
> > > goes in.
> > 
> > After a -rc2? 
> > 
> > I don't think so. Unless it's some new regression.
> 
> It's an old bug that ppl have been asking to be fixed for
> a long time. I fixed it a couple of months back, only to have
> inclusion put on hold because a) there was nothing XFS sepcific
> and it should be made generic, and b) the generic implementation
> conflicted with the impending ->fault work and hence was held back.
> 
> If neither of these things occurred, the XFS specific fix would have
> been released in 2.6.21. As it stands, the only user of
> block_page_mkwrite() would be XFS for 2.6.22 and the patches have
> been sitting in my QA tree for a couple of months now just waiting
> to go somewhere....
> 
> What's the plan for ->fault moving forward?

I don't see why it couldn't go into 2.6.23 (at the start of the merge
window, next time, would be preferable).

But don't let the ->fault work hold you up. You should even be able to
get it into -mm, because I haven't got the ->page_mkwrite conversion in
there yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
