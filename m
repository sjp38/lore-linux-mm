Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 098086B008A
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 12:03:03 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.1/8.13.1) with ESMTP id n8UGGul8012994
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 16:16:56 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8UGGtZ43158108
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 18:16:55 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8UGGtKJ022860
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 18:16:55 +0200
Message-ID: <4AC38477.4070007@free.fr>
Date: Wed, 30 Sep 2009 18:16:55 +0200
From: Daniel Lezcano <daniel.lezcano@free.fr>
MIME-Version: 1.0
Subject: Re: [PATCH 00/80] Kernel based checkpoint/restart [v18]
References: <1253749920-18673-1-git-send-email-orenl@librato.com>	<20090924154139.2a7dd5ec.akpm@linux-foundation.org>	<20090928163704.GA3327@us.ibm.com> <4AC20BB8.4070509@free.fr> <87iqf0o5sf.fsf@caffeine.danplanet.com>
In-Reply-To: <87iqf0o5sf.fsf@caffeine.danplanet.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Smith <danms@us.ibm.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, mingo@elte.hu, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

Dan Smith wrote:
> DL> Ok for the restart, but for the checkpoint, how do you access the
> DL> network setup from a process which belongs to another namespace
> DL> context ?
>
> So far the discussion has led to the kernel dumping all of that
> information on checkpoint, and then splitting it up into what can be
> done by userspace on restart and what still needs to be in the kernel.
>   
Ah, this was a discussion in the containers@ mailing list ?
Sorry I missed it, I will look at the containers@ archives.

If the checkpoint is done from the kernel, why the restart wouldn't be 
in the kernel too ?
Do you have a list of what is restartable from userspace or from the 
kernel ?

Is there any documentation about the statefile format I can use if I 
want to implement myself an userspace CR solution based on this kernel 
patchset ?
> Similarly, the task structure is currently exported by the kernel on
> checkpoint, but recreated in userspace on restart.
>   
(I guess you meant tasks hierarchy/tree) Well I understand why this is 
done from userspace but I don't like the idea of digging in the 
statefile, but there's no accounting for taste :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
