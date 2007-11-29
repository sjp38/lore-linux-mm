Date: Thu, 29 Nov 2007 00:29:12 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 00/19] Page cache: Replace PAGE_CACHE_xx with inline
 functions
Message-Id: <20071129002912.145b85a8.akpm@linux-foundation.org>
In-Reply-To: <20071129042039.GI119954183@sgi.com>
References: <20071129011052.866354847@sgi.com>
	<20071129042039.GI119954183@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 Nov 2007 15:20:39 +1100 David Chinner <dgc@sgi.com> wrote:

> On Wed, Nov 28, 2007 at 05:10:52PM -0800, Christoph Lameter wrote:
> > This patchset cleans up page cache handling by replacing
> > open coded shifts and adds with inline function calls.
> > 
> > The ultimate goal is to replace all uses of PAGE_CACHE_xxx in the
> > kernel through the use of these functions. All the functions take
> > a mapping parameter. The mapping parameter is required if we want
> > to support large block sizes in filesystems and block devices.
> > 
> > Patchset against 2.6.24-rc3-mm2.
> 
> Reviewed-by: Dave Chinner <dgc@sgi.com>

thanks ;)  I'll merge version 2..


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
