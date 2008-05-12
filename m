Date: Mon, 12 May 2008 15:01:13 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH 001/001] mmu-notifier-core v17
Message-ID: <20080512200113.GA31862@sgi.com>
References: <20080509193230.GH7710@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080509193230.GH7710@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, May 09, 2008 at 09:32:30PM +0200, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <andrea@qumranet.com>
> 
> With KVM/GFP/XPMEM there isn't just the primary CPU MMU pointing to
> pages. There are secondary MMUs (with secondary sptes and secondary
> tlbs) too. sptes in the kvm case are shadow pagetables, but when I say
> spte in mmu-notifier context, I mean "secondary pte". In GRU case
> there's no actual secondary pte and there's only a secondary tlb
> because the GRU secondary MMU has no knowledge about sptes and every
> secondary tlb miss event in the MMU always generates a page fault that
> has to be resolved by the CPU (this is not the case of KVM where the a
> secondary tlb miss will walk sptes in hardware and it will refill the
>...

FYI, I applied to patch to a tree that has the GRU driver. All regression
tests passed.

--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
