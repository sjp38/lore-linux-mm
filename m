Date: Thu, 31 Jul 2003 18:06:05 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Understanding page faults code in mm/memory.c
In-Reply-To: <Pine.GSO.4.51.0307311209220.8932@aria.ncl.cs.columbia.edu>
Message-ID: <Pine.LNX.4.53.0307311805200.22434@skynet>
References: <20030731111502.GA1591@eugeneteo.net> <Pine.LNX.4.53.0307311242370.10913@skynet>
 <Pine.GSO.4.51.0307311209220.8932@aria.ncl.cs.columbia.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Raghu R. Arur" <rra2002@aria.ncl.cs.columbia.edu>
Cc: Eugene Teo <eugene.teo@eugeneteo.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jul 2003, Raghu R. Arur wrote:

>    But when you put a page on to the swap cache will not the rss of the
> address spage  decrease. if not then when will the rss value of the
> address space change.
>

vmscan.c:try_to_swap_out() will decrement the rss before adding it to the
swap cache with add_to_swap_cache()

-- 
Mel Gorman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
