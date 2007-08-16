Date: Thu, 16 Aug 2007 04:49:49 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC 0/9] Reclaim during GFP_ATOMIC allocs
Message-ID: <20070816024949.GA16372@wotan.suse.de>
References: <20070814153021.446917377@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070814153021.446917377@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 14, 2007 at 08:30:21AM -0700, Christoph Lameter wrote:
> This is the extended version of the reclaim patchset. It enables reclaim from
> clean file backed pages during GFP_ATOMIC allocs. A bit invasive since
> may locks must now be taken with saving flags. But it works.
> 
> Tested by repeatedly allocating 12MB of memory from the timer interrupt.
> 
> -- 

Just to clarify... I can see how recursive reclaim can prevent memory getting
eaten up by reclaim (which thus causes allocations from interrupt handlers to
fail)...

But this patchset I don't see will do anything to prevent reclaim deadlocks,
right? (because if there is reclaimable memory at hand, then kswapd should
eventually reclaim it).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
