Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7BBE88D0001
	for <linux-mm@kvack.org>; Sat, 27 Nov 2010 05:33:24 -0500 (EST)
Date: Sat, 27 Nov 2010 21:33:19 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: [PATCH 02/21] powerpc: Use call_rcu_sched() for pagetables
Message-ID: <20101127103319.GA6830@amd>
References: <20101126143843.801484792@chello.nl>
 <20101126145410.373743450@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101126145410.373743450@chello.nl>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Can this go through powerpc tree as a bugfix?

On Fri, Nov 26, 2010 at 03:38:45PM +0100, Peter Zijlstra wrote:
> PowerPC relies on IRQ-disable to guard against RCU quiecent states,
> use the appropriate RCU call version.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
