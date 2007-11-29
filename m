Date: Thu, 29 Nov 2007 15:19:50 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch 14/19] Use page_cache_xxx in ext2
Message-ID: <20071129041950.GH119954183@sgi.com>
References: <20071129011052.866354847@sgi.com> <20071129011147.567317218@sgi.com> <20071129034521.GV119954183@sgi.com> <Pine.LNX.4.64.0711281955010.20688@schroedinger.engr.sgi.com> <20071129040659.GC119954183@sgi.com> <Pine.LNX.4.64.0711282014590.20688@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711282014590.20688@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Chinner <dgc@sgi.com>, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 28, 2007 at 08:15:26PM -0800, Christoph Lameter wrote:
> On Thu, 29 Nov 2007, David Chinner wrote:
> 
> > I don't think that gives the same return value. The return value
> > is supposed to be clamped at a maximum of page_cache_size(mapping).
> 
> Ok. So this?

Looks good.

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
