Message-ID: <20000828211026.D6043@saw.sw.com.sg>
Date: Mon, 28 Aug 2000 21:10:26 +0800
From: Andrey Savochkin <saw@saw.sw.com.sg>
Subject: Re: Question: memory management and QoS
References: <39A672FD.CEEA798C@asplinux.ru> <39A69617.CE4719EF@tuke.sk> <39A6D45D.6F4C3E2F@asplinux.ru> <39AA24A5.CB461F4E@tuke.sk> <20000828190557.A5579@saw.sw.com.sg> <39AA56D1.EC5635D3@tuke.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <39AA56D1.EC5635D3@tuke.sk>; from "Jan Astalos" on Mon, Aug 28, 2000 at 02:10:57PM
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Astalos <astalos@tuke.sk>
Cc: Yuri Pudgorodsky <yur@asplinux.ru>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 28, 2000 at 02:10:57PM +0200, Jan Astalos wrote:
> Andrey Savochkin wrote:
[snip]
> > 
> > That's what user beancounter patch is about.
> > Except that I'm not so strong in the judgements.
> > For example, I don't think that overcommits are evil.  They are quite ok if
> 
> Did you ever asked your users ? Whether they like to see their apps (possibly running
> for quite a long time) to be killed (no matter whether with or without warning) ?

Well, I was the person responsible for the work of servers (HTTP, FTP, mail,
proxy, statistic and accounting etc).
Yes, I want some applications to be killed under certain conditions.

> 
> > 1. the system can provide guarantee that certain processes can never be
> >    killed because of OOM;
> 
> Again. I wonder how beancounter would prevent overcommit of virtual memory if you don't
> set limits...

It doesn't prevent overcommit.
And it doesn't prevent out-of-memory situations.
It prevents processes that stays below preconfigured threshold to face
negative consequences of overcommits, OOM or whatever else.
If OOM happens then _someone_ is over the threshold, and this very one will
face the consequences.

You propose exactly the same: user whose swap file ends is the only one who
faces problems.  The difference is that with my code he likely avoids
problems if some other user doesn't consumed all his resources.
What you propose is just punish the user unconditionally, even if there are
some spare resources...

> 
> > 2. the whole system reaction to OOM situation is well predictable.
> > It's a part of quality of service: some processes/groups of processes have
> > better service, some others only best effort.
> 
> I wont repeat it again. With personal swapfiles _all_ users would be guarantied
> to get the amount of virtual memory provided by _themselves_.

Yes, personal swapfiles solve this problem, too.
They are just a waste of resources, to be very frank.

[snip]
> As a user, I won't bear _any_ overcommits at all. Once service is paid, I expect
> guarantied level of quality. In the case of VM, all the memory I paid for.
> For all of my processes.

It means that you pay orders of magnitude more for it.

> Do you mean "pages shared between processes of particular user" ? Where's the problem ?
> If you mean "pages provided by user to another user", I still don't see the problem...
> 
> If you mean anonymous pages not owned by any user, I'm really interested why this should
> be allowed (to let some trash to pollute system resources. Is it common practice ?).

Well, you're speaking about private pages only.
I speak about all memory resources, in-core and swap, and all kinds of
memory, shared and private, file mapped and anonymous.

Regards
					Andrey V.
					Savochkin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
