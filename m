Date: Sat, 6 Sep 2003 22:17:37 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: swap_free() inside delete_from_swap_cache
In-Reply-To: <Pine.LNX.4.44.0309052200580.440-100000@tehran.clic.cs.columbia.edu>
Message-ID: <Pine.LNX.4.44.0309062217090.6028-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Raghu R. Arur" <rra2002@cs.columbia.edu>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 5 Sep 2003, Raghu R. Arur wrote:

>  Why is swap_free() called inside delete_from_swap_cache() in linux
> 2.4.19? I believe delete_from_swap_cache() is called when we write a
> page to the swap disk. swap_free() decreases the count of number of
> references to that page.

The swap cache itself has one of the references to the location
on swap. 

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
