Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id LAA04034
	for <linux-mm@kvack.org>; Fri, 20 Dec 2002 11:59:11 -0800 (PST)
Message-ID: <3E037690.45419D64@digeo.com>
Date: Fri, 20 Dec 2002 11:59:12 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: shared pagetable benchmarking
References: <3E02FACD.5B300794@digeo.com> <9490000.1040401847@baldur.austin.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave McCracken wrote:
> 
> [ ... ]
>

Thanks.

> I'll look for ways to optimize the unsharing to reduce the penalty, but I'm
> not optimistic that we can eliminate it entirely.

So changing userspace to place its writeable memory on a new 4M boundary
would be a big win?

It's years since I played with elf, but I think this is feasible.  Change
the linker and just wait for it to propagate.

Do we know someone who can guide us in prototyping that?

Do we know where the writes are occurring?

> Let's also not lose sight of what I consider the primary goal of shared
> page tables, which is to greatly reduce the page table memory overhead of
> massively shared large regions.

Well yes.  But this is optimising the (extremely) uncommon case while
penalising the (very) common one.

It's the same with the reverse map - we've gone and added significant
expense even to machines and workloads which perform no page reclaim
at all.  Perhaps pagetable sharing can get that back for us.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
