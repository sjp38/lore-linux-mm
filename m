Date: Fri, 1 Oct 2004 13:11:47 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
Message-Id: <20041001131147.3780722b.akpm@osdl.org>
In-Reply-To: <20041001182221.GA3191@logos.cnet>
References: <20041001182221.GA3191@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, piggin@cyberone.com.au, arjanv@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
>
> The following patch implements a "coalesce_memory()" function 
> which takes "zone" and "order" as a parameter. 
> 
> It tries to move enough physically nearby pages to form a free area
> of "order" size.
> 
> It does that by checking whether the page can be moved, allocating a new page, 
> unmapping the pte's to it, copying data to new page, remapping the ptes, 
> and reinserting the page on the radix/LRU.

Presumably this duplicates some of the memory hot-remove patches.

Apparently Dave Hansen has working and sane-looking hot remove code
which is in a close-to-submittable state.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
