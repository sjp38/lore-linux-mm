Message-ID: <20040209182013.59140.qmail@web14302.mail.yahoo.com>
Date: Mon, 9 Feb 2004 10:20:13 -0800 (PST)
From: Kanoj Sarcar <kanojsarcar@yahoo.com>
Subject: Re: Documentation/vm/locking: why not hold two PT locks?
In-Reply-To: <87r7x4ns3m.fsf@cs.uga.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed L Cashin <ecashin@uga.edu>
Cc: Robert Love <rml@ximian.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--- Ed L Cashin <ecashin@uga.edu> wrote:
> Kanoj Sarcar <kanojsarcar@yahoo.com> writes:
> 
> ...
> > Its been a while since I wrote up those rules in
> > the "locking" file, but the example that Robert
> has
> > pointed out involving two different threads, each 
> > crabbing one mm lock and trying for the next one,
> > is the deadlock I had in mind. There may have been
> > new changes in 2.5 timeframe that also requires
> > the rule, I am not sure.
> 
> Thanks, Kanoj!
> 
> After further looking into it, one thing in
> Documentation/vm/locking
> does seem out of date.  It says that "Page stealers
> hold kernel_lock
> to protect against a bunch of races."
> 
> The only page stealing code that I can find is in
> rmap.c and vmscan.c.
> When vmscan.c:shrink_caches and its callees need to
> unmap a page,
> rmap.c:try_to_unmap gets called.  But nowhere is
> there a lock_kernel
> call that I could find.  Instead, they use trylocks
> and get the page
> table lock before stealing a page.
> 
> Are there other page stealers?
> 

Hi,

When "locking" came into being, vmscan was the only
page stealer.

Thanks.

Kanoj

> -- 
> --Ed L Cashin     PGP public key:
> http://noserose.net/e/pgp/
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
