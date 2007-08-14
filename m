Date: Wed, 15 Aug 2007 00:21:50 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 4/9] Atomic reclaim: Save irq flags in vmscan.c
Message-ID: <20070814222150.GI23308@one.firstfloor.org>
References: <20070814212355.GA23308@one.firstfloor.org> <Pine.LNX.4.64.0708141425000.31693@schroedinger.engr.sgi.com> <20070814212955.GC23308@one.firstfloor.org> <Pine.LNX.4.64.0708141436380.31693@schroedinger.engr.sgi.com> <20070814214430.GD23308@one.firstfloor.org> <Pine.LNX.4.64.0708141444590.32110@schroedinger.engr.sgi.com> <20070814215659.GF23308@one.firstfloor.org> <Pine.LNX.4.64.0708141504350.32420@schroedinger.engr.sgi.com> <20070814221616.GG23308@one.firstfloor.org> <Pine.LNX.4.64.0708141517340.32624@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708141517340.32624@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Ok I have a vague idea on how this could but its likely that the 
> changes make things worse rather than better. Additional reference to a 
> new cacheline (per cpu but still), preempt disable. Lots of code at all
> call sites. Interrupt enable/disable is quite efficient in recent 
> processors.

The goal of this was not to be faster than interrupt disable,
but to avoid the interrupt latency impact. This might be a problem
when spending a lot of time inside the locks.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
