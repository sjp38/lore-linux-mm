Date: Tue, 5 Aug 2003 16:54:03 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: anonymous buffer pages
In-Reply-To: <Pine.GSO.4.51.0308051141270.10476@aria.ncl.cs.columbia.edu>
Message-ID: <Pine.LNX.4.53.0308051647370.10972@skynet>
References: <Pine.GSO.4.51.0308051141270.10476@aria.ncl.cs.columbia.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Raghu R. Arur" <rra2002@aria.ncl.cs.columbia.edu>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Aug 2003, Raghu R. Arur wrote:

>   when are anonymous buffer pages created and how are they removed from
> the system  in linux 2.4.19 ?

Buried in
http://www.skynet.ie/~mel/projects/vm/guide/html/understand/node70.html#SECTION001533000000000000000
is

"An anonymous page may have associated buffers if it is backed by a swap
file."

The reason being that the page will need to be written out in block-sized
chunks. Once written out, the page->buffers will be null again and it'll
be cleared out the normal way via the swap cache when all processes have
unmapped the page

-- 
Mel Gorman
http://www.csn.ul.ie/~mel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
