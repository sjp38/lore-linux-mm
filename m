Date: Fri, 27 Oct 2000 23:51:02 +0100 (BST)
From: James Sutherland <jas88@cam.ac.uk>
Subject: Re: Discussion on my OOM killer API
In-Reply-To: <20001027224358.C3687F42C@agnes.fremen.dune>
Message-ID: <Pine.LNX.4.10.10010272348440.17407-100000@dax.joh.cam.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jfm2@club-internet.fr
Cc: ingo.oeser@informatik.tu-chemnitz.de, riel@conectiva.com.br, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 28 Oct 2000 jfm2@club-internet.fr wrote:

> > > Only solution is to allow the OOM never to be swapped but you also
> > > need all libraries to remain in memory or have the kernel check OOM is
> > > statically linked.  However this user space OOM will then have a
> > > sigificantly memory larger footprint than a kernel one and don't
> > > forget it cannot be swapped.
> > 
> > Not necessarily "significantly larger"; it can be small and simple without
> > using any libraries.
> 
> This I agree: a selfcontained source (ie no use of library functions
> because these have to be general so marge) can produce a small binary
> if you link it adequately (ie not with the standard C initilization
> code).

So you agree the OOM handler can be in userspace without unacceptable
overhead?

> > > Hhere is an heuristic who tends to work well ;-)
> > > 
> > > if (short_on_memory == TRUE )  {
> > >      kill_all_copies_of_netscape()
> > > }
> > 
> > Yes, that's a good start. Now we've done that, but we're still OOM, what
> > do you kill next?
> 
> I thought you would notice it was a joke.  Since 99% of OOMs are
> produced by netscape best kill netscape first and ask questions later.

I knew it wasn't intended as a serious comment, but the point remains: the
guesswork involved is too complex and variable to belong in the kernel.
This sort of "intelligent" handling of complex situations should only be
attempted from userspace: the kernel MUST be kept as simple as possible.
As a last resort, kill anything "suspicious" looking, until the problem
has gone. If we aren't that far gone, leave it to userspace to sort the
problem out.


James.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
