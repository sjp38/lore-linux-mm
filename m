Subject: Re: kernel hangs in 118th call to vmalloc
Date: Fri, 31 Aug 2001 21:38:29 +0100 (BST)
In-Reply-To: <3B8FDA36.5010206@interactivesi.com> from "Timur Tabi" at Aug 31, 2001 01:40:54 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E15cv3e-0003vf-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> What this routine does is call vmalloc() repeatedly for a number of 1MB 
> chunks until it fails or until it's allocated 128MB (CLEAR_BLOCK_COUNT 
> is equal to 128 in this case).  Then, it starts freeing them.
> 
> The side-effect of this routine is to page-out up to 128MB of RAM. 
> Unfortunately, on a 128MB machine, the 118th call to vmalloc() hangs the 
> system.  I was expecting it to return NULL instead.
> 
> Is this a bug in vmalloc()?  If so, is there a work-around that I can use?

vmalloc shouldnt be hanging the box, although in 2.4.2 the out of memory 
handling is not too reliable. You have to understand vmalloc isnt meant to 
be used that way and the kernel gets priority over user space for allocs so
is able to get itself to the point it killed off all user space.

Alan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
