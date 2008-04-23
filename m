Date: Wed, 23 Apr 2008 15:36:19 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
Message-ID: <20080423133619.GV24536@duo.random>
References: <ea87c15371b1bd49380c.1208872277@duo.random> <Pine.LNX.4.64.0804221315160.3640@schroedinger.engr.sgi.com> <20080422223545.GP24536@duo.random> <20080422230727.GR30298@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080422230727.GR30298@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 22, 2008 at 06:07:27PM -0500, Robin Holt wrote:
> > The only other change I did has been to move mmu_notifier_unregister
> > at the end of the patchset after getting more questions about its
> > reliability and I documented a bit the rmmod requirements for
> > ->release. we'll think later if it makes sense to add it, nobody's
> > using it anyway.
> 
> XPMEM is using it.  GRU will be as well (probably already does).

XPMEM requires more patches anyway. Note that in previous email you
told me you weren't using it. I think GRU can work fine on 2.6.26
without mmu_notifier_unregister, like KVM too. You've simply to unpin
the module count in ->release. The most important bit is that you've
to do that anyway in case mmu_notifier_unregister fails (and it can
fail because of vmalloc space shortage because somebody loaded some
framebuffer driver or whatever).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
