Date: Fri, 27 Oct 2000 07:46:31 +0100 (BST)
From: James Sutherland <jas88@cam.ac.uk>
Subject: Re: Discussion on my OOM killer API
In-Reply-To: <Pine.LNX.4.10.10010261708490.3053-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.10.10010270740040.11948-100000@dax.joh.cam.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Oct 2000, Linus Torvalds wrote:

> 
> On Fri, 27 Oct 2000, James Sutherland wrote:
> > 
> > Which begs the question, where did the userspace OOM policy daemon go? It,
> > coupled with Rik's simple in-kernel last-ditch handler, should cover most
> > eventualities without the need for nasty kernel kludges.
> 
> I agree. Possibly with help to the user-space OOM thing. We should
> probably implement the same SIGDANGER that some other Unixes have, and
> then anybody can implement their own low-on-memory thing by having a
> user-mode server that does a mlockall() and reacts to SIGDANGER by
> spraying anything it wants with kill(9)'s.

Yes, that should keep most people happy; better still, it could try other
approaches before kill9: start shouting at the console when you're down to
the last 25Mb, disable logins at 10Mb and start SIGTERMing things at 5,
perhaps. Or maybe bring some "emergency" swapspace online and disable
non-root logins. That way, if the sysadmin responds quickly enough, they
can clear out whatever THEY think is causing a problem; if not, they'll
arrive to find a fully working machine with a couple of people complaining
about Netscape having crashed yet again, rather than an init-less
machine!


James.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
