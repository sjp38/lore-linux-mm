Date: Sat, 20 Jan 2001 17:58:48 +1100 (EST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] 2-pointer PTE chaining idea
In-Reply-To: <Pine.LNX.4.10.10101182307340.9418-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.31.0101201754110.1071-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "David S. Miller" <davem@redhat.com>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Matthew Dillon <dillon@apollo.backplane.com>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Jan 2001, Linus Torvalds wrote:

> The only sane way I can think of to do the "implied pointer" is
> to do an order-2 allocation when you allocate a page directory:

While this idea seemed the best one at first glance, after
thinking about it a bit more I think your idea may actually
have _higher_ overhead than my idea of keeping the pte chain
structures external.

The reason for this is three-fold. Firstly, a lot of the page
tables will only be "occupied" for a small percentage. I don't
know the numbers, but I wouldn't be surprised if the page table
"occupation" is well under 50% for programs that are fully
resident ... probably less for programs which are partly swapped
out.

Secondly, if we do "dynamic" pte chaining, we can free up or
re-use the pte_chain structure as soon as we unmap a page, so
swapping out a page will free up the pte chain structure, which
is a big improvement compared to the unswappable page tables.

Thirdly, this idea doesn't suffer from memory fragmentation and
also works efficiently on architectures where the page table size
isn't equal to the page size.

Ideas ?

(btw, if I'm unlucky I won't be online again until the 26th)

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
