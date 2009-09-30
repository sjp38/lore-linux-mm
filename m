Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 129336B004D
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 17:48:15 -0400 (EDT)
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.14.3/8.13.8) with ESMTP id n8UM8egd792328
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 22:08:45 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8UM8UQo1654984
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 23:08:30 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8UM8TRC014208
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 23:08:30 +0100
Message-ID: <4AC3D6DC.9010500@free.fr>
Date: Thu, 01 Oct 2009 00:08:28 +0200
From: Daniel Lezcano <daniel.lezcano@free.fr>
MIME-Version: 1.0
Subject: Re: [PATCH 00/80] Kernel based checkpoint/restart [v18]
References: <1253749920-18673-1-git-send-email-orenl@librato.com>	<20090924154139.2a7dd5ec.akpm@linux-foundation.org>	<20090928163704.GA3327@us.ibm.com> <4AC20BB8.4070509@free.fr>	<87iqf0o5sf.fsf@caffeine.danplanet.com> <4AC38477.4070007@free.fr>	<87eipoo0po.fsf@caffeine.danplanet.com> <4AC39CE5.9080908@free.fr> <877hvgnv6z.fsf@caffeine.danplanet.com>
In-Reply-To: <877hvgnv6z.fsf@caffeine.danplanet.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Smith <danms@us.ibm.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, mingo@elte.hu, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

Dan Smith wrote:
> DL> Yep, I agree. But you didn't answer the question, what are the
> DL> network resources you plan to checkpoint / restart ?  eg. you let
> DL> the container to setup your network, will you restore netdev
> DL> statistics ? the mac address ? ipv4 ? ipv6 ?
>
> Yes, Yes, Yes, and Yes.  I'm making the assumption that the common
> case will be with a veth device in the container and that all of the
> aforementioned attributes should be copied over.  In the future case
> where we could potentially have a real device in the container, it
> probably doesn't make sense to copy the mac address.
>   

Be careful with the assumptions ;)
> DL> Is it possible to do a detailed list of network resources you plan
> DL> to CR with the different items you will address from userspace and
> DL> kernel space ?
>
> I'm sure it's possible, but no, I haven't planned out everything for
> the next year.  If you have strong feelings about what should be done
> in user and kernel space, feel free to share :)
>   

Dan,

I just want to understand what is your plan. If you say "yes I will 
checkpoint / restart" ipv4, ipv6, netdev statistics, etc ...  you should 
be able to give at least a small list of network resources you will 
checkpoint and how you will restart them, no ?

> DL> Argh ! I was hoping there was something else than the source code
>
> The header file makes it pretty clear what is going on, 
Certainly for you.
We are a little far away of the sys_checkpoint / sys_restart simple 
syscalls we talked about at the cr-minisummit in 2008.

Regards,
     -- Daniel



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
