Date: Thu, 22 Jun 2000 16:12:42 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] RSS guarantees and limits
In-Reply-To: <m2lmzx38a1.fsf@boreas.southchinaseas>
Message-ID: <Pine.LNX.4.21.0006221606300.10785-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Fremlin <vii@penguinpowered.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 22 Jun 2000, John Fremlin wrote:
> Rik van Riel <riel@conectiva.com.br> writes:
> 
> > I think I have an idea to solve the following two problems:
> > - RSS guarantees and limits to protect applications from
> >   each other
> 
> I think that this principle should be queried. Taking the base
> unit to be the process, while reasonable, is not IMHO a good
> idea.
> 
> For multiuser systems the obvious unit is the user; that is, it
> is clearly necessary to stop one user hogging system memory,
> whether they've got 5 or 500 processes.

Once userbeans is in place this whole process can be simply
extended to work on the level of both users and processes.

> > - make sure streaming IO doesn't cause the RSS of the application
> >   to grow too large
> 
> This problem could be more generally stated: make sure that
> streaming IO does not chuck stuff which will be looked at again
> out of cache.

Which is exactly what my code will do. ;)
(you may want to try to understand my code before you flame)

> > The idea revolves around two concepts. The first idea is to
> > have an RSS guarantee and an RSS limit per application, which
> > is recalculated periodically. A process' RSS will not be shrunk
> > to under the guarantee and cannot be grown to over the limit.
> > The ratio between the guarantee and the limit is fixed (eg.
> > limit = 4 x guarantee).
> 
> This is complex and arbitrary;

> I do agree that looking at and adjusting to processes memory
> access patterns is a good idea, if it can be done right.

*sigh*

You may want to read my idea again and try to do another
response when you understand it. I'm sorry I have to flame
you like this, but you really don't seem to grasp the concept.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
