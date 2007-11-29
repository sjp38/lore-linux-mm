Date: Thu, 29 Nov 2007 15:11:10 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch 05/19] Use page_cache_xxx in mm/rmap.c
Message-ID: <20071129041110.GG119954183@sgi.com>
References: <20071129011052.866354847@sgi.com> <20071129011145.414062339@sgi.com> <20071129031921.GS119954183@sgi.com> <Pine.LNX.4.64.0711281928220.20367@schroedinger.engr.sgi.com> <20071129035955.GZ119954183@sgi.com> <Pine.LNX.4.64.0711282009130.20688@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711282009130.20688@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Chinner <dgc@sgi.com>, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 28, 2007 at 08:09:39PM -0800, Christoph Lameter wrote:
> On Thu, 29 Nov 2007, David Chinner wrote:
> 
> > And the other two occurrences of this in the first patch?
> 
> Ahh... Ok they are also in rmap.c:
> 
> 
> 
> rmap: simplify page_referenced_file use of page cache inlines

Ok.

Cheers,

dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
