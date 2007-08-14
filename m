Date: Tue, 14 Aug 2007 14:15:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 4/9] Atomic reclaim: Save irq flags in vmscan.c
In-Reply-To: <20070814204454.GC22202@one.firstfloor.org>
Message-ID: <Pine.LNX.4.64.0708141414260.31693@schroedinger.engr.sgi.com>
References: <20070814153021.446917377@sgi.com> <20070814153501.766137366@sgi.com>
 <p73vebhnauo.fsf@bingen.suse.de> <Pine.LNX.4.64.0708141209270.29498@schroedinger.engr.sgi.com>
 <20070814203329.GA22202@one.firstfloor.org>
 <Pine.LNX.4.64.0708141341120.31513@schroedinger.engr.sgi.com>
 <20070814204454.GC22202@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 Aug 2007, Andi Kleen wrote:

> > Hmmmm... The spinlock is its own flag.
> 
> Yes, but it's not CPU local. Taking the spinlock from another CPU's
> interrupt handler is perfectly safe, just not from the local CPU.
> If you use the spinlock as flag you would need to lock out everybody.

So every spinlock would have an array of chars sized to NR_CPUS and set 
the flag when the lock is taken?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
