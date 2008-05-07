Date: Wed, 7 May 2008 15:44:24 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
In-Reply-To: <20080507222205.GC8276@duo.random>
Message-ID: <alpine.LFD.1.10.0805071540300.3024@woody.linux-foundation.org>
References: <6b384bb988786aa78ef0.1210170958@duo.random> <alpine.LFD.1.10.0805071349200.3024@woody.linux-foundation.org> <20080507212650.GA8276@duo.random> <alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org> <20080507222205.GC8276@duo.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>


On Thu, 8 May 2008, Andrea Arcangeli wrote:
> 
> Unfortunately the lock you're talking about would be:
> 
> static spinlock_t global_lock = ...
> 
> There's no way to make it more granular.

Right. So what? 

It's still about a million times faster than what the code does now.

You comment about "great smp scalability optimization" just shows that 
you're a moron. It is no such thing. The fact is, it's a horrible 
pessimization, since even SMP will be *SLOWER*. It will just be "less 
slower" when you have a million CPU's and they all try to do this at the 
same time (which probably never ever happens).

In other words, "scalability" is totally meaningless. The only thing that 
matters is *performance*. If the "scalable" version performs WORSE, then 
it is simply worse. Not better. End of story.

> mmu_notifier_register can take ages. No problem.

So what you're saying is that performance doesn't matter?

So why do you do the ugly crazy hundred-line implementation, when a simple 
two-liner would do equally well?

Your arguments are crap.

Anyway, discussion over. This code doesn't get merged. It doesn't get 
merged before 2.6.26, and it doesn't get merged _after_ either.

Rewrite the code, or not. I don't care. I'll very happily not merge crap 
for the rest of my life.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
