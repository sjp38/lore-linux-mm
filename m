Date: Tue, 28 Aug 2007 13:29:36 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: RFC:  Noreclaim with "Keep Mlocked Pages off the LRU"
Message-ID: <20070828122936.GB16906@infradead.org>
References: <20070823041137.GH18788@wotan.suse.de> <1187988218.5869.64.camel@localhost> <20070827013525.GA23894@wotan.suse.de> <1188225247.5952.41.camel@localhost> <20070827154426.GA27868@infradead.org> <20070827235153.GA14109@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070827235153.GA14109@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 28, 2007 at 01:51:53AM +0200, Nick Piggin wrote:
> > A few years ago I tried to implement a mlocked counter in the page
> > aswell, and my approach was to create a union to reuse the space occupied
> > by the lru list pointers for this.  I never really got it stable enough
> > because people tripped over the lru list randomly far too often.
> 
> My original mlock patches that Lee is talking about did use your
> method. I _believe_ it is basically bug free and worked nicely.
> 
> These days we're a bit more consistent and have fewer races with
> LRU handling, which is perhaps what made it doable.

If this works that'd be wonderful.  It also means xfs could switch back
to using the block device mapping for it's buffer cache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
