Date: Thu, 5 Aug 2004 22:49:20 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] 3/4: writeout watermarks
Message-Id: <20040805224920.6755198d.akpm@osdl.org>
In-Reply-To: <41131862.5050000@yahoo.com.au>
References: <41130FB1.5020001@yahoo.com.au>
	<41130FD2.5070608@yahoo.com.au>
	<41131105.8040108@yahoo.com.au>
	<20040805222733.477b3017.akpm@osdl.org>
	<41131862.5050000@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>
> No, it is not that code I am worried about, you're actually doing
>  this too (disregarding the admin's wishes):
> 
>           dirty_ratio = vm_dirty_ratio;
>           if (dirty_ratio > unmapped_ratio / 2)
>                   dirty_ratio = unmapped_ratio / 2;
> 
>           if (dirty_ratio < 5)
>                   dirty_ratio = 5;
> 

hm, OK, that's some "try to avoid writeback off the LRU" stuff.

But you said "This ensures we should always attempt to start background
writeout before synchronous writeout.".  Does not the current code do that?

>  So if the admin wants a dirty_ratio of 40 and dirty_background_ratio of 10
>  then that's good, but I'm sure if they knew you're moving dirty_ratio to 10
>  here, they'd want something like 2 for the dirty_background_ratio.
> 
>  I contend that the ratio between these two values is more important than
>  their absolue values -- especially considering one gets twiddled here.

Maybe true, maybe false.  These things are demonstrable via testing, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
