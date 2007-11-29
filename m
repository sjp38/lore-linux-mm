Date: Wed, 28 Nov 2007 19:21:42 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 01/19] Define functions for page cache handling
In-Reply-To: <20071129030645.GE115527101@sgi.com>
Message-ID: <Pine.LNX.4.64.0711281921050.20367@schroedinger.engr.sgi.com>
References: <20071129011052.866354847@sgi.com> <20071129011144.503535436@sgi.com>
 <20071129030645.GE115527101@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 Nov 2007, David Chinner wrote:

> On Wed, Nov 28, 2007 at 05:10:53PM -0800, Christoph Lameter wrote:
> > +/*
> > + * Index of the page starting on or after the given position.
> > + */
> > +static inline pgoff_t page_cache_next(struct address_space *a,
> > +		loff_t pos)
> > +{
> > +	return page_cache_index(a, pos + page_cache_size(a) - 1);
> 
> 	return page_cache_index(a, pos + page_cache_mask(a));

Na that is confusing. We really want to go to one byte before the end of 
the page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
