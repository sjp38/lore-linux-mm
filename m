Date: Wed, 23 May 2007 18:35:48 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch 2/8] mm: merge populate and nopage into fault (fixes nonlinear)
Message-ID: <20070523083548.GX86004887@sgi.com>
References: <200705180737.l4I7b5aR010752@shell0.pdx.osdl.net> <alpine.LFD.0.98.0705180758450.3890@woody.linux-foundation.org> <20070522151220.GA9541@infradead.org> <alpine.LFD.0.98.0705221814220.3890@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.98.0705221814220.3890@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, akpm@linux-foundation.org, linux-mm@kvack.org, npiggin@suse.de, randy.dunlap@oracle.com, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, May 22, 2007 at 06:14:47PM -0700, Linus Torvalds wrote:
> 
> 
> On Tue, 22 May 2007, Christoph Hellwig wrote:
> >
> > On Fri, May 18, 2007 at 08:11:35AM -0700, Linus Torvalds wrote:
> > > 
> > > On Fri, 18 May 2007, akpm@linux-foundation.org wrote:
> > > > 
> > > > Nonlinear mappings are (AFAIKS) simply a virtual memory concept that encodes
> > > > the virtual address -> file offset differently from linear mappings.
> > > 
> > > I'm not going to merge this one.
> > 
> > So if ->fault doesn't get in can be please at least get block_page_mkwrite
> > in to fix the shared mmap write allocation and unwritten extent + mmap
> > issues?  It can then later be converted to whatever version of ->fault
> > goes in.
> 
> After a -rc2? 
> 
> I don't think so. Unless it's some new regression.

It's an old bug that ppl have been asking to be fixed for
a long time. I fixed it a couple of months back, only to have
inclusion put on hold because a) there was nothing XFS sepcific
and it should be made generic, and b) the generic implementation
conflicted with the impending ->fault work and hence was held back.

If neither of these things occurred, the XFS specific fix would have
been released in 2.6.21. As it stands, the only user of
block_page_mkwrite() would be XFS for 2.6.22 and the patches have
been sitting in my QA tree for a couple of months now just waiting
to go somewhere....

What's the plan for ->fault moving forward?

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
