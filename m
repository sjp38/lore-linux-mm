Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BC94F8D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 09:47:13 -0500 (EST)
Message-ID: <4D5E86DF.8070805@redhat.com>
Date: Fri, 18 Feb 2011 09:49:03 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: Simplify anon_vma refcounts
References: <20110217161948.045410404@chello.nl>	 <20110217162124.457572646@chello.nl>	 <AANLkTimj1d6QpzuNZ6NJvLDVvvC++mPodggFaBziU8Bj@mail.gmail.com> <1298036683.5226.765.camel@laptop>
In-Reply-To: <1298036683.5226.765.camel@laptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Hugh Dickins <hughd@google.com>

On 02/18/2011 08:44 AM, Peter Zijlstra wrote:
> Subject: mm: Simplify anon_vma refcounts
> From: Peter Zijlstra<a.p.zijlstra@chello.nl>
> Date: Fri, 26 Nov 2010 15:38:49 +0100
>
> This patch changes the anon_vma refcount to be 0 when the object is
> free. It does this by adding 1 ref to being in use in the anon_vma
> structure (iow. the anon_vma->head list is not empty).
>
> This allows a simpler release scheme without having to check both the
> refcount and the list as well as avoids taking a ref for each entry
> on the list.
>
> Reviewed-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Hugh Dickins<hughd@google.com>
> Signed-off-by: Peter Zijlstra<a.p.zijlstra@chello.nl>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
