Date: Thu, 29 Nov 2007 11:23:55 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 01/19] Define functions for page cache handling
In-Reply-To: <396325866.00706@ustc.edu.cn>
Message-ID: <Pine.LNX.4.64.0711291123350.25803@schroedinger.engr.sgi.com>
References: <20071129011052.866354847@sgi.com> <20071129011144.503535436@sgi.com>
 <396325866.00706@ustc.edu.cn>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fengguang Wu <wfg@mail.ustc.edu.cn>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 Nov 2007, Fengguang Wu wrote:

> On Wed, Nov 28, 2007 at 05:10:53PM -0800, Christoph Lameter wrote:
> > +static inline loff_t page_cache_mask(struct address_space *a)
> > +{
> > +	return (loff_t)PAGE_MASK;
> > +}
> 
> A tiny question: Why choose loff_t instead of 'unsigned long'?
> 
> It's not obvious because page_cache_mask() is not referenced in this
> patchset at all ;-)

Ok Then lets drop page_cache_mask completely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
