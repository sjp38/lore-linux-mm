Date: Thu, 22 Jun 2000 17:07:16 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] RSS guarantees and limits
In-Reply-To: <20000622220049.G28360@pcep-jamie.cern.ch>
Message-ID: <Pine.LNX.4.21.0006221704240.1170-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: frankeh@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jun 2000, Jamie Lokier wrote:
> Rik van Riel wrote:
> > > Be careful with refault rate.  If a process is unable to
> > > progress because of memory pressure, it will have a low refault
> > > rate even though it's _trying_ to fault in lots of pages at high
> > > speed.
> > 
> > We probably want to use fault rate and memory size too in
> > order to promote fairness.
> 
> The number of global memory events between the process getting one page
> and requesting the next may indicate of how much page activity the
> process is trying to do.  (Relative to other memory users).

Oh, there are lots of possible things we could look at here.
The main thing to keep in mind is to always look at _ratios_
and not at pure magic numbers ... 

> > All of this may sound complicated, but as long as we make
> > sure that the feedback cycles are short (and negative ;))
> > it should all work out...
> 
> Keeping them negative is tricky :-)

Hehe, tell me all about it ;)

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
