From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199907081803.LAA78042@google.engr.sgi.com>
Subject: Re: [RFT][PATCH] 2.3.10 pre5 SMP/vm fixes
Date: Thu, 8 Jul 1999 11:03:27 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.10.9907080959220.6648-100000@penguin.transmeta.com> from "Linus Torvalds" at Jul 8, 99 10:00:30 am
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>
>
>
> On Thu, 8 Jul 1999, Kanoj Sarcar wrote:
> >
> > *****************************************************************
> > 3. In mm/memory.c, a new comment claims:
> > "The adding of pages is protected by the MM semaphore"
> > which is not quite correct, since swapoff does not hold this semaphore.
>
> The fix is to fix swapoff, not to change the comment.
> 

Couldn't agree more ... that is why I sent a patch for this (ie to
fix swapoff) on linux-mm, and reiterated the pointer to the patch 
in this thread. Here it is again:

    http://humbolt.nl.linux.org/lists/linux-mm/1999-06/msg00075.html

Let me know if you want me to create it against pre5. Or if you 
see a problem with it ... we talked about it quite a bit on
linux-mm.


> page_table_lock is _not_ going to be added to this path - I refuse to add> locks to common cases just to protect against things that never run in
> practice.
>

I assume you are talking about the fault path here ... none of the 
patches I posted adds page_table_lock to that path, right? Of
course without the lock, there might be other problems, I am 
not sure yet, will let you know if I see something ...

Kanoj

>               Linus
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
