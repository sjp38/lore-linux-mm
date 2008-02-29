Date: Fri, 29 Feb 2008 13:29:22 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address ranges
In-Reply-To: <20080229212327.GC8091@v2.random>
Message-ID: <Pine.LNX.4.64.0802291325580.13402@schroedinger.engr.sgi.com>
References: <20080228005249.GF8091@v2.random>
 <Pine.LNX.4.64.0802271702490.16510@schroedinger.engr.sgi.com>
 <20080228011020.GG8091@v2.random> <Pine.LNX.4.64.0802281043430.29191@schroedinger.engr.sgi.com>
 <20080229005530.GO8091@v2.random> <Pine.LNX.4.64.0802281658560.1954@schroedinger.engr.sgi.com>
 <20080229131302.GT8091@v2.random> <Pine.LNX.4.64.0802291149290.11292@schroedinger.engr.sgi.com>
 <20080229201744.GB8091@v2.random> <Pine.LNX.4.64.0802291301530.11889@schroedinger.engr.sgi.com>
 <20080229212327.GC8091@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, 29 Feb 2008, Andrea Arcangeli wrote:

> I don't have a strong opinion if it should become a semaphore
> unconditionally or only with a CONFIG_XPMEM=y. But keep in mind
> preempt-rt runs quite a bit slower, or we could rip spinlocks out of
> the kernel in the first place ;)

D you just skip comments of people on the mmu_notifier? It took me to 
remind you about Andrew's comments to note those. And I just responded on 
the XPmem issue in the morning.
 
Again for the gazillionth time: There will be no CONFIG_XPMEM because the 
functionality needs to be generic and not XPMEM specific.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
