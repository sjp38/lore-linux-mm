Date: Sat, 26 Jul 2008 15:49:15 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: MMU notifiers review and some proposals
Message-ID: <20080726134915.GD9598@duo.random>
References: <20080724143949.GB12897@wotan.suse.de> <20080725214552.GB21150@duo.random> <20080726030810.GA18896@wotan.suse.de> <20080726113813.GD21150@duo.random> <20080726122826.GA17958@wotan.suse.de> <20080726130202.GA9598@duo.random> <20080726131450.GC21820@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080726131450.GC21820@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, steiner@sgi.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 26, 2008 at 03:14:50PM +0200, Nick Piggin wrote:
> BTW. has anyone else actually looked at mmu notifiers or have an
> opinion on this? It might be helpful for me to get someone else's
> perspective.

My last submission was for -mm on 26 Jun, and all these developers and
lists were in CC:

	Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Christoph Lameter <clameter@sgi.com>,
        Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>,
        Nick Piggin <npiggin@suse.de>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm@vger.kernel.org,
        Kanoj Sarcar <kanojsarcar@yahoo.com>,
        Roland Dreier <rdreier@cisco.com>,
        Steve Wise <swise@opengridcomputing.com>,
        linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>,
        linux-mm@kvack.org, general@lists.openfabrics.org,
        Hugh Dickins <hugh@veritas.com>,
        Rusty Russell <rusty@rustcorp.com.au>,
        Anthony Liguori <aliguori@us.ibm.com>,
        Chris Wright <chrisw@redhat.com>,
        Marcelo Tosatti <marcelo@kvack.org>,
        Eric Dumazet <dada1@cosmosbay.com>,
        "Paul E. McKenney" <paulmck@us.ibm.com>,
        Izik Eidus <izike@qumranet.com>,
        Anthony Liguori <aliguori@us.ibm.com>,
        Rik van Riel <riel@redhat.com>

The ones explicitly agreeing (about all or part depending on the areas
of interest, and not just of the first patch adding the new list.h
function which is mostly unrelated) were Linus, Christoph, Jack,
Robin, Avi, Marcelo, Rik and last but not the least Paul.

Everyone else in the list implicitly agrees I assume, hope they're not
all waiting 1 month before commenting on it like you did ;).

Avi, me, Jack and Robin are the main users of the feature (or at least
the main users that are brave enough to be visible on lkml) so that
surely speaks well for the happiness of the mmu notifier users about
what is in -mm. Infact it is almost a sure thing that the users will
always prefer the current patches compared to the minimal notifier.

But I also wear a VM (as in virtual memory not virtual machine ;) hat
not just a KVM hat, so I surely wouldn't have submitted something that
I think is bad for the VM. Infact I opposed certain patches made
specifically for XPMEM that could hurt the VM a micro-bit (mostly
thinking at UP cellphones). Still I offered to support XPMEM but with
a lower priority and done right.

I don't happen to dislike mm_take_all_locks, as it's totally localized
and _can_never_run_ unless you load one of those kvm or gru
modules. I'd rather prefer mmu notifiers to be invisible to the
tlb-gather logic, surely it'd be orders of magnitude simpler to delete
mm_take_all_locks than to undo the changes to the tlb-gather logic. So
if something we should go with -mm first, and then evaluate if the
tlb-gather changes are better/worse.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
