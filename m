Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by postfix.conectiva.com.br (Postfix) with SMTP id CF09216B13
	for <linux-mm@kvack.org>; Sat, 24 Mar 2001 16:27:39 -0300 (EST)
Date: Sat, 24 Mar 2001 14:31:35 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Reduce Linux memory requirements for an Embedded PC
In-Reply-To: <20010324175627.F26121@nightmaster.csn.tu-chemnitz.de>
Message-ID: <Pine.LNX.4.21.0103241427110.1863-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: Andi Kleen <ak@muc.de>, Petr Dusil <pdusil@razdva.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 24 Mar 2001, Ingo Oeser wrote:
> On Sat, Mar 24, 2001 at 01:21:29PM -0300, Rik van Riel wrote:
> > I'm willing to work on a CONFIG_TINY option for 2.5 which
> > does things like this (but I'll have to finish some VM
> > things first ;)).
> 
> Why not 2.4? It is only a configuration thing, right? People are
> using Linux more and more for embedded stuff. So waiting 2 years
> more is not an option.

It depends.  I definately want to start development on 2.4
and keep some patch around. If things turn out to be trivial
we can submit the patch for 2.4, if not we can keep the
patch separately.

> I'm willing to help, if we collect some ideas on WHAT to do
> first.

- write a script to move all extern inline functions to
  a C file and have them compile out-of-line
- drastically reduce (or even abolish) hash tables for
  buffer cache, page cache, network routing, sockets, ...
  [ if you have 20 items, you may as well walk a list ]
- compile out all kinds of code which make optimisations
  that only work for larger machines (dynamic readahead
  size reduction, ...)

> Autotuning is nice, but has always the chance to fail for corner
> cases. Taking these into account to generates too much code
> bloat. So making the required tunables available (as already
> happend with threads-max, file-max and the like) is supporting
> the idea of 'providing features, not policy'.

*nod*

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
