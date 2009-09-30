Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7216B004D
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 13:45:26 -0400 (EDT)
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate4.uk.ibm.com (8.14.3/8.13.8) with ESMTP id n8UI1P0x026376
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 18:01:30 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8UI19CR2588794
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 19:01:15 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8UI182r030578
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 19:01:09 +0100
Message-ID: <4AC39CE5.9080908@free.fr>
Date: Wed, 30 Sep 2009 20:01:09 +0200
From: Daniel Lezcano <daniel.lezcano@free.fr>
MIME-Version: 1.0
Subject: Re: [PATCH 00/80] Kernel based checkpoint/restart [v18]
References: <1253749920-18673-1-git-send-email-orenl@librato.com>	<20090924154139.2a7dd5ec.akpm@linux-foundation.org>	<20090928163704.GA3327@us.ibm.com> <4AC20BB8.4070509@free.fr>	<87iqf0o5sf.fsf@caffeine.danplanet.com> <4AC38477.4070007@free.fr> <87eipoo0po.fsf@caffeine.danplanet.com>
In-Reply-To: <87eipoo0po.fsf@caffeine.danplanet.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Smith <danms@us.ibm.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, mingo@elte.hu, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

Dan Smith wrote:
> DL> If the checkpoint is done from the kernel, why the restart
> DL> wouldn't be in the kernel too ?
>
> I think thus far we have taken the approach of "if it can be done
> reasonably in userspace, then do it there" right?  
Well I am a little lost :)
The tty CR can be "reasonably" done in userspace I think. But it was 
done in the kernel, no ?

> Setup of the
> network devices is easy to do in userspace, allows more flexibility
> from a policy standpoint, and ensures that all existing security
> checks are performed. 
Yep, I agree. But you didn't answer the question, what are the network 
resources you plan to checkpoint / restart ?
eg. you let the container to setup your network, will you restore netdev 
statistics ? the mac address ? ipv4 ? ipv6 ?

Is it possible to do a detailed list of network resources you plan to CR 
with the different items you will address from userspace and kernel space ?

> Also, migration may be easier if the userspace
> bits can call custom hooks allowing for routing changes and other
> infrastructure-specific operations.
>   
You may have some problems with the connected sockets you will restore 
in this case.

> DL> Is there any documentation about the statefile format I can use if
> DL> I want to implement myself an userspace CR solution based on this
> DL> kernel patchset ?
>
> See linux-cr/include/linux/checkpoint_hdr.h and user-cr/restart.c.
>   
Argh ! I was hoping there was something else than the source code :)

Thanks
  -- Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
