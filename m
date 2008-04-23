Date: Wed, 23 Apr 2008 12:09:09 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
Message-ID: <20080423170909.GA1459@sgi.com>
References: <patchbomb.1208872276@duo.random> <ea87c15371b1bd49380c.1208872277@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ea87c15371b1bd49380c.1208872277@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

You may have spotted this already. If so, just ignore this.

It looks like there is a bug in copy_page_range() around line 667.
It's possible to do a mmu_notifier_invalidate_range_start(), then
return -ENOMEM w/o doing a corresponding mmu_notifier_invalidate_range_end().

--- jack


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
