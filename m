Date: Thu, 28 Feb 2008 01:52:50 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address
	ranges
Message-ID: <20080228005249.GF8091@v2.random>
References: <20080215064859.384203497@sgi.com> <20080215064932.620773824@sgi.com> <200802201008.49933.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0802271424390.13186@schroedinger.engr.sgi.com> <20080228001104.GB8091@v2.random> <Pine.LNX.4.64.0802271613080.15791@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802271613080.15791@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2008 at 04:14:08PM -0800, Christoph Lameter wrote:
> Erm. This would also be needed by RDMA etc.

The only RDMA I know is Quadrics, and Quadrics apparently doesn't need
to schedule inside the invalidate methods AFIK, so I doubt the above
is true. It'd be interesting to know if IB is like Quadrics and it
also doesn't require blocking to invalidate certain remote mappings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
