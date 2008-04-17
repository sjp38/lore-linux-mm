Date: Thu, 17 Apr 2008 11:36:42 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 1 of 9] Lock the entire mm to prevent any mmu related
	operation to happen
Message-ID: <20080417163642.GE11364@sgi.com>
References: <patchbomb.1207669443@duo.random> <ec6d8f91b299cf26cce5.1207669444@duo.random> <20080416163337.GJ22493@sgi.com> <Pine.LNX.4.64.0804161134360.12296@schroedinger.engr.sgi.com> <20080417155157.GC17187@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080417155157.GC17187@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, Robin Holt <holt@sgi.com>, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 17, 2008 at 05:51:57PM +0200, Andrea Arcangeli wrote:
> On Wed, Apr 16, 2008 at 11:35:38AM -0700, Christoph Lameter wrote:
> > On Wed, 16 Apr 2008, Robin Holt wrote:
> > 
> > > I don't think this lock mechanism is completely working.  I have
> > > gotten a few failures trying to dereference 0x100100 which appears to
> > > be LIST_POISON1.
> > 
> > How does xpmem unregistering of notifiers work?
> 
> Especially are you using mmu_notifier_unregister?

In this case, we are not making the call to unregister, we are waiting
for the _release callout which has already removed it from the list.

In the event that the user has removed all the grants, we use unregister.
That typically does not occur.  We merely wait for exit processing to
clean up the structures.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
