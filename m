From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC PATCH 0/2] fast_gup for shared futexes
Date: Fri, 4 Apr 2008 21:56:35 +0200 (CEST)
Message-ID: <alpine.LFD.1.10.0804042154580.3224@apollo.tec.linutronix.de>
References: <20080404193332.348493000@chello.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756214AbYDDT5T@vger.kernel.org>
In-Reply-To: <20080404193332.348493000@chello.nl>
Sender: linux-kernel-owner@vger.kernel.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Eric Dumazet <dada1@cosmosbay.com>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Fri, 4 Apr 2008, Peter Zijlstra wrote:
> Hi,
> 
> this patch series removes mmap_sem from the fast path of shared futexes by
> making use of Nick's recent fast_gup() patches. Full series at:
> 
>   http://programming.kicks-ass.net/kernel-patches/futex-fast_gup/v2.6.24.4-rt4/

Looks good at the first glance. Need to look at the corner cases, but
the code does not really depend on mmap_sem anymore so the chance that
it blows up is pretty low.

Thanks,

	tglx
