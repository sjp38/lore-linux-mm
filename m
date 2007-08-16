Date: Thu, 16 Aug 2007 13:24:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/9] Reclaim during GFP_ATOMIC allocs
In-Reply-To: <20070816024949.GA16372@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0708161322550.17777@schroedinger.engr.sgi.com>
References: <20070814153021.446917377@sgi.com> <20070816024949.GA16372@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Aug 2007, Nick Piggin wrote:

> Just to clarify... I can see how recursive reclaim can prevent memory getting
> eaten up by reclaim (which thus causes allocations from interrupt handlers to
> fail)...
> 
> But this patchset I don't see will do anything to prevent reclaim deadlocks,
> right? (because if there is reclaimable memory at hand, then kswapd should
> eventually reclaim it).

What deadlocks are you thinking about? Reclaim can be run concurrently 
right now.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
