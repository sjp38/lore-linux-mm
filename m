Message-ID: <39AA56D1.EC5635D3@tuke.sk>
Date: Mon, 28 Aug 2000 14:10:57 +0200
From: Jan Astalos <astalos@tuke.sk>
MIME-Version: 1.0
Subject: Re: Question: memory management and QoS
References: <39A672FD.CEEA798C@asplinux.ru> <39A69617.CE4719EF@tuke.sk> <39A6D45D.6F4C3E2F@asplinux.ru> <39AA24A5.CB461F4E@tuke.sk> <20000828190557.A5579@saw.sw.com.sg>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrey Savochkin <saw@saw.sw.com.sg>
Cc: Yuri Pudgorodsky <yur@asplinux.ru>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrey Savochkin wrote:
> 
> On Mon, Aug 28, 2000 at 10:36:53AM +0200, Jan Astalos wrote:
> [snip]
> > How about to split memory QoS into:
> >   - guarantied amount of physical memory
> >   - guarantied amount of virtual memory
> >
> > The former is much more complicated and includes page replacement policies
> > along with fair sharing of physical memory (true core of QoS).
> >
> > The latter should gurantee users requested amount of VM. I.e. avoid this kind
> > of situation: successful malloc, a lot of work, killed in action due to OOM (
> > out of munition^H^H^H^H^H^H^H^Hmemory), RIP...
> > In the current state it's the problem of system administration. In my approach
> > it will become user's problem. So user would be able to satisfy his need for
> > VM himself and system would only take care of fair management of physical memory.
> 
> That's what user beancounter patch is about.
> Except that I'm not so strong in the judgements.
> For example, I don't think that overcommits are evil.  They are quite ok if

Did you ever asked your users ? Whether they like to see their apps (possibly running
for quite a long time) to be killed (no matter whether with or without warning) ?

> 1. the system can provide guarantee that certain processes can never be
>    killed because of OOM;

Again. I wonder how beancounter would prevent overcommit of virtual memory if you don't
set limits...

> 2. the whole system reaction to OOM situation is well predictable.
> It's a part of quality of service: some processes/groups of processes have
> better service, some others only best effort.

I wont repeat it again. With personal swapfiles _all_ users would be guarantied
to get the amount of virtual memory provided by _themselves_.

> 
> It's simply impossible to run Internet servers without overcommits.

Which kind of Internet server ? Web server or e-mail server with 100+ active users...
Its questionable in what case QoS is more important. (sorry for flamebait)

> I encourage you to take a look at
> ftp://ftp.sw.com.sg/pub/Linux/people/saw/kernel/user_beancounter/MemoryManagement.html,
> especially Overcommits section.
> I need real guarantees only to some of processes, and I can bear overcommits
> and 0.01%/year chances for other processes being killed if it saves me the
> cost of 10Gygabytes of RAM (and the cost of motherboard which supports this
> amount of memory).

As a user, I won't bear _any_ overcommits at all. Once service is paid, I expect
guarantied level of quality. In the case of VM, all the memory I paid for.
For all of my processes.

> 
> [snip]
> >
> > > Userbeancounters are for that accounting. The problem is there are many different objects
> > > in play here, and sometimes it is not possible to associate them with particular user.
> >
> > But that's not a design flaw, it's a problem of implementation.
> 
> No.
> How do you propose to associate shared pages (or unmapped page cache) with a
> particular user?
> 

Do you mean "pages shared between processes of particular user" ? Where's the problem ?
If you mean "pages provided by user to another user", I still don't see the problem...

If you mean anonymous pages not owned by any user, I'm really interested why this should
be allowed (to let some trash to pollute system resources. Is it common practice ?).
OK, this can be solved by allocating some amount of memory (along with swapfile) to
anonymous user.
This kind of pages can be (and should be) avoided by communicating via shared files...

(Btw, the best argument I saw so far. I'm really happy that we finally got to
real arguments why personal swapfiles wouldn't work. The efficiency question can be
solved only with implementation under heavy fire).

Thank you for suggestion...

Jan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
