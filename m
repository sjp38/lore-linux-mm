Date: Thu, 26 Oct 2000 19:16:38 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Discussion on my OOM killer API
In-Reply-To: <Pine.LNX.4.10.10010261345320.2575-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0010261857580.15696-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Oct 2000, Linus Torvalds wrote:
> On Thu, 19 Oct 2000, Rik van Riel wrote:
> > > I'm also willing to maintain it ;-)
> > 
> > Linus, how would you feel about an interface that allows
> > people to insomd/rmmod their own OOM handler ?
> 
> I hate the idea.

*grin*

I agree with that, except for one small point...

> I dislike that kind of approach in general. I don't like plug-in
> schedulers, etc either. I think it's a cop-out, saying that we
> cannot do a good enough job, and claiming that it's such a
> difficult problem that we should let the user decide.

... the generic OOM killer we have in the system right now
should do a good job in most of the cases, but I've heard
from a number of people who would like to have the OOM killer
do something "special" for their system.

For instance, they want to have student programs killed before
staff programs, or want to be able to specify some priveledged
processes that will never be killed (or do other things that
we probably don't want to have in the generic killer).

> In short, it's one of those things that sounds like a good idea,
> but that results in absolute crap in the end.

Sure, but the idea is to keep this absolute crap out of
the kernel and local to the systems where people need
to replace the OOM killer because of special reasons ;)

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
