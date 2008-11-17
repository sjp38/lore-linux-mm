Date: Mon, 17 Nov 2008 13:23:23 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Large stack usage in fs code (especially for PPC64)
In-Reply-To: <20081117130856.92e41cd3.akpm@linux-foundation.org>
Message-ID: <alpine.LFD.2.00.0811171320330.18283@nehalem.linux-foundation.org>
References: <alpine.DEB.1.10.0811171508300.8722@gandalf.stny.rr.com> <20081117130856.92e41cd3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, linux-kernel@vger.kernel.org, paulus@samba.org, benh@kernel.crashing.org, linuxppc-dev@ozlabs.org, mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 17 Nov 2008, Andrew Morton wrote:
> 
> Far be it from me to apportion blame, but THIS IS ALL LINUS'S FAULT!!!!! :)
> 
> I fixed this six years ago.  See http://lkml.org/lkml/2002/6/17/68

Btw, in that thread I also said:

  "If we have 64kB pages, such architectures will have to have a bigger 
   kernel stack. Which they will have, simply by virtue of having the very 
   same bigger page. So that problem kind of solves itself."

and that may still be the "right" solution - if somebody is so insane that 
they want 64kB pages, then they might as well have a 64kB kernel stack as 
well. 

Trust me, the kernel stack isn't where you blow your memory with a 64kB 
page. You blow all your memory on the memory fragmentation of your page 
cache. I did the stats for the kernel source tree a long time ago, and I 
think you wasted something like 4GB of RAM with a 64kB page size.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
