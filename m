Date: Mon, 4 Feb 2008 11:13:53 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] mmu_notifier: Core code
In-Reply-To: <20080203013323.GA7185@v2.random>
Message-ID: <Pine.LNX.4.64.0802041113130.24187@schroedinger.engr.sgi.com>
References: <20080131045750.855008281@sgi.com> <20080131045812.553249048@sgi.com>
 <20080201035249.GE26420@sgi.com> <Pine.LNX.4.64.0801311957250.17649@schroedinger.engr.sgi.com>
 <20080203013323.GA7185@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Sun, 3 Feb 2008, Andrea Arcangeli wrote:

> On Thu, Jan 31, 2008 at 07:58:40PM -0800, Christoph Lameter wrote:
> > Ok. Andrea wanted the same because then he can void the begin callouts.
> 
> Exactly. I hope the page-pin will avoid me having to serialize the KVM
> page fault against the start/end critical section.
> 
> BTW, I wonder if the start/end critical section API is intended to
> forbid scheduling inside it. In short I wonder if GRU can is allowed
> to take a spinlock in _range_start as last thing before returning, and
> to release that same spinlock in _range_end as first thing, and not to
> be forced to use a mutex.

_begin/end encloses code that may sleep and _begin/_end itself may sleep. 
So a semaphore may work but not a spinlock.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
