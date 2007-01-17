Date: Wed, 17 Jan 2007 10:12:06 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 0/9] VM deadlock avoidance -v10
Message-ID: <20070117091206.GA9845@elf.ucw.cz>
References: <20070116094557.494892000@taijtu.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070116094557.494892000@taijtu.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Hi!

> These patches implement the basic infrastructure to allow swap over networked
> storage.
> 
> The basic idea is to reserve some memory up front to use when regular memory
> runs out.
> 
> To bound network behaviour we accept only a limited number of concurrent 
> packets and drop those packets that are not aimed at the connection(s) servicing
> the VM. Also all network paths that interact with userspace are to be avoided - 
> e.g. taps and NF_QUEUE.
> 
> PF_MEMALLOC is set when processing emergency skbs. This makes sense in that we
> are indeed working on behalf of the swapper/VM. This allows us to use the 
> regular memory allocators for processing but requires that said processing have
> bounded memory usage and has that accounted in the reserve.

How does it work with ARP, for example? You still need to reply to ARP
if you want to keep your ethernet connections.

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
