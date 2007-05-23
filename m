Date: Wed, 23 May 2007 04:57:47 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/8] mm: merge populate and nopage into fault (fixes nonlinear)
Message-ID: <20070523025747.GB9255@wotan.suse.de>
References: <200705180737.l4I7b5aR010752@shell0.pdx.osdl.net> <alpine.LFD.0.98.0705180758450.3890@woody.linux-foundation.org> <20070522151220.GA9541@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070522151220.GA9541@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, akpm@linux-foundation.org, linux-mm@kvack.org, randy.dunlap@oracle.com, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, May 22, 2007 at 04:12:20PM +0100, Christoph Hellwig wrote:
> On Fri, May 18, 2007 at 08:11:35AM -0700, Linus Torvalds wrote:
> > 
> > On Fri, 18 May 2007, akpm@linux-foundation.org wrote:
> > > 
> > > Nonlinear mappings are (AFAIKS) simply a virtual memory concept that encodes
> > > the virtual address -> file offset differently from linear mappings.
> > 
> > I'm not going to merge this one.
> 
> So if ->fault doesn't get in can be please at least get block_page_mkwrite
> in to fix the shared mmap write allocation and unwritten extent + mmap
> issues?  It can then later be converted to whatever version of ->fault
> goes in.

David asked me about that a while back and yes, I have no problems with
page_mkwrite users going into the tree -- I'll just convert them myself
when the page_mkwrite -> fault conversion happens.

Actually it would be kind of useful to have some of them in the tree as
a reference when doing the conversion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
