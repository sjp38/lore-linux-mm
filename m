Date: Wed, 23 Apr 2008 20:19:28 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
Message-ID: <20080423181928.GI24536@duo.random>
References: <ea87c15371b1bd49380c.1208872277@duo.random> <Pine.LNX.4.64.0804221315160.3640@schroedinger.engr.sgi.com> <20080422223545.GP24536@duo.random> <20080422230727.GR30298@sgi.com> <20080423133619.GV24536@duo.random> <20080423144747.GU30298@sgi.com> <20080423155940.GY24536@duo.random> <Pine.LNX.4.64.0804231105090.12373@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804231105090.12373@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 11:09:35AM -0700, Christoph Lameter wrote:
> Why is there still the hlist stuff being used for the mmu notifier list? 
> And why is this still unsafe?

What's the problem with hlist, it saves 8 bytes for each mm_struct,
you should be using it too instead of list.

> There are cases in which you do not take the reverse map locks or mmap_sem
> while traversing the notifier list?

There aren't.

> This hope for inclusion without proper review (first for .25 now for .26) 
> seems to interfere with the patch cleanup work and cause delay after delay 
> for getting the patch ready. On what basis do you think that there is a 
> chance of any of these patches making it into 2.6.26 given that this 
> patchset has never been vetted in Andrew's tree?

Let's say I try to be optimistic and hope the right thing will happen
given this is like a new driver that can't hurt anybody but KVM and
GRU if there's any bug. But in my view what interfere with proper
review for .26 are the endless discussions we're doing ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
