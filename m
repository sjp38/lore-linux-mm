Date: Wed, 13 Aug 2003 11:46:34 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: removing clean mapped pages
In-Reply-To: <Pine.GSO.4.51.0308121541290.23513@aria.ncl.cs.columbia.edu>
Message-ID: <Pine.LNX.4.53.0308131143440.4904@skynet>
References: <Pine.GSO.4.51.0308121522570.23513@aria.ncl.cs.columbia.edu>
 <Pine.GSO.4.51.0308121541290.23513@aria.ncl.cs.columbia.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Raghu R. Arur" <rra2002@aria.ncl.cs.columbia.edu>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Aug 2003, Raghu R. Arur wrote:

>
>  I meant a clean mapped frame.
>

Freed in try_to_swap_out() . There is no need to do anything with a clean
page, so it is just dropped from the page tables and page_cache_release()
is called. When the reference reaches 0, the page is reclaimed

-- 
Mel Gorman
http://www.csn.ul.ie/~mel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
