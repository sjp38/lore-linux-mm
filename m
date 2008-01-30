Date: Wed, 30 Jan 2008 16:18:02 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address
	ranges
Message-ID: <20080130221801.GW26420@sgi.com>
References: <20080129211759.GV7233@v2.random> <Pine.LNX.4.64.0801291327330.26649@schroedinger.engr.sgi.com> <20080129220212.GX7233@v2.random> <Pine.LNX.4.64.0801291407380.27104@schroedinger.engr.sgi.com> <20080130000039.GA7233@v2.random> <20080130161123.GS26420@sgi.com> <20080130170451.GP7233@v2.random> <20080130173009.GT26420@sgi.com> <20080130182506.GQ7233@v2.random> <Pine.LNX.4.64.0801301147330.30568@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801301147330.30568@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2008 at 11:50:26AM -0800, Christoph Lameter wrote:
> On Wed, 30 Jan 2008, Andrea Arcangeli wrote:
> 
> > XPMEM requires with invalidate_range (sleepy) +
> > before_invalidate_range (sleepy). invalidate_all should also be called
> > before_release (both sleepy).
> > 
> > It sounds we need full overlap of information provided by
> > invalidate_page and invalidate_range to fit all three models (the
> > opposite of the zero objective that current V3 is taking). And the
> > swap will be handled only by invalidate_page either through linux rmap
> > or external rmap (with the latter that can sleep so it's ok for you,
> > the former not). GRU can safely use the either the linux rmap notifier
> > or the external rmap notifier equally well, because when try_to_unmap
> > is called the page is locked and obviously pinned by the VM itself.
> 
> So put the invalidate_page() callbacks in everywhere.

The way I am envisioning it, we essentially drop back to Andrea's original
patch.  We then introduce a invalidate_range_begin (I was really thinking
of it as invalidate_and_lock_range()) and an invalidate_range_end (again
I was thinking of unlock_range).

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
