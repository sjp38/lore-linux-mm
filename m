Date: Wed, 27 Feb 2008 14:39:46 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address ranges
In-Reply-To: <20080220010038.GQ7128@v2.random>
Message-ID: <Pine.LNX.4.64.0802271436260.13186@schroedinger.engr.sgi.com>
References: <20080215064859.384203497@sgi.com> <20080215064932.620773824@sgi.com>
 <200802201008.49933.nickpiggin@yahoo.com.au> <20080220010038.GQ7128@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008, Andrea Arcangeli wrote:

> Well, xpmem requirements are complex. As as side effect of the
> simplicity of my approach, my patch is 100% safe since #v1. Now it
> also works for GRU and it cluster invalidates.

The patch has to satisfy RDMA, XPMEM, GRU and KVM. I keep hearing that we 
have a KVM only solution that works 100% (which makes me just switch 
ignore the rest of the argument because 100% solutions usually do not 
exist).


> rcu_read_lock), no "atomic" parameters, and it doesn't open a window
> where sptes have a view on older pages and linux pte has view on newer
> pages (this can happen with remap_file_pages with my KVM swapping
> patch to use V8 Christoph's patch).

Ok so you are now getting away from keeping the refcount elevated? That 
was your design decision....


> > Also, how to you resolve the case where you are not allowed to sleep?
> > I would have thought either you have to handle it, in which case nobody
> > needs to sleep; or you can't handle it, in which case the code is
> > broken.
> 
> I also asked exactly this, glad you reasked this too.

It would have helped if you would have repeated my answers that you had 
already gotten before. You knew I was on vacation....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
