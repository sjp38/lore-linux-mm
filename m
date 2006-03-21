Message-ID: <441FEF8D.7090905@yahoo.com.au>
Date: Tue, 21 Mar 2006 23:20:29 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH][0/8] (Targeting 2.6.17) Posix memory locking and balanced
 mlock-LRU semantic
References: <bc56f2f0603200535s2b801775m@mail.gmail.com>
In-Reply-To: <bc56f2f0603200535s2b801775m@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stone Wang <pwstone@gmail.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stone Wang wrote:
> Both one of my friends(who is working on a DBMS oriented from
> PostgreSQL) and i had encountered unexpected OOMs with mlock/mlockall.
> 

I'm not sure this is a great idea. There are more conditions than just
mlock that prevent pages being reclaimed. Running out of swap, for
example, no swap, page temporarily pinned (in other words -- any duration
from fleeting to permanent). I think something _much_ simpler could be
done for a more general approach just to teach the VM to tolerate these
pages a bit better.

Also, supposing we do want this, I think there is a fairly significant
queue of mm stuff you need to line up behind... it is probably asking
too much to target 2.6.17 for such a significant change in any case.

But despite all that I looked though and have a few comments ;)
Kudos for jumping in and getting your hands dirty! It can be tricky code.

> The patch brings Linux with:
> 1. Posix mlock/munlock/mlockall/munlockall.
>    Get mlock/munlock/mlockall/munlockall to Posix definiton: transaction-like,
>    just as described in the manpage(2) of mlock/munlock/mlockall/munlockall.
>    Thus users of mlock system call series will always have an clear map of
>    mlocked areas.

In what way are we not now posix compliant now?

-- 
SUSE Labs, Novell Inc.


Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
