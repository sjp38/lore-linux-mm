Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m9MBtkcI329658
	for <linux-mm@kvack.org>; Wed, 22 Oct 2008 11:55:46 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9MBtkxd2703550
	for <linux-mm@kvack.org>; Wed, 22 Oct 2008 13:55:46 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9MBtjHI024443
	for <linux-mm@kvack.org>; Wed, 22 Oct 2008 13:55:45 +0200
Message-ID: <48FF14BA.6050807@fr.ibm.com>
Date: Wed, 22 Oct 2008 13:55:38 +0200
From: Cedric Le Goater <clg@fr.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC v7][PATCH 0/9] Kernel based checkpoint/restart
References: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu> <20081021122135.4bce362c.akpm@linux-foundation.org> <1224621667.1848.228.camel@nimitz> <20081022092024.GC12453@elte.hu>
In-Reply-To: <20081022092024.GC12453@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Oren Laadan <orenl@cs.columbia.edu>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, hpa@zytor.com, tglx@linutronix.de, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> 
>> On Tue, 2008-10-21 at 12:21 -0700, Andrew Morton wrote:
>>> On Mon, 20 Oct 2008 01:40:28 -0400
>>> Oren Laadan <orenl@cs.columbia.edu> wrote:
>>>> These patches implement basic checkpoint-restart [CR]. This version
>>>> (v7) supports basic tasks with simple private memory, and open files
>>>> (regular files and directories only).
>>> - how useful is this code as it stands in real-world usage?
>> Right now, an application must be specifically written to use these 
>> mew system calls.  It must be a single process and not share any 
>> resources with other processes.  The only file descriptors that may be 
>> open are simple files and may not include sockets or pipes.
>>
>> What this means in practice is that it is useful for a simple app 
>> doing computational work.
> 
> say a chemistry application doing calculations. Or a raytracer with a 
> large job. Both can take many hours (days!) even on very fast machine 

even weeks in the EDA and Petroleum geophysics.

> and the restrictions on rebootability can hurt in such cases.

yes, indeed. 

These industries also like to be able to schedule high priority jobs
needing the full power of their clusters: checkpoint running jobs,
schedule a high priority one, restart the previous.

> You should reach a minimal level of initial practical utility: say some 
> helper tool that allows testers to checkpoint and restore a real PovRay 
> session - without any modification to a stock distro PovRay.

Supporting Povray is a good target. many HPC applications have the same 
resource  scope.  

C.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
