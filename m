Date: Sun, 3 Feb 2008 03:23:56 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 2/4] mmu_notifier: Callbacks to invalidate address
	ranges
Message-ID: <20080203022356.GD7185@v2.random>
References: <20080201050439.009441434@sgi.com> <20080201050623.344041545@sgi.com> <20080201220952.GA3875@sgi.com> <Pine.LNX.4.64.0802011517430.20608@schroedinger.engr.sgi.com> <20080201233528.GE12099@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080201233528.GE12099@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, Feb 01, 2008 at 05:35:28PM -0600, Robin Holt wrote:
> No, we need a callout when we are becoming more restrictive, but not
> when becoming more permissive.  I would have to guess that is the case
> for any of these callouts.  It is for both GRU and XPMEM.  I would
> expect the same is true for KVM, but would like a ruling from Andrea on
> that.

I still hope I don't need to take any lock in _range_start and that
losing coherency (w/o risking global memory corruption but only
risking temporary userland data corruption thanks to the page pin) is
ok for KVM.

If I would have to take a lock in _range_start like XPMEM is forced to
do (GRU is by far not forced to it, if it would switch to my #v5) then
it would be a problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
