Date: Wed, 7 May 2008 23:26:50 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080507212650.GA8276@duo.random>
References: <6b384bb988786aa78ef0.1210170958@duo.random> <alpine.LFD.1.10.0805071349200.3024@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0805071349200.3024@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2008 at 01:56:23PM -0700, Linus Torvalds wrote:
> This also looks very debatable indeed. The only performance numbers quoted 
> are:
> 
> >   This results in f.e. the Aim9 brk performance test to got down by 10-15%.
> 
> which just seems like a total disaster.
> 
> The whole series looks bad, in fact. Lack of authorship, bad single-line 

Glad you agree. Note that the fact the whole series looks bad, is
_exactly_ why I couldn't let Christoph keep going with
mmu-notifier-core at the very end of his patchset. I had to move it at
the top to have a chance to get the KVM and GRU requirements merged
in 2.6.26.

I think the spinlock->rwsem conversion is ok under config option, as
you can see I complained myself to various of those patches and I'll
take care they're in a mergeable state the moment I submit them. What
XPMEM requires are different semantics for the methods, and we never
had to do any blocking I/O during vmtruncate before, now we have to.
And I don't see a problem in making the conversion from
spinlock->rwsem only if CONFIG_XPMEM=y as I doubt XPMEM works on
anything but ia64.

Please ignore all patches but mmu-notifier-core. I regularly forward
_only_ mmu-notifier-core to Andrew, that's the only one that is in
merge-ready status, everything else is just so XPMEM can test and we
can keep discussing it to bring it in a mergeable state like
mmu-notifier-core already is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
