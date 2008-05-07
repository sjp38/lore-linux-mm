Date: Wed, 7 May 2008 18:20:07 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 02 of 11] get_task_mm
Message-ID: <20080507162006.GB18260@duo.random>
References: <patchbomb.1210170950@duo.random> <c5badbefeee07518d9d1.1210170952@duo.random> <20080507155948.GO18857@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080507155948.GO18857@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2008 at 10:59:48AM -0500, Robin Holt wrote:
> You can drop this patch.
> 
> This turned out to be a race in xpmem.  It "appeared" as if it were a
> race in get_task_mm, but it really is not.  The current->mm field is
> cleared under the task_lock and the task_lock is grabbed by get_task_mm.

100% agreed, I'll nuke it as it seems really a noop.

> I have been testing you v15 version without this patch and not
> encountere the problem again (now that I fixed my xpmem race).

Great. About your other deadlock I'm curious if my deadlock fix for
the i_mmap_sem patch helped. That was crashing kvm with a VM 2G in the
swap + a swaphog allocating and freeing another 2G of swap in a
loop. I couldn't reproduce any other problem with KVM since I fixed
that bit regardless if I apply only mmu-notifier-core (2.6.26 version)
or the full patchset (post 2.6.26).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
