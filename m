Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DA7A16B003D
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 04:19:18 -0500 (EST)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.14.3/8.13.8) with ESMTP id n1R9JAm7118030
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 09:19:10 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n1R9JAxR753768
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 10:19:10 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1R9JAj6007826
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 10:19:10 +0100
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
 do?
From: Greg Kurz <gkurz@fr.ibm.com>
In-Reply-To: <20090226221709.GA2924@x200.localdomain>
References: <20090211141434.dfa1d079.akpm@linux-foundation.org>
	 <1234462282.30155.171.camel@nimitz> <1234467035.3243.538.camel@calx>
	 <20090212114207.e1c2de82.akpm@linux-foundation.org>
	 <1234475483.30155.194.camel@nimitz>
	 <20090212141014.2cd3d54d.akpm@linux-foundation.org>
	 <1234479845.30155.220.camel@nimitz>
	 <20090226162755.GB1456@x200.localdomain> <20090226173302.GB29439@elte.hu>
	 <1235673016.5877.62.camel@bahia>  <20090226221709.GA2924@x200.localdomain>
Content-Type: text/plain
Date: Fri, 27 Feb 2009 10:19:09 +0100
Message-Id: <1235726349.4570.7.camel@bahia>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, viro@zeniv.linux.org.uk, mpm@selenic.com, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, tglx@linutronix.de, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-02-27 at 01:17 +0300, Alexey Dobriyan wrote:
> On Thu, Feb 26, 2009 at 07:30:16PM +0100, Greg Kurz wrote:
> > On Thu, 2009-02-26 at 18:33 +0100, Ingo Molnar wrote:
> > > I think the main question is: will we ever find ourselves in the 
> > > future saying that "C/R sucks, nobody but a small minority uses 
> > > it, wish we had never merged it"? I think the likelyhood of that 
> > > is very low. I think the current OpenVZ stuff already looks very 
> > 
> > We've been maintaining for some years now a C/R middleware with only a
> > few hooks in the kernel. Our strategy is to leverage existing kernel
> > paths as they do most of the work right.
> > 
> > Most of the checkpoint is performed from userspace, using regular
> > syscalls in a signal handler or /proc parsing. Restart is a bit trickier
> > and needs some kernel support to bypass syscall checks and enforce a
> > specific id for a resource. At the end, we support C/R and live
> > migration of networking apps (websphere application server for example).
> > 
> > >From our experience, we can tell:
> > 
> > Pros: mostly not-so-tricky userland code, independent from kernel
> > internals
> > Cons: sub-optimal for some resources
> 
> How do you restore struct task_struct::did_exec ?

With sys_execve().

-- 
Gregory Kurz                                     gkurz@fr.ibm.com
Software Engineer @ IBM/Meiosys                  http://www.ibm.com
Tel +33 (0)534 638 479                           Fax +33 (0)561 400 420

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
