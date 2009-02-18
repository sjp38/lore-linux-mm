Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A31656B009D
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 18:16:03 -0500 (EST)
Date: Thu, 19 Feb 2009 00:15:45 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: What can OpenVZ do?
Message-ID: <20090218231545.GA17524@elte.hu>
References: <20090212141014.2cd3d54d.akpm@linux-foundation.org> <20090213105302.GC4608@elte.hu> <1234817490.30155.287.camel@nimitz> <20090217222319.GA10546@elte.hu> <1234909849.4816.9.camel@nimitz> <20090218003217.GB25856@elte.hu> <1234917639.4816.12.camel@nimitz> <20090218051123.GA9367@x200.localdomain> <20090218181644.GD19995@elte.hu> <1234992447.26788.12.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1234992447.26788.12.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, Nathan Lynch <nathanl@austin.ibm.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, hpa@zytor.com, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, tglx@linutronix.de, xemul@openvz.org
List-ID: <linux-mm.kvack.org>


* Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Wed, 2009-02-18 at 19:16 +0100, Ingo Molnar wrote:
> > Nothing motivates more than app designers complaining about the 
> > one-way flag.
> > 
> > Furthermore, it's _far_ easier to make a one-way flag SMP-safe. 
> > We just set it and that's it. When we unset it, what do we about 
> > SMP races with other threads in the same MM installing another 
> > non-linear vma, etc.
> 
> After looking at this for file descriptors, I have to really 
> agree with Ingo on this one, at least as far as the flag is 
> concerned.  I want to propose one teeny change, though: I 
> think the flag should be per-resource.
> 
> We should have one flag in mm_struct, one in files_struct, 
> etc...  The task_is_checkpointable() function can just query 
> task->mm, task->files, etc...  This gives us nice behavior at 
> clone() *and* fork that just works.
> 
> I'll do this for files_struct and see how it comes out so you 
> can take a peek.

Yeah, per resource it should be. That's per task in the normal 
case - except for threaded workloads where it's shared by 
threads.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
