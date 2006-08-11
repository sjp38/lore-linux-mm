Message-ID: <44DBED4C.6040604@redhat.com>
Date: Thu, 10 Aug 2006 22:37:00 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
References: <20060808193325.1396.58813.sendpatchset@lappy> <20060808193345.1396.16773.sendpatchset@lappy> <20060808211731.GR14627@postel.suug.ch>
In-Reply-To: <20060808211731.GR14627@postel.suug.ch>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thomas Graf <tgraf@suug.ch>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

Thomas Graf wrote:

> skb->dev is not guaranteed to still point to the "allocating" device
> once the skb is freed again so reserve/unreserve isn't symmetric.
> You'd need skb->alloc_dev or something.

There's another consequence of this property of the network
stack.

Every network interface must be able to fall back to these
MEMALLOC allocations, because the memory critical socket
could be on another network interface.  Hence, we cannot
know which network interfaces should (not) be marked MEMALLOC.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
