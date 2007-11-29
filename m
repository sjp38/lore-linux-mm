Message-ID: <396325866.00706@ustc.edu.cn>
Date: Thu, 29 Nov 2007 16:44:18 +0800
From: Fengguang Wu <wfg@mail.ustc.edu.cn>
Subject: Re: [patch 01/19] Define functions for page cache handling
References: <20071129011052.866354847@sgi.com> <20071129011144.503535436@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071129011144.503535436@sgi.com>
Message-Id: <E1Ixf0M-0004lI-0Z@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 28, 2007 at 05:10:53PM -0800, Christoph Lameter wrote:
> +static inline loff_t page_cache_mask(struct address_space *a)
> +{
> +	return (loff_t)PAGE_MASK;
> +}

A tiny question: Why choose loff_t instead of 'unsigned long'?

It's not obvious because page_cache_mask() is not referenced in this
patchset at all ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
