Date: Thu, 22 Jun 2000 16:52:29 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] RSS guarantees and limits
In-Reply-To: <20000622214819.C28360@pcep-jamie.cern.ch>
Message-ID: <Pine.LNX.4.21.0006221651230.1170-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: frankeh@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jun 2000, Jamie Lokier wrote:
> frankeh@us.ibm.com wrote:
> > Now I understand this much better. The RSS guarantee is a function of the
> > refault-rate <clever>.
> > This in principle implements a decay of the limit based on usage.... I like
> > that approach.
> 
> Be careful with refault rate.  If a process is unable to
> progress because of memory pressure, it will have a low refault
> rate even though it's _trying_ to fault in lots of pages at high
> speed.

*nod*

We probably want to use fault rate and memory size too in
order to promote fairness.

All of this may sound complicated, but as long as we make
sure that the feedback cycles are short (and negative ;))
it should all work out...

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
