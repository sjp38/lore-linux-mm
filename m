Date: Thu, 22 Jun 2000 20:27:16 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] RSS guarantees and limits
In-Reply-To: <m2og4t9w7j.fsf@boreas.southchinaseas>
Message-ID: <Pine.LNX.4.21.0006222022420.1137-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Fremlin <vii@penguinpowered.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 22 Jun 2000, John Fremlin wrote:
> Stephen Tweedie <sct@redhat.com> writes:

> > It is critically important that when under memory pressure, a
> > system administrator can still log in and kill any runaway
> > processes.  The smaller apps in question here are system daemons
> > such as init, inetd and telnetd, and user apps such as bash and
> > ps.  We _must_ be able to allow them to make at least some
> > progress while the VM is under load.
> 
> I agree completely. It was one of the reasons I suggested that a
> syscall like nice but giving info to the mm layer would be
> useful. In general, small apps (xeyes,biff,gpm) don't deserve
> any special treatment.

Why not?  In scheduling processes which use less CPU get
a better response time. Why not do the same for memory
use? The less memory you use, the less agressive we'll be
in trying to take it away from you.

Of course a small app should be removed from memory when
it's sleeping, but there's no reason to not apply some
degree of fairness in memory allocation and memory stealing.

> I also said that on a multiuser system it is important that one
> user can't hog the system.

*nod*

> The only general solution I can see is to give some process
> (groups) a higher MM priority, by analogy with nice.

That you can't see anything better doesn't mean it
isn't possible ;)

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
