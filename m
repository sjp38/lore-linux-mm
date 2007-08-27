Date: Mon, 27 Aug 2007 16:44:26 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: RFC:  Noreclaim with "Keep Mlocked Pages off the LRU"
Message-ID: <20070827154426.GA27868@infradead.org>
References: <20070823041137.GH18788@wotan.suse.de> <1187988218.5869.64.camel@localhost> <20070827013525.GA23894@wotan.suse.de> <1188225247.5952.41.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1188225247.5952.41.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 27, 2007 at 10:34:07AM -0400, Lee Schermerhorn wrote:
> Well, keeping the mlock count in the lru pointer more or less defeats
> the purpose of this exercise for me--that is, a unified mechanism for
> tracking "non-reclaimable" pages.  I wanted to maintain the ability to
> use the zone lru_lock and isolate_lru_page() to arbitrate access to
> pages for migration, etc. w/o having to temporarily put the pages back
> on the lru during migration.   

A few years ago I tried to implement a mlocked counter in the page
aswell, and my approach was to create a union to reuse the space occupied
by the lru list pointers for this.  I never really got it stable enough
because people tripped over the lru list randomly far too often.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
