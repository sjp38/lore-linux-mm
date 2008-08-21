Message-ID: <48AD692F.8030908@linux-foundation.org>
Date: Thu, 21 Aug 2008 08:10:07 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/2] Quicklist is slighly problematic.
References: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>	<48AC25E7.4090005@linux-foundation.org>	<20080821021332.GA23397@sgi.com> <20080820.200852.193706487.davem@davemloft.net>
In-Reply-To: <20080820.200852.193706487.davem@davemloft.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: holt@sgi.com, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

David Miller wrote:

> Using SLAB/SLUB for the page table bits with appropriate constructor
> and destructor bits ought to be able to approximate the gains
> from avoiding the initialization for cached objects.

Its a bit strange to use the small object allocator for page sized
allocations. Plus there is this tie in with the tlb flushing logic. So I think
this would be more clean if it would be moved into the asm-generic/tlb.h or so.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
