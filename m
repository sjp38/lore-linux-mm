Date: Thu, 5 Jun 2008 18:51:04 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 001/001] mmu-notifier-core v17
Message-ID: <20080605165104.GI15502@duo.random>
References: <20080509193230.GH7710@duo.random> <20080516190752.GK11333@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080516190752.GK11333@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>
List-ID: <linux-mm.kvack.org>

On Fri, May 16, 2008 at 12:07:52PM -0700, Paul E. McKenney wrote:
> The hlist_del_init_rcu() primitive looks good.
> 
> The rest of the RCU code looks fine assuming that "mn->ops->release()"
> either does call_rcu() to defer actual removal, or that the actual
> removal is deferred until after mmu_notifier_release() returns.

Yes, actual removal is deferred until after mmu_notifier_release()
returns.

> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Thanks for the review Paul! I should also have added your precious
Acked-by to the 1/3 and 3/3 but the important is the ack by email ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
