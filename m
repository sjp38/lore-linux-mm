Date: Wed, 31 Mar 2004 17:51:13 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap
 complexity fix
Message-Id: <20040331175113.27fd1d0e.akpm@osdl.org>
In-Reply-To: <20040401012625.GV2143@dualathlon.random>
References: <20040331150718.GC2143@dualathlon.random>
	<Pine.LNX.4.44.0403311735560.27163-100000@localhost.localdomain>
	<20040331172851.GJ2143@dualathlon.random>
	<20040401004528.GU2143@dualathlon.random>
	<20040331172216.4df40fb3.akpm@osdl.org>
	<20040401012625.GV2143@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: hugh@veritas.com, vrajesh@umich.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@suse.de> wrote:
>
>  > Doing a __GFP_FS allocation while holding lock_page() is worrisome.  It's
>  > OK if that page is private, but how do we know that the caller didn't pass
>  > us some page which is on the LRU?
> 
>  it _has_ to be private if it's using rw_swap_page_sync. How can a page
>  be in a lru if we're going to execute add_to_page_cache on it? That
>  would be pretty broken in the first place.

An anonymous user page meets these requirements.  A did say "anal", but
rw_swap_page_sync() is a general-purpose library function and we shouldn't
be making assumptions about the type of page which the caller happens to be
feeding us.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
