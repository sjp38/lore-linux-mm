Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A80398D0040
	for <linux-mm@kvack.org>; Sat, 26 Mar 2011 17:36:56 -0400 (EDT)
Date: Sat, 26 Mar 2011 16:36:51 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Disable the lockless allocator
In-Reply-To: <20110326195722.GA7748@elte.hu>
Message-ID: <alpine.DEB.2.00.1103261636210.29331@router.home>
References: <20110324185258.GA28370@elte.hu> <alpine.LFD.2.00.1103242005530.31464@localhost6.localdomain6> <20110324192247.GA5477@elte.hu> <AANLkTinBwM9egao496WnaNLAPUxhMyJmkusmxt+ARtnV@mail.gmail.com> <20110326112725.GA28612@elte.hu> <20110326114736.GA8251@elte.hu>
 <1301161507.2979.105.camel@edumazet-laptop> <alpine.DEB.2.00.1103261406420.24195@router.home> <alpine.DEB.2.00.1103261428200.25375@router.home> <alpine.DEB.2.00.1103261440160.25375@router.home> <20110326195722.GA7748@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 26 Mar 2011, Ingo Molnar wrote:

> > Subject: per_cpu: Fixup cmpxchg_double for !SMP
> >
> > cmpxchg_double should only be provided for SMP. In the UP case
> > the GS register is not defined and the function will fail.
> >
> > Signed-off-by: Christoph Lameter <cl@linux.com>
>
> I.e. the bug got introduced by:
>
>  | commit b9ec40af0e18fb7d02106be148036c2ea490fdf9
>  | Author: Christoph Lameter <cl@linux.com>
>  | Date:   Mon Feb 28 11:02:24 2011 +0100
>  |
>  |     percpu, x86: Add arch-specific this_cpu_cmpxchg_double() support
>
> and then the lockless allocator made use of it, right?

Correct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
