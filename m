Message-ID: <48EFEB9D.3080100@redhat.com>
Date: Fri, 10 Oct 2008 19:56:13 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-lru.patch
References: <200810081655.06698.nickpiggin@yahoo.com.au>	<20081008185401.D958.KOSAKI.MOTOHIRO@jp.fujitsu.com>	<20081010151701.e9e50bdb.akpm@linux-foundation.org> <20081010152540.79ed64cb.akpm@linux-foundation.org>
In-Reply-To: <20081010152540.79ed64cb.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> Which means that after vmscan-split-lru-lists-into-anon-file-sets.patch,
> shrink_active_list() simply does
> 
> 	while (!list_empty(&l_hold)) {
> 		cond_resched();
> 		page = lru_to_page(&l_hold);
> 		list_add(&page->lru, &l_inactive);
> 	}
> 
> yes?
> 
> We might even be able to list_splice those pages..

Not quite.  We still need to clear the referenced bits.

In order to better balance the pressure between the file
and anon lists, we may also want to count the number of
referenced mapped file pages.

That would be roughly a 3-line change, which I could
either send against a recent mmotm (is the one on your
site recent enough?) or directly to Linus if you are
sending the split LRU code upstream.

Just let me know which you prefer.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
