Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 703856B002B
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 21:28:40 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so6850242obc.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2012 18:28:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350141021.21172.14949.camel@edumazet-glaptop>
References: <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com>
	<m27gqwtyu9.fsf@firstfloor.org>
	<alpine.DEB.2.00.1210111558290.6409@chino.kir.corp.google.com>
	<m2391ktxjj.fsf@firstfloor.org>
	<alpine.DEB.2.00.1210130249070.7462@chino.kir.corp.google.com>
	<1350141021.21172.14949.camel@edumazet-glaptop>
Date: Tue, 16 Oct 2012 10:28:39 +0900
Message-ID: <CAAmzW4M8drwRPy_qWxnkG3-GKGPq+m24me+pGOWNtPzA15iVfg@mail.gmail.com>
Subject: Re: [Q] Default SLAB allocator
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Ezequiel Garcia <elezegarcia@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Tim Bird <tim.bird@am.sony.com>, celinux-dev@lists.celinuxforum.org

Hello, Eric.

2012/10/14 Eric Dumazet <eric.dumazet@gmail.com>:
> SLUB was really bad in the common workload you describe (allocations
> done by one cpu, freeing done by other cpus), because all kfree() hit
> the slow path and cpus contend in __slab_free() in the loop guarded by
> cmpxchg_double_slab(). SLAB has a cache for this, while SLUB directly
> hit the main "struct page" to add the freed object to freelist.

Could you elaborate more on how 'netperf RR' makes kernel "allocations
done by one cpu, freeling done by other cpus", please?
I don't have enough background network subsystem, so I'm just curious.

> I played some months ago adding a percpu associative cache to SLUB, then
> just moved on other strategy.
>
> (Idea for this per cpu cache was to build a temporary free list of
> objects to batch accesses to struct page)

Is this implemented and submitted?
If it is, could you tell me the link for the patches?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
