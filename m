Date: Wed, 23 Apr 2008 18:15:45 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 04 of 12] Moves all mmu notifier methods outside the PT
	lock (first and not last
Message-ID: <20080423161544.GZ24536@duo.random>
References: <ac9bb1fb3de2aa5d2721.1208872280@duo.random> <Pine.LNX.4.64.0804221323510.3640@schroedinger.engr.sgi.com> <20080422224048.GR24536@duo.random> <Pine.LNX.4.64.0804221613570.4868@schroedinger.engr.sgi.com> <20080423134427.GW24536@duo.random> <20080423154536.GV30298@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423154536.GV30298@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 10:45:36AM -0500, Robin Holt wrote:
> XPMEM has passed all regression tests using your version 12 notifiers.

That's great news, thanks! I'd greatly appreciate if you could test
#v13 too as I posted it. It already passed GRU and KVM regressions
tests and it should work fine for XPMEM too. You can ignore the purely
cosmetical error I managed to introduce in mm_lock_cmp (I implemented
a BUG_ON that would have trigger if that wasn't a purely cosmetical
issue, and it clearly doesn't trigger so you can be sure it's
only cosmetical ;).

Once I get confirmation that everyone is ok with #v13 I'll push a #v14
before Saturday with that cosmetical error cleaned up and
mmu_notifier_unregister moved at the end (XPMEM will have unregister
don't worry). I expect the 1/13 of #v14 to go in -mm and then 2.6.26.

> I have a bug in xpmem which shows up on our 8x oversubscription tests,
> but that is clearly my bug to figure out.  Unfortunately it only shows

This is what I meant.

As opposed we don't have any known bug left in this area, infact we
need mmu_notifiers to _fix_ issues I identified that can't be fixed
efficiently without mmu notifiers, and we need the mmu notifier to go
productive ASAP.

> up on a 128 processor machine so I have 1024 stack traces to sort
> through each time it fails.  Does take a bit of time and a lot of
> concentration.

Sure, hope you find it soon!

> SGI is under an equally strict timeline.  We really needed the sleeping
> version into 2.6.26.  We may still be able to get this accepted by
> vendor distros if we make 2.6.27.

I don't think vendor distro are less likely to take the patches 2-12
if 1/N (aka mmu-notifier-core) is merged in 2.6.26 especially at the
light of kabi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
