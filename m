Date: Fri, 14 Jan 2005 20:16:44 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] Avoiding fragmentation through different allocator V2
Message-ID: <20050114221644.GE3336@logos.cnet>
References: <Pine.LNX.4.58.0501131552400.31154@skynet> <20050114213619.GA3336@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050114213619.GA3336@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> You want to do 
> 		free_pages -= (z->free_area_lists[0][o].nr_free + z->free_area_lists[2][o].nr_free +
										   ^^^^ = 1
>                 		z->free_area_lists[2][o].nr_free) << o;

I meant the sum of the free lists. You'd better use the defines instead of course :)

> So not to interfere with the "min" decay (and remove the allocation type loop). 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
