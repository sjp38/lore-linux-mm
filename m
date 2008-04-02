From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 1/9] EMM Notifier: The notifier calls
Date: Wed, 2 Apr 2008 09:26:10 -0500
Message-ID: <20080402142609.GD22493@sgi.com>
References: <20080401205531.986291575@sgi.com> <20080401205635.793766935@sgi.com> <20080402064952.GF19189@duo.random> <20080402105925.GC22493@sgi.com> <20080402111651.GN19189@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758198AbYDBO0Z@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080402111651.GN19189@duo.random>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Christoph Lameter <clameter@sgi.com>, Hugh Dickins <hugh@veritas.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Nick Piggin <npiggin@suse.de>
List-Id: linux-mm.kvack.org

I must have missed v10.  Could you repost so I can build xpmem
against it to see how it operates?  To help reduce confusion, you should
probably comandeer the patches from Christoph's set which you think are
needed to make it sleep.

Thanks,
Robin


On Wed, Apr 02, 2008 at 01:16:51PM +0200, Andrea Arcangeli wrote:
> On Wed, Apr 02, 2008 at 05:59:25AM -0500, Robin Holt wrote:
> > On Wed, Apr 02, 2008 at 08:49:52AM +0200, Andrea Arcangeli wrote:
> > > Most other patches will apply cleanly on top of my coming mmu
> > > notifiers #v10 that I hope will go in -mm.
> > > 
> > > For #v10 the only two left open issues to discuss are:
> > 
> > Does your v10 allow sleeping inside the callbacks?
> 
> Yes if you apply all the patches. But not if you apply the first patch
> only, most patches in EMM serie will apply cleanly or with minor
> rejects to #v10 too, Christoph's further work to make EEM sleep
> capable looks very good and it's going to be 100% shared, it's also
> going to be a lot more controversial for merging than the two #v10 or
> EMM first patch. EMM also doesn't allow sleeping inside the callbacks
> if you only apply the first patch in the serie.
> 
> My priority is to get #v9 or the coming #v10 merged in -mm (only
> difference will be the replacement of rcu_read_lock with the seqlock
> to avoid breaking the synchronize_rcu in GRU code). I will mix seqlock
> with rcu ordered writes. EMM indeed breaks GRU by making
> synchronize_rcu a noop and by not providing any alternative (I will
> obsolete synchronize_rcu making it a noop instead). This assumes Jack
> used synchronize_rcu for whatever good reason. But this isn't the real
> strong point against EMM, adding seqlock to EMM is as easy as adding
> it to #v10 (admittedly with #v10 is a bit easier because I didn't
> expand the hlist operations for zero gain like in EMM).
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
