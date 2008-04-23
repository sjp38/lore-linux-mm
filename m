Date: Wed, 23 Apr 2008 20:34:18 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
Message-ID: <20080423183418.GK24536@duo.random>
References: <ea87c15371b1bd49380c.1208872277@duo.random> <Pine.LNX.4.64.0804221315160.3640@schroedinger.engr.sgi.com> <20080422223545.GP24536@duo.random> <Pine.LNX.4.64.0804221619540.4996@schroedinger.engr.sgi.com> <20080423162629.GB24536@duo.random> <20080423172432.GE24536@duo.random> <Pine.LNX.4.64.0804231120180.12373@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804231120180.12373@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 11:21:49AM -0700, Christoph Lameter wrote:
> No I really want you to do this. I have no interest in a takeover in the 

Ok if you want me to do this, I definitely prefer the core to go in
now. It's so much easier to concentrate on two problems at different
times then to attack both problems at the same time given they're
mostly completely orthogonal problems. Given we already solved one
problem, I'd like to close it before concentrating on the second
problem. I already told you it was my interest to support XPMEM
too. For example it was me to notice we couldn't possibly remove
can_sleep parameter from invalidate_range without altering the locking
as vmas were unstable outside of one of the three core vm locks. That
finding resulted in much bigger patches than we hoped (like Andrew
previously sort of predicted) and you did all great work to develop
those. From my part, once the converged part is in, it'll be a lot
easier to fully concentrate on the rest. My main focus right now is to
produce a mmu-notifier-core that is entirely bug free for .26.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
