Date: Wed, 13 Aug 2003 15:07:31 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: removing clean mapped pages
In-Reply-To: <Pine.LNX.4.53.0308131143440.4904@skynet>
Message-ID: <Pine.LNX.4.53.0308131504470.12612@skynet>
References: <Pine.GSO.4.51.0308121522570.23513@aria.ncl.cs.columbia.edu>
 <Pine.GSO.4.51.0308121541290.23513@aria.ncl.cs.columbia.edu>
 <Pine.LNX.4.53.0308131143440.4904@skynet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Raghu R. Arur" <rra2002@aria.ncl.cs.columbia.edu>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Aug 2003, Mel Gorman wrote:

> Freed in try_to_swap_out() . There is no need to do anything with a clean
> page, so it is just dropped from the page tables and page_cache_release()
> is called. When the reference reaches 0, the page is reclaimed
>

Bah, this is wrong, shouldn't be let near e-mail in the morning. The
freeing of a file-mapped page is actually two-stage.

try_to_swap_out() will unmap the file-backed page from a process page
table. Once there are no processes mapping the page, the only user in
page->count will be the page cache. It stays in the page cache until it is
reclaimed later by shrink_cache().

-- 
Mel Gorman
http://www.csn.ul.ie/~mel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
