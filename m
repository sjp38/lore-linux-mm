Date: Fri, 20 Feb 2004 06:01:16 -0800
From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-ID: <20040220140116.GD1269@us.ibm.com>
Reply-To: paulmck@us.ibm.com
References: <20040216190927.GA2969@us.ibm.com> <200402200007.25832.phillips@arcor.de> <20040220120255.GA1269@us.ibm.com> <200402201535.47848.phillips@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200402201535.47848.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 20, 2004 at 03:37:26PM -0500, Daniel Phillips wrote:
> Hi Paul,
> 
> > I cannot think of any reasonable alternative to passing the parameter
> > down either, as it certainly does not be reasonable to duplicate the
> > code...
> 
> Yes, it's simply the (small) price that has to be paid in order to be able to 
> boast about our accurate semantics.

;-)

> > How about something like "private_too" instead of "zap"?
> 
> How about just "all", which is what we mean.

Fair enough, certainly keeps a few more lines of code within 80 columns.

> > > -void zap_page_range(struct vm_area_struct *vma,
> > > -			unsigned long address, unsigned long size)
> > > +void invalidate_page_range(struct vm_area_struct *vma,
> >
> > Would it be useful for this to be inline?  (Wouldn't seem so,
> > zapping mappings has enough overhead that an extra level of
> > function call should be deep down in the noise...)
> 
> Yes, it doesn't seem worth it just to save a stack frame.
> 
> Actually, I erred there in that invalidate_mmap_range should not export the 
> flag, because it never makes sense to pass in non-zero from a DFS.

Doesn't vmtruncate() want to pass non-zero "all" in to
invalidate_mmap_range() in order to maintain compatibility with existing
Linux semantics?

> > Doesn't the new argument need to be passed down through
> > invalidate_mmap_range_list()?
> 
> It does, thanks for the catch.  Please bear with me for a moment while I 
> reroll this, then hopefully we can move on to the more interesting discussion 
> of whether it's worth it.  (Yes it is :)

;-)

						Thanx, Paul
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
