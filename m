Date: Mon, 1 Sep 2003 22:13:59 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: flushing tlb in try_to_swap_out 
In-Reply-To: <Pine.GSO.4.51.0309011437050.15065@aria.ncl.cs.columbia.edu>
Message-ID: <Pine.LNX.4.44.0309012213320.25149-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Raghu R. Arur" <rra2002@aria.ncl.cs.columbia.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Sep 2003, Raghu R. Arur wrote:

>    I see that in try_to_swap_out() (linux 2.4.19), the page that is being
> unmapped from a process is flushed out. But try_to_swap_out() is executed
> in the context of kswapd. And also whenever a context switch takes place
> the whole tlb is flushed out. So is this flushing done just becuase linux
> uses lazy_tlb_flush during process context switch ?

Think about SMP systems, where the task that's being swapped
out could be running simultaneously with the pageout code, on
another CPU.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
