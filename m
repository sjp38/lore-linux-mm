Date: Thu, 28 Feb 2008 01:42:26 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 5/6] mmu_notifier: Support for drivers with revers maps
	(f.e. for XPmem)
Message-ID: <20080228004226.GE8091@v2.random>
References: <20080215064859.384203497@sgi.com> <20080215064933.376635032@sgi.com> <200802201055.21343.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0802271440530.13186@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802271440530.13186@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2008 at 02:43:41PM -0800, Christoph Lameter wrote:
> Nope. unmap_mapping_range is already handled by the range callbacks.

But they're called with atomic=1 on anything but anonymous memory. I
understood Andrew asked to remove the atomic param and to allow
sleeping for all kind of vmas. I also understood certain XPMEM
customers asked to use XPMEM on something more than anonymous memory.

> The situation that you are imagining has already been dealt with [..]

I guess there's some misunderstanding, I think Nick was referring to
the above problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
