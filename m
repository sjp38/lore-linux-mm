Date: Tue, 17 Apr 2001 16:48:25 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
In-Reply-To: <Pine.LNX.4.30.0104161353270.20939-100000@fs131-224.f-secure.com>
Message-ID: <Pine.LNX.4.21.0104171648010.14442-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-mm@kvack.org, Andrew Morton <andrewm@uow.edu.au>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Apr 2001, Szabolcs Szakacsits wrote:
> On Fri, 13 Apr 2001, Rik van Riel wrote:
> 
> > That is, when the load gets too high, we temporarily suspend
> > processes to bring the load down to more acceptable levels.
> 
> Please don't. Or at least make it optional and not the default or user
> controllable. Trashing is good.

This sounds like you have no idea what thrashing is.

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
