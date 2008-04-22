Date: Tue, 22 Apr 2008 14:42:23 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 00 of 12] mmu notifier #v13
Message-ID: <20080422194223.GT22493@sgi.com>
References: <patchbomb.1208872276@duo.random> <20080422182213.GS22493@sgi.com> <20080422184335.GN24536@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080422184335.GN24536@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 22, 2008 at 08:43:35PM +0200, Andrea Arcangeli wrote:
> On Tue, Apr 22, 2008 at 01:22:13PM -0500, Robin Holt wrote:
> > 1) invalidate_page:  You retain an invalidate_page() callout.  I believe
> > we have progressed that discussion to the point that it requires some
> > direction for Andrew, Linus, or somebody in authority.  The basics
> > of the difference distill down to no expected significant performance
> > difference between the two.  The invalidate_page() callout potentially
> > can simplify GRU code.  It does provide a more complex api for the
> > users of mmu_notifier which, IIRC, Christoph had interpretted from one
> > of Andrew's earlier comments as being undesirable.  I vaguely recall
> > that sentiment as having been expressed.
> 
> invalidate_page as demonstrated in KVM pseudocode doesn't change the
> locking requirements, and it has the benefit of reducing the window of
> time the secondary page fault has to be masked and at the same time
> _halves_ the number of _hooks_ in the VM every time the VM deal with
> single pages (example: do_wp_page hot path). As long as we can't fully
> converge because of point 3, it'd rather keep invalidate_page to be
> better. But that's by far not a priority to keep.

Christoph, Jack and I just discussed invalidate_page().  I don't think
the point Andrew was making is that compelling in this circumstance.
The code has change fairly remarkably.  Would you have any objection to
putting it back into your patch/agreeing to it remaining in Andrea's
patch?  If not, I think we can put this issue aside until Andrew gets
out of the merge window and can decide it.  Either way, the patches
become much more similar with this in.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
