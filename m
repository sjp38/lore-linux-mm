Date: Thu, 19 Oct 2000 15:02:06 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Discussion on my OOM killer API
In-Reply-To: <20001019122331.H840@nightmaster.csn.tu-chemnitz.de>
Message-ID: <Pine.LNX.4.21.0010191459320.19735-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Oct 2000, Ingo Oeser wrote:

> You might remember the shortest "API" ever: The OOM killer API[1]
> I posted during the last round of hot discussion on OOM killing.
> 
> What are the reasons of not including it? Its only a few lines
> for a complete API. 
> 
> I could have made it full blown with reference counting,
> automatic releasing old OOM killers and a nice proc interface[2]
> for letting the user say which he wants. 

> I'm also willing to maintain it ;-)

Linus, how would you feel about an interface that allows
people to insomd/rmmod their own OOM handler ?

I think we should be able to do this in less than half
a kb of kernel code and it might be able to get the last
few people who complain silenced as they try to produce
their own OOM killer ;)

[and we have a maintainer ... what else do we need ? ]

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
