Date: Tue, 29 Apr 2008 15:32:35 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
Message-ID: <20080429133235.GC8315@duo.random>
References: <20080423221928.GV24536@duo.random> <20080424064753.GH24536@duo.random> <20080424095112.GC30298@sgi.com> <20080424153943.GJ24536@duo.random> <20080424174145.GM24536@duo.random> <20080426131734.GB19717@sgi.com> <20080427122727.GO9514@duo.random> <Pine.LNX.4.64.0804281332030.31163@schroedinger.engr.sgi.com> <20080429001052.GA8315@duo.random> <Pine.LNX.4.64.0804291128330.12702@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804291128330.12702@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Christoph Lameter <clameter@sgi.com>, Robin Holt <holt@sgi.com>, Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

Hi Hugh!!

On Tue, Apr 29, 2008 at 11:49:11AM +0100, Hugh Dickins wrote:
> [I'm scarcely following the mmu notifiers to-and-fro, which seems
> to be in good hands, amongst faster thinkers than me: who actually
> need and can test this stuff.  Don't let me slow you down; but I
> can quickly clarify on this history.]

Still I think it'd be great if you could review mmu-notifier-core v14.
You and Nick are the core VM maintainers so it'd be great to hear any
feedback about it. I think it's fairly easy to classify the patch as
obviously safe as long as mmu notifiers are disarmed. Here a link for
your convenience.

http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.25/mmu-notifier-v14/mmu-notifier-core

> No, the locking was different as you had it, Andrea: there was an extra
> bitspin lock, carried over from the pte_chains days (maybe we changed
> the name, maybe we disagreed over the name, I forget), which mainly
> guarded the page->mapcount.  I thought that was one lock more than we
> needed, and eliminated it in favour of atomic page->mapcount in 2.6.9.

Thanks a lot for the explanation!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
