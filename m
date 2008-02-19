Date: Tue, 19 Feb 2008 14:34:05 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address
	ranges
Message-ID: <20080219133405.GH7128@v2.random>
References: <20080215064859.384203497@sgi.com> <20080215064932.620773824@sgi.com> <200802191954.14874.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200802191954.14874.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2008 at 07:54:14PM +1100, Nick Piggin wrote:
> As far as sleeping inside callbacks goes... I think there are big
> problems with the patch (the sleeping patch and the external rmap
> patch). I don't think it is workable in its current state. Either
> we have to make some big changes to the core VM, or we have to turn
> some locks into sleeping locks to do it properly AFAIKS. Neither
> one is good.

Agreed.

The thing is quite simple, the moment we support xpmem the complexity
in the mmu notifier patch start and there are hacks, duplicated
functionality through the same xpmem callbacks etc... GRU can already
be 100% supported (infact simpler and safer) with my patch.

> But anyway, I don't really think the two approaches (Andrea's
> notifiers vs sleeping/xrmap) should be tangled up too much. I
> think Andrea's can possibly be quite unintrusive and useful very
> soon.

Yes, that's why I kept maintaining my patch and I posted the last
revision to Andrew. I use pte/tlb locking of the core VM, it's
unintrusive and obviously safe. Furthermore it can be extended with
Christoph's stuff in a 100% backwards compatible fashion later if needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
