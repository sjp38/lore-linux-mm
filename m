Date: Tue, 18 Oct 2005 09:43:39 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 1/2] Page migration via Swap V2: Page Eviction
In-Reply-To: <aec7e5c30510180134of0b129au3f1a1b61cf822b53@mail.gmail.com>
Message-ID: <Pine.LNX.4.62.0510180938430.7911@schroedinger.engr.sgi.com>
References: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
  <20051018004937.3191.42181.sendpatchset@schroedinger.engr.sgi.com>
 <aec7e5c30510180134of0b129au3f1a1b61cf822b53@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, 18 Oct 2005, Magnus Damm wrote:

> This function is very similar to isolate_lru_pages(), except that it
> operates on one page at a time and drains the lru if needed. Maybe
> isolate_lru_pages() could use this function (inline) if the spinlock
> and drain code was moved out?

isolate_lru_pages operates on batches of pages from the same zone and is 
very efficient by only taking a single lock. It also does not drain other 
processors LRUs.

> I'm also curios why you choose to always use list_del() and move back
> the page if freed elsewhere, instead of using
> del_page_from_[in]active_list(). I guess because of performance. But
> if that is the case, wouldn't it make sense to do as little as
> possible with the spinlock held, ie move list_add() (when rc == 1) out
> of the function?

I tried to follow isolate_lru_pages as closely as possible. list_add() is 
a simple operation and so I left it inside following some earlier code 
from the hotplug project.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
