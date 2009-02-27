Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id ADC896B003D
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 05:46:26 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so572995fgg.4
        for <linux-mm@kvack.org>; Fri, 27 Feb 2009 02:46:24 -0800 (PST)
Date: Fri, 27 Feb 2009 13:53:06 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
	do?
Message-ID: <20090227105306.GB2939@x200.localdomain>
References: <1234467035.3243.538.camel@calx> <20090212114207.e1c2de82.akpm@linux-foundation.org> <1234475483.30155.194.camel@nimitz> <20090212141014.2cd3d54d.akpm@linux-foundation.org> <1234479845.30155.220.camel@nimitz> <20090226162755.GB1456@x200.localdomain> <20090226173302.GB29439@elte.hu> <1235673016.5877.62.camel@bahia> <20090226221709.GA2924@x200.localdomain> <1235726349.4570.7.camel@bahia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1235726349.4570.7.camel@bahia>
Sender: owner-linux-mm@kvack.org
To: Greg Kurz <gkurz@fr.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, viro@zeniv.linux.org.uk, mpm@selenic.com, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, tglx@linutronix.de, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 27, 2009 at 10:19:09AM +0100, Greg Kurz wrote:
> On Fri, 2009-02-27 at 01:17 +0300, Alexey Dobriyan wrote:
> > On Thu, Feb 26, 2009 at 07:30:16PM +0100, Greg Kurz wrote:
> > > On Thu, 2009-02-26 at 18:33 +0100, Ingo Molnar wrote:
> > > > I think the main question is: will we ever find ourselves in the 
> > > > future saying that "C/R sucks, nobody but a small minority uses 
> > > > it, wish we had never merged it"? I think the likelyhood of that 
> > > > is very low. I think the current OpenVZ stuff already looks very 
> > > 
> > > We've been maintaining for some years now a C/R middleware with only a
> > > few hooks in the kernel. Our strategy is to leverage existing kernel
> > > paths as they do most of the work right.
> > > 
> > > Most of the checkpoint is performed from userspace, using regular
> > > syscalls in a signal handler or /proc parsing. Restart is a bit trickier
> > > and needs some kernel support to bypass syscall checks and enforce a
> > > specific id for a resource. At the end, we support C/R and live
> > > migration of networking apps (websphere application server for example).
> > > 
> > > >From our experience, we can tell:
> > > 
> > > Pros: mostly not-so-tricky userland code, independent from kernel
> > > internals
> > > Cons: sub-optimal for some resources
> > 
> > How do you restore struct task_struct::did_exec ?
> 
> With sys_execve().

How do you restore set of uts_namespace's? Kernel never exposes to
userspace which are the same, which are independent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
