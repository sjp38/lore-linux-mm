Message-ID: <39ACCD6F.37EAA614@tuke.sk>
Date: Wed, 30 Aug 2000 11:01:35 +0200
From: Jan Astalos <astalos@tuke.sk>
MIME-Version: 1.0
Subject: Re: Question: memory management and QoS
References: <39A672FD.CEEA798C@asplinux.ru> <39A69617.CE4719EF@tuke.sk> <39A6D45D.6F4C3E2F@asplinux.ru> <39AA24A5.CB461F4E@tuke.sk> <20000828190557.A5579@saw.sw.com.sg> <39AA56D1.EC5635D3@tuke.sk> <20000828211026.D6043@saw.sw.com.sg>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrey Savochkin <saw@saw.sw.com.sg>
Cc: Yuri Pudgorodsky <yur@asplinux.ru>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrey Savochkin wrote:
[snip]

> > As a user, I won't bear _any_ overcommits at all. Once service is paid, I expect
> > guarantied level of quality. In the case of VM, all the memory I paid for.
> > For all of my processes.
> 
> It means that you pay orders of magnitude more for it.

If I got it right you are speaking about disk space. About sum of disk quotas
"orders of magnitude" higher than actual available disk space, right ?
You will sell users more disk space than you have for the price of your
actual space (and you'll hope that they won't use whole disk).

But you must get the disk space when users will need it (QoS), so in disk shortage,
you'll need to buy next one. You'll then send an additional bill to them ?

> 
> > Do you mean "pages shared between processes of particular user" ? Where's the problem ?
> > If you mean "pages provided by user to another user", I still don't see the problem...
> >
> > If you mean anonymous pages not owned by any user, I'm really interested why this should
> > be allowed (to let some trash to pollute system resources. Is it common practice ?).
> 
> Well, you're speaking about private pages only.

No.

> I speak about all memory resources, in-core and swap, and all kinds of
> memory, shared and private, file mapped and anonymous.
> 

I don't think it's a problem to associate private memory (or private file map)
with user. Shared memory should have its owner and permissions. Otherwise I don't know
what would be the permissions good for.

Mapped files I didn't considered at all. I thought that they have private swap space 
(the file). So it's not a problem of personal swapfiles. It's a problem of accounting
of physical memory (as I said, I know that this part of MM is much more complicated
and I'm not going to write whole MM myself and from scratch :). I hope that beancounter 
would become more discussed as 2.5 will fork and all the physical memory accounting
problems will be touched then.

So from the point of implementation of personal swapfiles it is important to select
the right swapfile for swapin/swapout. And solve the cases when a page changes owner.
And of course swapon/swapoff. Anything else is in the layer of physical memory 
management.

Can you be more concrete for whose memory objects (swappable) it is a problem
to find owner and why, it would help me a lot (maybe in private e-mail) ? Thanx.

Regards,

Jan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
