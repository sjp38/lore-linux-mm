Date: Wed, 7 May 2008 13:56:23 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
In-Reply-To: <6b384bb988786aa78ef0.1210170958@duo.random>
Message-ID: <alpine.LFD.1.10.0805071349200.3024@woody.linux-foundation.org>
References: <6b384bb988786aa78ef0.1210170958@duo.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>


On Wed, 7 May 2008, Andrea Arcangeli wrote:
> 
> Convert the anon_vma spinlock to a rw semaphore. This allows concurrent
> traversal of reverse maps for try_to_unmap() and page_mkclean(). It also
> allows the calling of sleeping functions from reverse map traversal as
> needed for the notifier callbacks. It includes possible concurrency.

This also looks very debatable indeed. The only performance numbers quoted 
are:

>   This results in f.e. the Aim9 brk performance test to got down by 10-15%.

which just seems like a total disaster.

The whole series looks bad, in fact. Lack of authorship, bad single-line 
description, and the code itself sucks so badly that it's not even funny.

NAK NAK NAK. All of it. It stinks.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
