Date: Fri, 18 May 2001 19:44:39 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Linux 2.4.4-ac10
In-Reply-To: <Pine.LNX.4.33.0105182153570.387-100000@mikeg.weiden.de>
Message-ID: <Pine.LNX.4.21.0105181941070.5531-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@wen-online.de>
Cc: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 May 2001, Mike Galbraith wrote:

> While I'd love to have more control, I can't say I have a clear
> picture of exactly how I'd like those knobs to look.  I always
> start out trying to get it to seek the right behavior.. :) and
> end up fighting so many different fires I get lost in the smoke.

This is the core of why we cannot (IMHO) have a discussion
of whether a patch introducing new VM tunables can go in:
there is no clear overview of exactly what would need to be
tunable and how it would help.

When you and Ingo have something more specific to talk about,
I guess we can decide on that; but deciding on something like
this isn't really possible without at least knowing what should
be tunable ;)

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
