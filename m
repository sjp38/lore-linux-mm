Message-Id: <20071130173448.951783014@sgi.com>
Date: Fri, 30 Nov 2007 09:34:48 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 00/19] Page cache: Replace PAGE_CACHE_xx with inline functions V2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

This patchset cleans up page cache handling by replacing
open coded shifts and adds with inline function calls.

The ultimate goal is to replace all uses of PAGE_CACHE_xxx in the
kernel through the use of these functions. All the functions take
a mapping parameter. The mapping parameter is required if we want
to support large block sizes in filesystems and block devices.

Patchset against 2.6.24-rc3-mm2.

V1->V2:
- Review by Dave Chinner. Multiple improvements and fixes.
- Review by Fengguand Wu with more improvements.

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
