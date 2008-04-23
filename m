Date: Wed, 23 Apr 2008 19:24:32 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
Message-ID: <20080423172432.GE24536@duo.random>
References: <ea87c15371b1bd49380c.1208872277@duo.random> <Pine.LNX.4.64.0804221315160.3640@schroedinger.engr.sgi.com> <20080422223545.GP24536@duo.random> <Pine.LNX.4.64.0804221619540.4996@schroedinger.engr.sgi.com> <20080423162629.GB24536@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423162629.GB24536@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 06:26:29PM +0200, Andrea Arcangeli wrote:
> On Tue, Apr 22, 2008 at 04:20:35PM -0700, Christoph Lameter wrote:
> > I guess I have to prepare another patchset then?

Apologies for my previous not too polite comment in answer to the
above, but I thought this double patchset was over now that you
converged in #v12 and obsoleted EMM and after the last private
discussions. There's nothing personal here on my side, just a bit of
general frustration on this matter. I appreciate all great
contribution from you, as last your idea to use sort(), but I can't
really see any possible benefit or justification anymore from keeping
two patchsets floating around given we already converged on the
mmu-notifier-core, and given it's almost certain mmu-notifier-core
will go in -mm in time for 2.6.26. Let's put it this way, if I fail to
merge mmu-notifier-core into 2.6.26 I'll voluntarily give up my entire
patchset and leave maintainership to you so you move 1/N to N/N and
remove mm_lock-sem patch (everything else can remain the same as it's
all orthogonal so changing the order is a matter of minutes).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
