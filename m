Date: Fri, 2 Aug 2002 21:39:28 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: large page patch (fwd) (fwd) 
In-Reply-To: <E17aqUv-000344-00@w-gerrit2>
Message-ID: <Pine.LNX.4.44.0208022136380.2733-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerrit Huizenga <gh@us.ibm.com>
Cc: Andrew Morton <akpm@zip.com.au>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, Hubertus Franke <frankeh@watson.ibm.com>, wli@holomorpy.com, swj@cse.unsw.edu.au, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Fri, 2 Aug 2002, Gerrit Huizenga wrote:

> In message <Pine.LNX.4.44.0208021757490.2210-100000@home.transmeta.com>, > : Li
> nus Torvalds writes:
> >
> >
> > On Fri, 2 Aug 2002, Andrew Morton wrote:
> > >
> > > Remind me again what's wrong with wrapping the Intel syscalls
> > > inside malloc() and then maybe grafting a little hook into the shm code?
> >
> > Indeed.
>
> Do you really want all calls to malloc to allocate non-pageable
> memory?  And I doubt that this memory will be pageable in time for
> 2.5.

No, I'm saying that you can do the SHM_LARGEPAGE bit testing in user space
if you want to.

And obviously it will only succeed for root or similar user anyway.

But hey, the proof is in the pudding. If you guys can come up with a
better scheme that does not pollute the VM paths and has better semantics,
I don't think anybody will complain.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
