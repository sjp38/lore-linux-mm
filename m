Subject: Re: [ckrm-tech] [RFC][PATCH 5/8] RSS controller task migration support
Message-Id: <20061117144206.3013D1B6A2@openx4.frec.bull.fr>
Date: Fri, 17 Nov 2006 15:42:06 +0100 (CET)
From: Patrick.Le-Dot@bull.net (Patrick.Le-Dot)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: alan@lxorguk.ukuu.org.uk
Cc: balbir@in.ibm.com, ckrm-tech@lists.sourceforge.net, dev@openvz.org, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rohitseth@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 17 Nov 2006 14:05:13 +0000
> ...
> There are two reasons for wanting memory guarantees
> 
> #1      To be sure a user can't toast the entire box but just their own
>         compartment (eg web hosting)

Well, this seems not a situation to add a guarantee to this user
but a limit...

> ...
> #2      To ensure all apps continue to make progress

or to ensure that a job is ready to work without to have to pay the
cost of a lot of pagination in...


>> If the limit is a "hard limit" then we have implemented reservation and
>> this is too strict.
>
> Thats fundamentally a judgement based on your particular workload and
> constraints.
Nop.
You can read this on the wiki page...

I'm just saying that the implementation of guarantee with limits seems to
be not enough for #2.

> If I am web hosting then I don't generally care if my end
> users compartment blows up under excess load, I care that the other 200
> customers using the box don't suffer and all phone me to complain.

I agree : limit is necessary and should be a "hard limit" (even if the
controler needs an internal threeshold like a "soft limit" to decide to
wakeup the kswapd).
But this is not the topic (not yet:-)

Patrick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
