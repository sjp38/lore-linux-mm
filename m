Date: Tue, 28 Aug 2007 01:51:53 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: RFC:  Noreclaim with "Keep Mlocked Pages off the LRU"
Message-ID: <20070827235153.GA14109@wotan.suse.de>
References: <20070823041137.GH18788@wotan.suse.de> <1187988218.5869.64.camel@localhost> <20070827013525.GA23894@wotan.suse.de> <1188225247.5952.41.camel@localhost> <20070827154426.GA27868@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070827154426.GA27868@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 27, 2007 at 04:44:26PM +0100, Christoph Hellwig wrote:
> On Mon, Aug 27, 2007 at 10:34:07AM -0400, Lee Schermerhorn wrote:
> > Well, keeping the mlock count in the lru pointer more or less defeats
> > the purpose of this exercise for me--that is, a unified mechanism for
> > tracking "non-reclaimable" pages.  I wanted to maintain the ability to
> > use the zone lru_lock and isolate_lru_page() to arbitrate access to
> > pages for migration, etc. w/o having to temporarily put the pages back
> > on the lru during migration.   
> 
> A few years ago I tried to implement a mlocked counter in the page
> aswell, and my approach was to create a union to reuse the space occupied
> by the lru list pointers for this.  I never really got it stable enough
> because people tripped over the lru list randomly far too often.

My original mlock patches that Lee is talking about did use your
method. I _believe_ it is basically bug free and worked nicely.

These days we're a bit more consistent and have fewer races with
LRU handling, which is perhaps what made it doable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
