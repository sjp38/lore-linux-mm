Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A820D6B003D
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 10:24:00 -0500 (EST)
Date: Wed, 11 Feb 2009 16:23:42 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Using module private memory to simulate microkernel's memory
	protection
Message-ID: <20090211152342.GA16550@elte.hu>
References: <a5f59d880902100542x7243b13fuf40e7dd21faf7d7a@mail.gmail.com> <20090210141405.GA16147@elte.hu> <a5f59d880902110604g40cf17b5w92431f60e6f16fa4@mail.gmail.com> <20090211145525.GB10525@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090211145525.GB10525@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Pengfei Hu <hpfei.cn@gmail.com>
Cc: Vegard Nossum <vegard.nossum@gmail.com>, akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> * Pengfei Hu <hpfei.cn@gmail.com> wrote:
> 
> > >
> > > Hm, are you aware of the kmemcheck project?
> > >
> > >        Ingo
> > >
> > 
> > Frankly, I only know this project's name. Just when I nearly finished
> > this patch, I browsed http://git.kernel.org/ first time. I am only a
> > beginner in Linux kernel. Maybe I should first discuss before write
> > code. But I think it is not too late.
> > 
> > Can you tell me more about this project? I realy appreciate it.
> 
> Sure:

More info: kmemcheck was written by Vegard Nossum (and released more than
a year ago) and it uses similar principles as your patch: it enforces
memory usage constraints via pagetable access bits.

More description about kmemcheck can be found in the following LWN article:

  http://lwn.net/Articles/260068/

I think your idea of limiting execution to individual modules could perhaps
be combined with kmemcheck. It's the same general principle.

The difference is that your patch calls back from the page fault handler and
modifies the monitored pte's to present, brings in a TLB and then it modifies
it to not present. So the page can be accessed up until the TLB gets flushed.

Kmemcheck uses debug traps to execute a single instruction, and thus gets
finer grained control of what is visible to a task.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
