Received: by uproxy.gmail.com with SMTP id o2so240477uge
        for <linux-mm@kvack.org>; Fri, 24 Mar 2006 07:05:10 -0800 (PST)
Message-ID: <bc56f2f0603240705y3b4abe3ej@mail.gmail.com>
Date: Fri, 24 Mar 2006 10:05:09 -0500
From: "Stone Wang" <pwstone@gmail.com>
Subject: Re: [PATCH][0/8] (Targeting 2.6.17) Posix memory locking and balanced mlock-LRU semantic
In-Reply-To: <441FEF8D.7090905@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <bc56f2f0603200535s2b801775m@mail.gmail.com>
	 <441FEF8D.7090905@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2006/3/21, Nick Piggin <nickpiggin@yahoo.com.au>:
> Stone Wang wrote:
> > Both one of my friends(who is working on a DBMS oriented from
> > PostgreSQL) and i had encountered unexpected OOMs with mlock/mlockall.
> >
>
> I'm not sure this is a great idea. There are more conditions than just
> mlock that prevent pages being reclaimed. Running out of swap, for
> example, no swap, page temporarily pinned (in other words -- any duration
> from fleeting to permanent). I think something _much_ simpler could be
> done for a more general approach just to teach the VM to tolerate these
> pages a bit better.
>
> Also, supposing we do want this, I think there is a fairly significant
> queue of mm stuff you need to line up behind... it is probably asking
> too much to target 2.6.17 for such a significant change in any case.
>
> But despite all that I looked though and have a few comments ;)
> Kudos for jumping in and getting your hands dirty! It can be tricky code.
>
> > The patch brings Linux with:
> > 1. Posix mlock/munlock/mlockall/munlockall.
> >    Get mlock/munlock/mlockall/munlockall to Posix definiton: transaction-like,
> >    just as described in the manpage(2) of mlock/munlock/mlockall/munlockall.
> >    Thus users of mlock system call series will always have an clear map of
> >    mlocked areas.
>
> In what way are we not now posix compliant now?

Currently, Linux's mlock for example, may fail with  only part of its
task finished.

While accroding to POSIX definition:

man mlock(2)

"
RETURN VALUE
       On success, mlock returns zero.  On error, -1 is returned, errno is set
       appropriately, and no changes are made to  any  locks  in  the  address
       space of the process.
"

Shaoping Wang

>
> --
> SUSE Labs, Novell Inc.
>
>
> Send instant messages to your online friends http://au.messenger.yahoo.com
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
