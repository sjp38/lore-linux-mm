Subject: Re: the new VMt
Date: Mon, 25 Sep 2000 17:55:58 +0100 (BST)
In-Reply-To: <Pine.LNX.4.21.0009251314350.14614-100000@duckman.distro.conectiva> from "Rik van Riel" at Sep 25, 2000 01:16:29 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E13dbXt-0005HQ-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > kmalloc 16K				kmalloc 32K
> > block					block
> > 
> 2) set PF_MEMALLOC on the task you're killing for OOM,
>    that way this task will either get the memory or
>    fail (note that PF_MEMALLOC tasks don't wait)

Nobody is out of memory at this point. Everyone is in kernel space blocking
for someone else. There is also no further allocation after this deadlock 
point to cause a kill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
