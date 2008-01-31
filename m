Date: Thu, 31 Jan 2008 14:39:12 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [kvm-devel] [patch 2/6] mmu_notifier: Callbacks to invalidate
	address ranges
Message-ID: <20080131133912.GM7185@v2.random>
References: <20080130170451.GP7233@v2.random> <20080130173009.GT26420@sgi.com> <20080130182506.GQ7233@v2.random> <Pine.LNX.4.64.0801301147330.30568@schroedinger.engr.sgi.com> <20080130235214.GC7185@v2.random> <Pine.LNX.4.64.0801301555550.1722@schroedinger.engr.sgi.com> <20080131003434.GE7185@v2.random> <Pine.LNX.4.64.0801301805200.14071@schroedinger.engr.sgi.com> <20080131024252.GF7185@v2.random> <Pine.LNX.4.64.0801301848550.14263@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801301848550.14263@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2008 at 06:51:26PM -0800, Christoph Lameter wrote:
> True. hlist_del_init ok? That would allow to check the driver that the 
> mmu_notifier is already linked in using !hlist_unhashed(). Driver then 
> needs to properly initialize the mmu_notifier list with INIT_HLIST_NODE().

A driver couldn't possibly care about the mmu notifier anymore at that
point, we just agreed a moment ago that the list can't change under
mmu_notifier_release, and in turn no driver could possibly call
mmu_notifier_unregister/register at that point anymore regardless of
the outcome of hlist_unhashed and external serialization must let the
driver know he's done with the notifiers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
