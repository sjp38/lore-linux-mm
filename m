Date: Mon, 24 Apr 2000 08:01:18 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [patch] memory hog protection
In-Reply-To: <3903D353.D98969B7@mandrakesoft.com>
Message-ID: <Pine.LNX.4.21.0004240728070.3464-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Apr 2000, Jeff Garzik wrote:
> Rik van Riel wrote:
> > the patch below changes the mm->swap_cnt assignment to put
> > memory hogs at a disadvantage to programs with a smaller
> > RSS.
> [...]
> 
> There are many classes of problems where preserving
> interactivity at the expense of a resource hog is a bad not good
> idea.  Think of obscure situations like database servers for
> example :)

Firstly, if this code turns out to work, I'll make it sysctl
switchable.

Secondly, about the issue you bring up; suppose a database
server has 75% of memory and with this patch that would be
reduced to 70% of memory, that's only a very small difference
to the database server itself, but a BIG difference to the
dozen or so smaller processes in the system...

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
