From: jfm2@club-internet.fr
In-reply-to: <Pine.LNX.4.10.10010272309040.17292-100000@dax.joh.cam.ac.uk>
	(message from James Sutherland on Fri, 27 Oct 2000 23:11:11 +0100
	(BST))
Subject: Re: Discussion on my OOM killer API
References: <Pine.LNX.4.10.10010272309040.17292-100000@dax.joh.cam.ac.uk>
Message-Id: <20001027224358.C3687F42C@agnes.fremen.dune>
Date: Sat, 28 Oct 2000 00:43:58 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jas88@cam.ac.uk
Cc: jfm2@club-internet.fr, ingo.oeser@informatik.tu-chemnitz.de, riel@conectiva.com.br, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> > Only solution is to allow the OOM never to be swapped but you also
> > need all libraries to remain in memory or have the kernel check OOM is
> > statically linked.  However this user space OOM will then have a
> > sigificantly memory larger footprint than a kernel one and don't
> > forget it cannot be swapped.
> 
> Not necessarily "significantly larger"; it can be small and simple without
> using any libraries.
> 

This I agree: a selfcontained source (ie no use of library functions
because these have to be general so marge) can produce a small binary
if you link it adequately (ie not with the standard C initilization
code).


> > > > The original idea was an simple "I install a module and lock it
> > > > into memory" approach[1] for kernel hackers, which is _really_
> > > > easy to to and flexibility for nothing[2].
> > > > 
> > > > If the Rik and Linus prefer the user-accessable variant via
> > > > /proc, I'll happily implement this.
> > > > 
> > > > I just intended to solve a "religious" discussion via code
> > > > instead of words ;-)
> > > 
> > > I was planning to implement a user-side OOM killer myself - perhaps we
> > > could split the work, you do kernel-side, I'll do the userspace bits?
> > > 
> > 
> > Hhere is an heuristic who tends to work well ;-)
> > 
> > if (short_on_memory == TRUE )  {
> >      kill_all_copies_of_netscape()
> > }
> 
> Yes, that's a good start. Now we've done that, but we're still OOM, what
> do you kill next?
> 

I thought you would notice it was a joke.  Since 99% of OOMs are
produced by netscape best kill netscape first and ask questions later.

-- 
			Jean Francois Martinez

Project Independence: Linux for the Masses
http://www.independence.seul.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
