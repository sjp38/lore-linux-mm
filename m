Message-ID: <20040209074409.32804.qmail@web14306.mail.yahoo.com>
Date: Sun, 8 Feb 2004 23:44:09 -0800 (PST)
From: Kanoj Sarcar <kanojsarcar@yahoo.com>
Subject: Re: Documentation/vm/locking: why not hold two PT locks?
In-Reply-To: <1076278320.6015.1.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@ximian.com>, Ed L Cashin <ecashin@uga.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--- Robert Love <rml@ximian.com> wrote:
> On Sun, 2004-02-08 at 16:47 -0500, Ed L Cashin
> wrote:
> 
> > If that's all there is to it, then in my case, I
> have imposed a
> > locking hierarchy on my own code, so that wouldn't
> happen in my code.
> > I have a semaphore "S" outside of mmap_sem and
> page_table_lock.  Every
> > call path that can get to my code takes S before
> getting the
> > mmap_sem.  
> 
> Well, you don't follow a locking hierarchy either,
> you just have a
> global synchronizer (your semaphore S).  Same
> effect, sure, you cannot
> deadlock.
> 
> But anyone else who touches two or more PT's will
> deadlock.
> 
> > So it looks like my code is safe but not so
> efficient, since T2 has to
> > sleep when it doesn't get the semaphore S.  Is
> there some other
> > complication I'm missing?
> 
> It could be that _I_ am missing something, and there
> is another reason
> why we don't grab more than one PT concurrently. 
> But the locking
> hierarchy is still a concern.
> 
> 	Robert Love
>

Hi,

Its been a while since I wrote up those rules in
the "locking" file, but the example that Robert has
pointed out involving two different threads, each 
crabbing one mm lock and trying for the next one,
is the deadlock I had in mind. There may have been
new changes in 2.5 timeframe that also requires
the rule, I am not sure.

Thanks.

Kanoj

> 
> --
> To unsubscribe, send a message with 'unsubscribe
> linux-mm' in
> the body to majordomo@kvack.org.  For more info on
> Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org">
> aart@kvack.org </a>


__________________________________
Do you Yahoo!?
Yahoo! Finance: Get your refund fast by filing online.
http://taxes.yahoo.com/filing.html
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
