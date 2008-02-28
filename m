Date: Wed, 27 Feb 2008 17:03:21 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address ranges
In-Reply-To: <20080228005249.GF8091@v2.random>
Message-ID: <Pine.LNX.4.64.0802271702490.16510@schroedinger.engr.sgi.com>
References: <20080215064859.384203497@sgi.com> <20080215064932.620773824@sgi.com>
 <200802201008.49933.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.64.0802271424390.13186@schroedinger.engr.sgi.com>
 <20080228001104.GB8091@v2.random> <Pine.LNX.4.64.0802271613080.15791@schroedinger.engr.sgi.com>
 <20080228005249.GF8091@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, 28 Feb 2008, Andrea Arcangeli wrote:

> On Wed, Feb 27, 2008 at 04:14:08PM -0800, Christoph Lameter wrote:
> > Erm. This would also be needed by RDMA etc.
> 
> The only RDMA I know is Quadrics, and Quadrics apparently doesn't need
> to schedule inside the invalidate methods AFIK, so I doubt the above
> is true. It'd be interesting to know if IB is like Quadrics and it
> also doesn't require blocking to invalidate certain remote mappings.

RDMA works across a network and I would assume that it needs confirmation 
that a connection has been torn down before pages can be unmapped.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
