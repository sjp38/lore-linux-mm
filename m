Date: Sat, 28 Dec 2002 08:39:12 +0100 (CET)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: Ingo Molnar <mingo@elte.hu>
Subject: Re: shared pagetable benchmarking
In-Reply-To: <3E0D4B83.FEE220B8@digeo.com>
Message-ID: <Pine.LNX.4.44.0212280837340.2443-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Dave McCracken <dmccr@us.ibm.com>, Daniel Phillips <phillips@arcor.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Dec 2002, Andrew Morton wrote:

> Yup.  Ingo said at the time:
> 
>   It would be faster to iterate the pagecache mapping's radix tree
>   and the pagetables at once, but it's also *much* more complex. I have
>   tried to implement it and had to unroll the change - mixing radix tree
>   walking and pagetable walking and getting all the VM details right is
>   really complex - especially considering all the re-lookup race checks
>   that have to occur upon IO.
> 
> But find_get_pages() is well-suited to this, and was not in place when
> he did this work.

i agree that find_get_pages() would simplify this work. I did not consider
group-lookup - i tried to implement an algorithm that had a single-page
scope, to keep the amount of locked pages to the minimum.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
