Message-ID: <3D4B2535.2B1F5BF8@zip.com.au>
Date: Fri, 02 Aug 2002 17:35:01 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: large page patch (fwd) (fwd)
References: <Pine.LNX.4.33.0208021252090.2466-100000@penguin.transmeta.com> <92200000.1028332493@flay>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Hubertus Franke <frankeh@watson.ibm.com>, wli@holomorpy.com, swj@cse.unsw.edu.au, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> >> Let me than turn around the table. Have you looked at our patch for 2.4.18.
> >> It doesn't add anything to the hot path either, if the (vma->pg_order == 0).
> >> Period.
> >
> > Nobody has forwarded the patch, and I've seen no discussion of it on the
> > kernel mailing lists.
> >
> > Guess what the answer is?
> >
> > Is it 10 lines of code in the VM subsystem?
> 
> No, and you're not going to like the patch in it's current incarnation by
> the sound of it. So, having listened to your objections, we're going to
> take a slightly different course - we will prepare a minimal version of
> the patch with very low impact on the core VM code, but using more
> standard interfaces to access it (eg the shmem method you outlined
> earlier). It'll have a little less functionality, but so be it.

Remind me again what's wrong with wrapping the Intel syscalls
inside malloc() and then maybe grafting a little hook into the shm code?

>...
> We should have this available in a few days - if you could hold off
> until then, we should be able to do an objective comparison? I believe
> we can make something that's acceptable to you.

More than a few days.  The patch which went around isn't Rohit's
latest, and it hasn't even been tested in 2.5 and we're considering
replacing the shm key with an fd, and...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
