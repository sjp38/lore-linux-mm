Date: Thu, 3 Aug 2000 16:32:39 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: RFC: design for new VM
In-Reply-To: <Pine.LNX.4.10.10008031132400.6384-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0008031631260.24022-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: lamont@icopyright.com, Chris Wedgwood <cw@f00f.org>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 3 Aug 2000, Linus Torvalds wrote:
> On Thu, 3 Aug 2000 lamont@icopyright.com wrote:
> > 
> > CONFIG_VM_FREEBSD_ME_HARDER would be a nice kernel option to have, if
> > possible.  Then drop it iff the tweaks are proven over time to work
> > better.
> 
> On eproblem is/may be the basic setup. Does FreeBSD have the
> notion of things like high memory etc? Different memory pools
> for NUMA? Things like that..

That's basically a minor issue. The FreeBSD page replacement
code (or rather the slightly modified one) can just be glued
on top of that.

If the code isn't modular enough to do that it wouldn't be
maintainable anyway.

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
