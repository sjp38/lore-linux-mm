Date: Sun, 4 Mar 2001 21:59:41 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Shared mmaps
In-Reply-To: <20010304211053.F1865@parcelfarce.linux.theplanet.co.uk>
Message-ID: <Pine.LNX.4.21.0103042158430.5591-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 4 Mar 2001, Matthew Wilcox wrote:

> Sparc & IA64 use a flag in the task_struct to indicate that they're trying
> to allocate an mmap which is shared.  That's really ugly, let's just pass
> the flags in to the get_mapped_area function instead.  I had to invent a
> 
> Comments?

Looks a lot cleaner than the task->flags hack that sparc is
using at the moment...

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
