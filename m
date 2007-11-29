Date: Thu, 29 Nov 2007 15:20:39 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch 00/19] Page cache: Replace PAGE_CACHE_xx with inline functions
Message-ID: <20071129042039.GI119954183@sgi.com>
References: <20071129011052.866354847@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071129011052.866354847@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 28, 2007 at 05:10:52PM -0800, Christoph Lameter wrote:
> This patchset cleans up page cache handling by replacing
> open coded shifts and adds with inline function calls.
> 
> The ultimate goal is to replace all uses of PAGE_CACHE_xxx in the
> kernel through the use of these functions. All the functions take
> a mapping parameter. The mapping parameter is required if we want
> to support large block sizes in filesystems and block devices.
> 
> Patchset against 2.6.24-rc3-mm2.

Reviewed-by: Dave Chinner <dgc@sgi.com>

-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
