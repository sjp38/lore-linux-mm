Date: Wed, 1 Oct 2003 23:53:30 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: page flags
In-Reply-To: <Pine.LNX.4.44.0310011346580.24073-100000@delhi.clic.cs.columbia.edu>
Message-ID: <Pine.LNX.4.44.0310012347200.7095-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Raghu R. Arur" <rra2002@cs.columbia.edu>
Cc: kenelnewbies@linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 1 Oct 2003, Raghu R. Arur wrote:
>  
>  In 2.4.19 linux, I see that 9th bit of page->flags is not used for any 
> flag. Is there a particular reason for doing so?

Up to 2.4.9 there was #define PG_swap_cache 9, but we deleted that as
unnecessary in 2.4.10, changing the PageSwapCache macro.  It happens
to have stayed free ever since in 2.4, but I don't believe there's a
curse on that bit.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
