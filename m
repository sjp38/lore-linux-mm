Date: Mon, 1 Mar 2004 15:33:26 -0500 (EST)
From: "Raghu R. Arur" <rra2002@cs.columbia.edu>
Subject: Re: writepage  
In-Reply-To: <Pine.LNX.4.58-035.0403011136250.2281@unix43.andrew.cmu.edu>
Message-ID: <Pine.LNX.4.44.0403011531260.32137-100000@delhi.clic.cs.columbia.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anand Eswaran <aeswaran@andrew.cmu.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 The page is added to the swap cache by add_to_swap_cache and not by 
writepage.

 writepage() (swap_writepage() in this case) prepares the page to write to 
the swap disk by creating buffers and submits the page to the disk. So 
page->buffers will be NON_NULL.

Raghu.

On Mon, 1 Mar 2004, Anand Eswaran wrote:

> Hi :
> 
>   I have quick question reg Linux 2.4.18, Ive tried to understand the code
> but am pretty confused:
> 
>   In the typical malloc execution-path,  the page is added to swap and it's
> pte_chain is unmapped  after which the writepage() is executed.  However I
> notice that *after* the writepage(), the page->buffers is NON_NULL.
> 
>   Is this supposed to happen? I thought the writepage function flushed the
> page to swap, so why are there residual buffers?
> 
> Thanks,
> ----
> Anand.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
