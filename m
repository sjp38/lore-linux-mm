Date: Thu, 8 Jun 2000 12:35:41 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH,incomplete] shm integration into shrink_mmap
In-Reply-To: <qwwg0qob4ef.fsf_-_@sap.com>
Message-ID: <Pine.LNX.4.21.0006081229554.22665-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.21.0006081229556.22665@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 8 Jun 2000, Christoph Rohland wrote:

> Here is my first proposal for changing shm to be integrated into
> shrink_mmap.
> 
> It gives you a function 'int shm_write_swap (struct page *page)'
> to write out a page to swap and replace the pte in the shm
> structures.

> What do you think?

This is a great start. We probably want to make the
shm_write_swap() function a function pointer in the
page->mapping struct so the shrink_mmap() code can
call the same function for every page, but other than
that this is the direction I'd like VM to go.

I've seen Juan Quintela is already looking into your
patch trying to write the missing part, so I guess
I'll continue on the active/inactive/scavenge list
code and not look at your patch in detail today ;)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
