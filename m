Date: Thu, 26 Oct 2000 17:10:14 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Discussion on my OOM killer API
In-Reply-To: <Pine.LNX.4.10.10010270056590.11273-100000@dax.joh.cam.ac.uk>
Message-ID: <Pine.LNX.4.10.10010261708490.3053-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Sutherland <jas88@cam.ac.uk>
Cc: Rik van Riel <riel@conectiva.com.br>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 27 Oct 2000, James Sutherland wrote:
> 
> Which begs the question, where did the userspace OOM policy daemon go? It,
> coupled with Rik's simple in-kernel last-ditch handler, should cover most
> eventualities without the need for nasty kernel kludges.

I agree. Possibly with help to the user-space OOM thing. We should
probably implement the same SIGDANGER that some other Unixes have, and
then anybody can implement their own low-on-memory thing by having a
user-mode server that does a mlockall() and reacts to SIGDANGER by
spraying anything it wants with kill(9)'s.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
