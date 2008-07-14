Date: Mon, 14 Jul 2008 14:50:18 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH] - GRU virtual -> physical translation
Message-ID: <20080714195018.GD8534@sgi.com>
References: <20080709191439.GA7307@sgi.com> <20080711121736.18687570.akpm@linux-foundation.org> <20080714145255.GA23173@sgi.com> <20080714092451.2c81a472.akpm@linux-foundation.org> <20080714163107.GA936@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080714163107.GA936@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 14, 2008 at 11:31:07AM -0500, Jack Steiner wrote:
> On Mon, Jul 14, 2008 at 09:24:51AM -0700, Andrew Morton wrote:
> > On Mon, 14 Jul 2008 09:52:55 -0500 Jack Steiner <steiner@sgi.com> wrote:
> > 
> > > On Fri, Jul 11, 2008 at 12:17:36PM -0700, Andrew Morton wrote:
> > > > On Wed, 9 Jul 2008 14:14:39 -0500 Jack Steiner <steiner@sgi.com> wrote:
> > > > 
> > > > > Open code the equivalent to follow_page(). This eliminates the
> > > > > requirement for an EXPORT of follow_page().
> > > > 
> > > > I'd prefer to export follow_page() - copying-n-pasting just to avoid
> > > > exporting the darn thing is silly.
> > > 
> > > If follow_page() can be EXPORTed, I think that may make the most sense for
> > > now.
> > 
> > What was Christoph's reason for objecting to the export?
> 
> No clue. Just a NACK.
> 
> Christoph???

Maybe I missed part of the discussion, but I thought follow_page() would
not work because you need this to function in the interrupt context and
locks would then need to be made irqsave/irqrestore.

This, of course does not in any way answer the question about why
follow_page() can not be exported.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
