Date: Wed, 18 Apr 2001 23:11:59 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
In-Reply-To: <Pine.LNX.4.30.0104190031190.20939-100000@fs131-224.f-secure.com>
Message-ID: <Pine.LNX.4.21.0104182311370.1685-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>
Cc: "James A. Sutherland" <jas88@cam.ac.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Apr 2001, Szabolcs Szakacsits wrote:
> On Wed, 18 Apr 2001, James A. Sutherland wrote:
> > >How you want to avoid "deadlocks" when running processes have
> > >dependencies on suspended processes?
> > If a process blocks waiting for another, the thrashing will be
> > resolved.
> 
> This is a big simplification, e.g. not if it polls [not poll(2)].

If it sits there in a loop, the rest of the memory that process
uses can be swapped out ;)

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
