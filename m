Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 658D46B0087
	for <linux-mm@kvack.org>; Sun, 28 Nov 2010 21:59:15 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAT2xC6C006313
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 29 Nov 2010 11:59:12 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E4FA45DE67
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 11:59:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A7CE45DE55
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 11:59:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D8B01DB803B
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 11:59:12 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EAD241DB8040
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 11:59:11 +0900 (JST)
Date: Mon, 29 Nov 2010 11:53:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 08/21] mm: Preemptible mmu_gather
Message-Id: <20101129115324.31cc9005.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101126145410.712834114@chello.nl>
References: <20101126143843.801484792@chello.nl>
	<20101126145410.712834114@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Tony Luck <tony.luck@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, 26 Nov 2010 15:38:51 +0100
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Make mmu_gather preemptible by using a small on stack list and use
> an option allocation to speed things up.
> 
> Preemptible mmu_gather is desired in general and usable once
> i_mmap_lock becomes a mutex. Doing it before the mutex conversion
> saves us from having to rework the code by moving the mmu_gather
> bits inside the i_mmap_lock.
> 
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: David Miller <davem@davemloft.net>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Russell King <rmk@arm.linux.org.uk>
> Cc: Paul Mundt <lethal@linux-sh.org>
> Cc: Jeff Dike <jdike@addtoit.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Interesting, Hmm, how about using the 1st freed pages as tlb->pages
rathet than calling alloc_page() ? no benefits ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
