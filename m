Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B560C6B0092
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 15:29:32 -0500 (EST)
Date: Tue, 25 Jan 2011 12:30:05 -0800 (PST)
Message-Id: <20110125.123005.193713229.davem@davemloft.net>
Subject: Re: [PATCH 04/25] sparc: Preemptible mmu_gather
From: David Miller <davem@davemloft.net>
In-Reply-To: <20110125174907.390914415@chello.nl>
References: <20110125173111.720927511@chello.nl>
	<20110125174907.390914415@chello.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: a.p.zijlstra@chello.nl
Cc: aarcange@redhat.com, avi@redhat.com, tglx@linutronix.de, riel@redhat.com, mingo@elte.hu, akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, benh@kernel.crashing.org, hugh.dickins@tiscali.co.uk, mel@csn.ul.ie, npiggin@kernel.dk, paulmck@linux.vnet.ibm.com, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 25 Jan 2011 18:31:15 +0100

> Rework the sparc mmu_gather usage to conform to the new world order :-)
> 
> Sparc mmu_gather does two things:
>  - tracks vaddrs to unhash
>  - tracks pages to free
> 
> Split these two things like powerpc has done and keep the vaddrs
> in per-cpu data structures and flush them on context switch.
> 
> The remaining bits can then use the generic mmu_gather.
> 
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
