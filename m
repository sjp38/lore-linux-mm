Date: Thu, 11 Jan 2001 10:49:10 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: pre2 swap_out() changes
In-Reply-To: <Pine.LNX.4.21.0101110825460.9296-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10101111046020.2388-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 11 Jan 2001, Marcelo Tosatti wrote:
> 
> Since no process calls swap_out() directly, I dont see any sense on the
> comment above. 

Stage #2 is to allow them to call refill_inactive() in the low-memory case
(right now processes can only do "page_launder()" in alloc_pages(), and I
think that is wrong - it means that the only one scanning page tables etc
is kswapd)

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
