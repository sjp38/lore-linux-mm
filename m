Date: Tue, 25 Apr 2000 15:33:53 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: 2.3.x mem balancing
In-Reply-To: <3905DFCF.B8695E16@mandrakesoft.com>
Message-ID: <Pine.LNX.4.21.0004251531560.10408-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Apr 2000, Jeff Garzik wrote:
> Rik van Riel wrote:
> > Another thing which we probably want before 2.4 is scanning
> > big processes more agressively than small processes. I've
> > implemented most of what is needed for that and it seems to
> > have a good influence on performance because:
> > - small processes suffer less from the presence of memory hogs
> > - memory hogs have their pages aged more agressively, making it
> >   easier for them to do higher throughput from/to swap or disk
> 
> Since you do not mention a new sysctl here...

Yeah, I forgot to mention that. This is something which can
be made switchable by the admin very easily.

I'll add the sysctl switch (and remove some old redundant
ones) later, when the code has stabilised and we know what's
needed.

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
