Message-ID: <20000828190557.A5579@saw.sw.com.sg>
Date: Mon, 28 Aug 2000 19:05:57 +0800
From: Andrey Savochkin <saw@saw.sw.com.sg>
Subject: Re: Question: memory management and QoS
References: <39A672FD.CEEA798C@asplinux.ru> <39A69617.CE4719EF@tuke.sk> <39A6D45D.6F4C3E2F@asplinux.ru> <39AA24A5.CB461F4E@tuke.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <39AA24A5.CB461F4E@tuke.sk>; from "Jan Astalos" on Mon, Aug 28, 2000 at 10:36:53AM
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Astalos <astalos@tuke.sk>
Cc: Yuri Pudgorodsky <yur@asplinux.ru>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 28, 2000 at 10:36:53AM +0200, Jan Astalos wrote:
[snip]
> How about to split memory QoS into:
>   - guarantied amount of physical memory
>   - guarantied amount of virtual memory  
> 
> The former is much more complicated and includes page replacement policies
> along with fair sharing of physical memory (true core of QoS).
> 
> The latter should gurantee users requested amount of VM. I.e. avoid this kind
> of situation: successful malloc, a lot of work, killed in action due to OOM (
> out of munition^H^H^H^H^H^H^H^Hmemory), RIP...
> In the current state it's the problem of system administration. In my approach
> it will become user's problem. So user would be able to satisfy his need for
> VM himself and system would only take care of fair management of physical memory.

That's what user beancounter patch is about.
Except that I'm not so strong in the judgements.
For example, I don't think that overcommits are evil.  They are quite ok if
1. the system can provide guarantee that certain processes can never be
   killed because of OOM;
2. the whole system reaction to OOM situation is well predictable.
It's a part of quality of service: some processes/groups of processes have
better service, some others only best effort.

It's simply impossible to run Internet servers without overcommits.
I encourage you to take a look at
ftp://ftp.sw.com.sg/pub/Linux/people/saw/kernel/user_beancounter/MemoryManagement.html,
especially Overcommits section.
I need real guarantees only to some of processes, and I can bear overcommits
and 0.01%/year chances for other processes being killed if it saves me the
cost of 10Gygabytes of RAM (and the cost of motherboard which supports this
amount of memory).

[snip]
> 
> > Userbeancounters are for that accounting. The problem is there are many different objects
> > in play here, and sometimes it is not possible to associate them with particular user.
> 
> But that's not a design flaw, it's a problem of implementation.

No.
How do you propose to associate shared pages (or unmapped page cache) with a
particular user?

Regards
					Andrey V.
					Savochkin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
