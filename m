Subject: Re: VM tuning through fault trace gathering [with actual code]
References: <Pine.LNX.4.21.0106251456130.7419-100000@imladris.rielhome.conectiva>
	<m28zigi7m4.fsf@boreas.yi.org.> <01062610022607.01124@spigot>
From: John Fremlin <vii@users.sourceforge.net>
Date: 26 Jun 2001 20:29:16 +0100
In-Reply-To: <01062610022607.01124@spigot> (Scott F. Kaplan's message of "Tue, 26 Jun 2001 10:02:26 -0400")
Message-ID: <m21yo7hwfn.fsf@boreas.yi.org.>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Scott F <Kaplan@boreas.yi.org.>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi people!

I just sent an updated version of the patch to Scott, which faults on
almost every mem access. Unfortunately that slows the system to a
crawl (doh), in fact so much of a crawl that nothing much
happens. Anybody have a turbofast P4/Athlon they want to lend or send
me ;-)

Scott F. Kaplan <sfkaplan@cs.amherst.edu> writes:

[...]

> Not to look a gift horse in the mouth, but the ability to trace
> selectively either the whole system OR an individual application
> would be useful.  Certainly whole system traces would be new, as
> individual process traces can be gathered with other tools (although
> I don't know of one available on Linux -- I'm stuck using ATOM under
> Alpha/Tru64.)

That looks like a very cool package (AFAICS it instruments the binary
to call a subroutine before every memory access).

The pagetrace patch has a slightly different goal however. The alpha
people seemed to want to tune their cache behaviour whereas I want to
tune the VM behaviour.

> > In the current patch all pagefaults are recorded from all
> > sources. I'd like to be able to catch read(2) and write(2) (buffer
> > cache stuff) as well but I don't know how . . . .
> 
> Also a great idea.  Someone who works on the filesystem end of the
> kernel should be able to add support for this kind of thing without
> much trouble, don't you think?

I'd really like a clue or too in this direction certainly because its
difficult to simulate the VM if you don't know how big e.g. the
directory dcache is.

> > Of course! It is important not to regard each thread group as an
> > independent entity IMHO (had a big old argument about this).
> 
> Yes, I was the other side of that argument! :-)  I'll still contend that, 

Hehe. Let's not go into that right now ;-)

[...]

--
	http://ape.n3.net
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
