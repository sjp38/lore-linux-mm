Date: Sun, 22 Apr 2001 17:41:41 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
In-Reply-To: <ssf6etkhgrc2ejgcv22ophdj7pb5fbifbk@4ax.com>
Message-ID: <Pine.LNX.4.21.0104221740380.1685-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "James A.Sutherland" <jas88@cam.ac.uk>
Cc: Jonathan Morton <chromi@cyberspace.org>, "Joseph A. Knapka" <jknapka@earthlink.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 22 Apr 2001, James A.Sutherland wrote:

> >>How exactly will your approach solve the two process case, yet still
> >>keeping the processes running properly?
> >
> >It will allocate one process it's entire working set in physical RAM, 
> 
> Which one?

A random one. And after some time you switch, suspending the
first process and letting the other one run.

Note that I have code for this on my system here, I'll put it
online soon.

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
