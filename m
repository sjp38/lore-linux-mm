Date: Tue, 2 May 2000 08:19:18 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [PATCH] pre7-1 semicolon & nicely readableB
In-Reply-To: <Pine.LNX.4.21.0005021152330.10854-100000@ferret.lmh.ox.ac.uk>
Message-ID: <Pine.LNX.4.21.0005020809580.10610-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Evans <chris@ferret.lmh.ox.ac.uk>
Cc: Roel van der Goot <roel@cs.ualberta.ca>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Tue, 2 May 2000, Chris Evans wrote:
> On Mon, 1 May 2000, Rik van Riel wrote:
> 
> > I want to inform you that you're wrong. The only difference is
> > in readability.
> 
> [..]
> 
> > In fact, the <10 test is only there to prevent infinite looping
> > for when a process with 0 swap_cnt "slips through" the tests above.
> 
> If such a value should never "slip through", then, for
> readability, you want an assert (e.g. BUG() ).

It's ok for them to slip through, it's just not ok for the kernel
to go into an infinite loop here...

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
