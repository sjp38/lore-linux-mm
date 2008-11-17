Date: Mon, 17 Nov 2008 13:31:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Large stack usage in fs code (especially for PPC64)
Message-Id: <20081117133137.616cf287.akpm@linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.0811171320330.18283@nehalem.linux-foundation.org>
References: <alpine.DEB.1.10.0811171508300.8722@gandalf.stny.rr.com>
	<20081117130856.92e41cd3.akpm@linux-foundation.org>
	<alpine.LFD.2.00.0811171320330.18283@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org, paulus@samba.org, benh@kernel.crashing.org, linuxppc-dev@ozlabs.org, mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 17 Nov 2008 13:23:23 -0800 (PST)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> On Mon, 17 Nov 2008, Andrew Morton wrote:
> > 
> > Far be it from me to apportion blame, but THIS IS ALL LINUS'S FAULT!!!!! :)
> > 
> > I fixed this six years ago.  See http://lkml.org/lkml/2002/6/17/68
> 
> Btw, in that thread I also said:
> 
>   "If we have 64kB pages, such architectures will have to have a bigger 
>    kernel stack. Which they will have, simply by virtue of having the very 
>    same bigger page. So that problem kind of solves itself."
> 
> and that may still be the "right" solution - if somebody is so insane that 
> they want 64kB pages, then they might as well have a 64kB kernel stack as 
> well. 

I'd have thought so, but I'm sure we're about to hear how important an
optimisation the smaller stacks are ;)

> Trust me, the kernel stack isn't where you blow your memory with a 64kB 
> page. You blow all your memory on the memory fragmentation of your page 
> cache. I did the stats for the kernel source tree a long time ago, and I 
> think you wasted something like 4GB of RAM with a 64kB page size.
> 

Yup.  That being said, the younger me did assert that "this is a neater
implementation anyway".  If we can implement those loops without
needing those on-stack temporary arrays then things probably are better
overall.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
