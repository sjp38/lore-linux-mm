From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200004090040.RAA49059@google.engr.sgi.com>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
Date: Sat, 8 Apr 2000 17:40:45 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.21.0004090135050.620-100000@alpha.random> from "Andrea Arcangeli" at Apr 09, 2000 01:39:10 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> On Sat, 8 Apr 2000, Kanoj Sarcar wrote:
> 
> >As I mentioned before, have you stress tested this to make sure grabbing
> 
> I have stress tested the whole thing (also a few minutes ago to check the
> latest patch) but it never locked up so we have to think about it.

Okay good.

> 
> Could you explain why you think it's the inverse lock ordering?

Let me see, if I can come up with something, I will let you know. If
it survives stress testing, it probably is not inverse locking.

Btw, I am looking at your patch with message id
<Pine.LNX.4.21.0004081924010.317-100000@alpha.random>, that does not
seem to be holding vmlist/pagetable lock in the swapdelete code (at
least at first blush). That was partly why I wanted to know what fixes 
are in your patch ...

Note: I prefer being able to hold mmap_sem in the swapdelete path, that
will provide protection against fork/exit races too. I will try to port
over my version of the patch, and list the problems it fixes ...

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
