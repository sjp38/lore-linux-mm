Date: Thu, 26 Oct 2000 13:47:55 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Discussion on my OOM killer API
In-Reply-To: <Pine.LNX.4.21.0010191459320.19735-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10010261345320.2575-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 19 Oct 2000, Rik van Riel wrote:
> 
> > I'm also willing to maintain it ;-)
> 
> Linus, how would you feel about an interface that allows
> people to insomd/rmmod their own OOM handler ?

I hate the idea.

I dislike that kind of approach in general. I don't like plug-in
schedulers, etc either. I think it's a cop-out, saying that we cannot do a
good enough job, and claiming that it's such a difficult problem that we
should let the user decide. And in the end it ends up just screwing
everybody, because all the modules will do the wrong thing in some
circumstances, and nobody ever bothers to test _their_ module for anything
but the case they care about.

In short, it's one of those things that sounds like a good idea, but that
results in absolute crap in the end.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
