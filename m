Message-ID: <413014AF.3050104@yahoo.com.au>
Date: Sat, 28 Aug 2004 15:14:23 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] Avoid unecessary zone spinlocking on refill_inactive_zone()
References: <20040828005550.GC4482@logos.cnet>
In-Reply-To: <20040828005550.GC4482@logos.cnet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:

> On a side note, the current accounting of inactive/active pages is broken 
> in refill_inactive_zone (due to pages being freed in __release_pages). 
> I plan to fix that tomorrow - should be easy as returning the number of pages
> freed in __release_pages and take that into account.
> 

Hi,
I don't think this is a problem: release_pages should do del_page_from_lru,
which would take care of accounting, wouldn't it?

Maybe I'm not looking in the right place.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
